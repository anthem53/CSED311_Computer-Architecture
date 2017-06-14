`include "opcodes.v" 	   

module ControlUnit(inst, ctrlRegDst, ctrlALUOp, ctrlALUSrc, ctrlRegWrite, ctrlRegWriteSrc, ctrlReadDataDst, ctrlMemRead, ctrlMemWrite, ctrlLHI, ctrlPc, aluControl, reset_n, C);  
	input [`WORD_SIZE-1:0] inst;
	input [`WORD_SIZE-1:0] C;
	output reg ctrlRegDst;
	output reg ctrlALUOp;  
	output reg [1:0] ctrlALUSrc;
	output reg ctrlRegWrite; 		
	output reg ctrlRegWriteSrc;
	output reg ctrlReadDataDst;	  
	output reg ctrlMemRead;
	output reg ctrlMemWrite;
	output reg ctrlLHI;		   
	output reg [1:0] ctrlPc;
	output reg [2:0] aluControl;   
	input reset_n; 
				   			
	wire branch;
	assign branch = (C == 16'h0000)? 1 : 0;		 
	
	reg[4:0] opcode; 
						   
	
	
	always @(*) begin   	 						   
		opcode  = inst[15:12];
		
		ctrlRegDst  = 1'b0;
		ctrlALUOp = 1'b0;
		ctrlALUSrc	= 1'b0;		       
		ctrlRegWrite = 1'b0;
	   	ctrlRegWriteSrc	= 1'b0;
		ctrlReadDataDst	= 1'b0;
		ctrlMemRead	= 1'b0;  
		ctrlMemWrite = 1'b0;
		ctrlLHI	= 1'b0;
		ctrlPc= 2'b00;
		aluControl = 3'b000;  	   
			
		if (opcode == `ALU_OP) begin  
			ctrlRegDst  = 1'b1;
			ctrlALUOp = 1'b1; 
			ctrlRegWrite = 1'b1;
			aluControl = inst[2:0];
		end
		
		if (opcode == `ADI_OP) begin	
			ctrlRegDst  = 1'b1;
			ctrlALUSrc	= 1'b1;	
			ctrlRegWrite = 1'b1;
			ctrlRegWriteSrc	= 1'b1;
			aluControl = 3'b000;
			
		end		
		
		if (opcode == `ORI_OP) begin
			ctrlRegDst  = 1'b1;
			ctrlALUSrc	= 1'b1;	
			ctrlRegWrite = 1'b1;
			ctrlRegWriteSrc	= 1'b1;	
			aluControl = 3'b011;
		end	
		
		if (opcode == `LHI_OP) begin	 
			ctrlRegDst  = 1'b1;
			ctrlALUSrc	= 1'b1;	
			ctrlRegWrite = 1'b1;
			ctrlRegWriteSrc	= 1'b1;
			ctrlLHI	= 1'b1;
			aluControl = 3'b110;			
		end	
																				 
		if (opcode == `LWD_OP) begin	
		 	ctrlALUSrc	= 1'b1;		       
			ctrlRegWrite = 1'b1;
	   		ctrlRegWriteSrc	= 1'b1;
			ctrlMemRead	= 1'b1;
			aluControl = 3'b000;	
			ctrlReadDataDst	= 1'b1;
		end	
		
		if (opcode == `SWD_OP) begin  
			ctrlALUSrc	= 1'b1;		       
	   		ctrlRegWriteSrc	= 1'b1;
			ctrlMemWrite	= 1'b1; 			
			aluControl = 3'b000;
		end	
		
		if (opcode == `BNE_OP) begin 
														 
			ctrlPc[0]= 0;
			aluControl = 3'b001; 	
			ctrlPc[1] = !branch;
		end	
		
		if (opcode == `BEQ_OP) begin
														 
			ctrlPc[0]= 0;							
			aluControl = 3'b001;   	
			ctrlPc[1] = branch;
		end	
		if (opcode == `JMP_OP) begin 
			ctrlPc= 2'b01;
		end	
		
		
	end		  
	
endmodule