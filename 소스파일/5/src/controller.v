`timescale 1ns/1ns

module controller(clk,inst,reset_n, ALUSrcA, ALUSrcB,lorD,IRWrite,PCWrite,PCWriteCond, PCSource,RegDest,RegWrite,MemRead,MemWrite,MemtoReg,func);	   
	
	
	input clk;	   		   
	input reset_n;		
	output reg ALUSrcA	;
	output reg ALUSrcB	;
	output reg lorD	;
	output reg  IRWrite	;
	output reg PCWrite	;
	output reg PCWriteCond	;
	output reg PCSource	;
	output reg RegDest	;
	output reg RegWrite	;
	output reg MemRead	;
	output reg MemWrite	;
	output reg MemtoReg	;
	output reg func;
	
	reg [3:0] mPC; 
	reg [3:0] nPC;
	reg [3:0] opcode;
	output reg [5:0] func;	
	
	parameter [3:0]IF1 = 4'd0, [4:0]IF2 = 4'd1, [4:0]IF3 = 4'd2, [4:0]IF4 = 4'd3, [4:0]ID = 4'd4, [4:0]EX1 = 4'd5, [4:0]EX2 = 4'd6, [4:0]MEM1 = 4'd7, [4:0]MEM2 = 4'd8, [4:0]MEM3 = 4'd9, [4:0]MEME4 = 4'd10,  [4:0]WB = 4'd11;
		   												
	
	always @ (mPC, inst) begin
		opcode = inst[15:12];
		func = inst[5:0]; 
	   case(mPC) 
		   IF1:	 // signal initiallizing.
		   			nPC = IF2;		
		   IF2:	nPC = IF3;
		   IF3:	nPC = IF4;
		   IF4:   if(opcode == 4`d15 ||opcode == 4`d10 || opcode == 4`d9)  begin
				   		nPC = IF1;
					end 
			  		else	 begin
				   		nPC = ID;
					end
		   ID:     nPC = EX1;
		   EX1: nPC = EX2;
		   
		   EX2: if(opcode == 4`d15 ||  opcode == 4`d4 ||  opcode == 4`d5 ||  opcode == 4`d6 )  begin
			   			nPC =  WB;
					end
	   				if(opcode == 4`d7 || opcode == 4`d8 ) begin
		   				nPC =  MEM1;
					if(opcode <= 4`d3 && opcode >= 0) begin  
						nPC = IF1;		
		  MEM1:	nPC = MEM2;				
		  MEM2:	nPC = MEM3;
		  MEM3:	nPC = MEM4;
		  MEM4:	if(opcode == 4`d7 ) begin
			  				nPC = WB;
			  			else
						if (opcode == 4`d8) begin
							nPC = IF1;
			  			else
		  WB: nPC =  IF1;  
						
	end
	
	always @(posedge clk, negedge reset_n) 	begin
	    if(reset_n == 0)
		   mPC =IF1;	
	    else
			mPC = nPC;
   	end
endmodule