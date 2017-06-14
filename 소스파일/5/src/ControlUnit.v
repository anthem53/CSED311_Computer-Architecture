`include "opcodes.v" 	   

module ControlUnit(readM1, readM2, writeM2,	is_halted, num_inst,
	inst, clk, reset_n, 
	ctrlPCWriteCond, ctrlPCWrite, ctrlMemtoReg, ctrlIRWrite, ctrlPCSource, ctrlALUOp, ctrlALUSrcB, ctrlALUSrcA, ctrlRegWrite, ctrlRegDst, ctrlWritePort);  
	
	output readM1;
	output readM2;
	output writeM2;		
	
	output reg is_halted;		 
	output reg [`WORD_SIZE-1:0] num_inst;		// number of instruction during execution
	
	input [`WORD_SIZE-1:0] inst;		
	input clk;		   
	input reset_n;
	
	output ctrlPCWriteCond;
	output ctrlPCWrite;		 	 
	output [1:0] ctrlMemtoReg;
	output ctrlIRWrite;
	output [1:0] ctrlPCSource;
	output [2:0] ctrlALUOp;
	output [1:0] ctrlALUSrcB;
	output ctrlALUSrcA;
	output ctrlRegWrite;
	output [1:0] ctrlRegDst;				 		
	output ctrlWritePort;			 
	
								  
																	   
	wire [1:0] ctrlNextPC;					
	reg [3:0] uPC;					

	wire [1:0] ctrlALUOpTemp;//plus, minus, function, or. each 0,1,2,3
	wire ctrlWritePortTemp;//if 0 can't write. if 1 look at function to decide
	wire ctrlRegWriteTemp;//if 0 can't write. if 1 look at function to decide	  
	wire is_haltedTemp;//if 0 can't write. if 1 look at function to decide		   
		
	
	assign ctrlNextPC = (uPC==0 || uPC==3 || uPC==6 || uPC==8 ? 1 : (uPC==1 ? 2 : (uPC==2 ? 3 : 0)));
	
	assign readM1 = (uPC == 0 ? 1 : 0);  
	assign readM2 = (uPC == 3 ? 1 : 0);
	assign writeM2 = (uPC == 5 ? 1 : 0); 
	assign ctrlPCWriteCond = (uPC==11 ? 1 : 0);	
	assign ctrlPCWrite = (uPC==0||uPC==12||(inst[15:12]==15 && (inst[5:0]==25 || inst[5:0]==26) && uPC==7) ? 1  : 0);		 
	assign ctrlMemtoReg = (uPC==1 ? 2 : (uPC == 4 ? 1 : (uPC == 10 ? 3 : 0)));   	  
	assign ctrlIRWrite = (uPC == 0 ? 1 : 0);
	assign ctrlPCSource = (uPC == 0 ? 0 : (uPC == 12 ? 2 : 1));		
	assign ctrlALUOp = (ctrlALUOpTemp==2 ? (inst[15:12]==5 ? 3 : (inst[15:12]==15 && inst[5:0]<8 ? inst[5:0] : 0)) : ctrlALUOpTemp);
	assign ctrlALUOpTemp = (uPC < 6 ? 0 : (uPC == 11 ? 1 : 2));
	assign ctrlALUSrcB = (uPC == 0 ? 1 : (uPC < 3 || uPC == 8 ? 2 : ( (inst[15:12]==15 && inst[5:0]>24) || inst[15:12]==3 || inst[15:12]==2 ? 3 : 0)));
	assign ctrlALUSrcA = (uPC < 2 ? 0 : 1);																	
	assign ctrlRegDst = (uPC==1 ? 2 : (uPC==7 ? 1 : 0));				 		
	assign ctrlWritePort = (ctrlWritePortTemp && inst[5:0]==28 ? 1 : 0);	 
	assign ctrlWritePortTemp = (uPC == 7 ? 1 : 0);									   
	assign ctrlRegWrite = (ctrlRegWriteTemp==0 ? 0 : ((uPC==7&&inst[5:0]>7) || (uPC==1&& (!(inst[15:12]==10||(inst[15:12]==15&&inst[5:0]==26))) ) ? 0 : 1));
	assign ctrlRegWriteTemp = (uPC == 7 || uPC == 10 || uPC == 9 || uPC == 4 || uPC == 1 ? 1 : 0);	   											 
	assign is_haltedTemp = (uPC == 7 ? 1 : 0);		
	
	initial begin
		is_halted = 0;
		uPC = 0;	  
		num_inst = 0;																															  
	end							  					
	
	always @(posedge clk) begin
		if(is_haltedTemp && inst[5:0]==29)
			is_halted = 1;
		
		if(ctrlNextPC == 0)	begin
			uPC = 0;
			num_inst += 1;
		end
		if(ctrlNextPC == 1)
			uPC = uPC+1;
		if(ctrlNextPC == 2)
			uPC = (inst[15:12]<4 ? 11 : (inst[15:12]<6 ? 8 : (inst[15:12]==6 ? 10 : (inst[15:12]<9 ? 2 : (inst[15:12]<11 ? 12 : 6)))));
		if(ctrlNextPC == 3)
			uPC = (inst[15:12]==7 ? 3 : 5);	
		
		if(reset_n == 0 || is_halted == 1) begin
			uPC = 0;
		end
	end		  
	
endmodule