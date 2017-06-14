`timescale 1ns /100ps
`include "opcodes.v"																					 

module ALU (						   		 
	input [`WORD_SIZE-1:0] A,
	input [`WORD_SIZE-1:0] B,
	input [2:0] FuncCode,						  
	output reg [`WORD_SIZE-1:0] C,	   
	output reg OverflowFlag
	);	 
	
	reg extra;					  
	
	initial begin
		C <= 0;
		OverflowFlag <= 0;
	end

	always @(*) begin	
			case (FuncCode)
				0 :  
					begin
						C <= A+B;
						OverflowFlag <= (A[`WORD_SIZE-1] ^ C[`WORD_SIZE-1]) && !(A[`WORD_SIZE-1] ^ B[`WORD_SIZE-1]);
					end
				1 : 
					begin
						C <= A-B;
						OverflowFlag <= (A[`WORD_SIZE-1] ^ C[`WORD_SIZE-1]) && (A[`WORD_SIZE-1] ^ B[`WORD_SIZE-1]);
					end
				2 :	 C <= A & B;		
				3 : C <= A | B;
				4 : C <= ~A;
				5 : C <= ~A+1;
				6 : C <= A<<1;
				7 : C <= { A[`WORD_SIZE-1],A}>>1;  
				
			endcase		   	
	end		
endmodule
	