`timescale 1ns / 100ps		

module ALU (A, B, FuncCode, C, OverflowFlag);
	input [15:0] A;
	input [15:0] B;
	input [2:0] FuncCode;  
	
	output [15:0] C;
	output OverflowFlag;
	
	reg [15:0] C;
	reg OverflowFlag;
	reg extra;					  
	
	initial begin
		C <= 16'h0000;
		OverflowFlag <= 1'b0;
	end

	always @(*) begin	
			case (FuncCode)
				0 :  
					begin
						C <= A+B;
						OverflowFlag <= (A[15] ^ C[15]) && !(A[15] ^ B[15]);
					end
				1 : 
					begin
						C <= A-B;
						OverflowFlag <= (A[15] ^ C[15]) && (A[15] ^ B[15]);
					end
				2 :	 C <= A & B;		
				3 : C <= A | B;
				4 : C <= ~A;
				5 : C <= ~A+1;
				6 : C <= A<<1;
				7 : C <= {A[15],A}>>1;
			endcase		   	
	end		 
endmodule