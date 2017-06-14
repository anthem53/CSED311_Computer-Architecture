`include "opcodes.v" 

module Datapath (clk, reset_n, data1, data2,  readM2, writeM2, is_halted,
	address1, address2, output_port, 
	inst, 
	ctrlPCWriteCond, ctrlPCWrite, ctrlMemtoReg, ctrlIRWrite, ctrlPCSource, ctrlALUOp, ctrlALUSrcB, ctrlALUSrcA, ctrlRegWrite, ctrlRegDst, ctrlWritePort);	

	input reset_n;    // active-low RESET signal
	input clk;        // clock signal				
	input [`WORD_SIZE-1:0] data1;	  
	inout [`WORD_SIZE-1:0] data2;			  // input -> inout 으로 한번 해봄.		  
	input readM2;
	input writeM2;	 
	input is_halted;
																  
	output [`WORD_SIZE-1:0] address1;		
	output [`WORD_SIZE-1:0] address2;	 																		   
	output reg [`WORD_SIZE-1:0] output_port;	// this will be used for a "WWD" instruction
		
	
																																					  
	output reg [`WORD_SIZE-1:0] inst;
	
	
	
	input ctrlPCWriteCond;
	input ctrlPCWrite;		 
	input [1:0]ctrlMemtoReg;
	input ctrlIRWrite;
	input [1:0] ctrlPCSource;
	input [2:0] ctrlALUOp;
	input [1:0] ctrlALUSrcB;
	input ctrlALUSrcA;
	input ctrlRegWrite;
	input [1:0] ctrlRegDst;				 		
	input ctrlWritePort;			   
																	 									  
	/////////////////////////////////////////////////////////////////////
	
	
	wire Memwritewire;
	
	wire [1:0]readReg1;
	wire [1:0]readReg2;	 
	wire [1:0] writeReg;
													 
	wire [`WORD_SIZE-1:0] MemData;
	wire [`WORD_SIZE-1:0] writeData;
																	 

	reg [`WORD_SIZE-1:0] PC;																	 
	
	
	wire [`WORD_SIZE-1:0] readData1;
	wire [`WORD_SIZE-1:0] readData2;
		
	reg [`WORD_SIZE-1:0] A;
	reg [`WORD_SIZE-1:0] B;
	wire [`WORD_SIZE-1:0] C; 
	wire OverflowFlag;
	
	
	wire [`WORD_SIZE-1:0] ALUwire1;
	wire [`WORD_SIZE-1:0] ALUwire2;
	
	wire  [7:0] immediate;									
	reg [`WORD_SIZE-1:0]ALUOut;
	
	reg [`WORD_SIZE-1:0] MemoryDataReg ;
	
	
	wire [15:0] nextPC;
	
	
	wire doBranch;
	assign doBranch = (inst[15:12]==0 && C!=0) || (inst[15:12]==1 && C==0) || (inst[15:12]==2 && C[15]==0 && C!=0) || (inst[15:12]==3 && C[15]==1);
	
	
	reg [15:0] readDataTemp;		  
	assign readDataTemp = (readM2 ? data2 : 16'hzzzz);
	assign data2 = (writeM2 ? B : 16'hzzzz);
	
	
																	  
	assign address1  = PC;
	assign address2  = ALUOut;  /*  for LW or SW*/		 
		
		
	assign immediate = inst[7:0];
	
	assign readReg1 = inst[11:10];
	assign readReg2 = inst[9:8];
	assign writeReg = 	ctrlRegDst == 2'b00 ? inst[9:8] : ( ctrlRegDst == 2'b01 ? inst[7:6] : 2) ;  

	
	
	assign ALUwire1 = ctrlALUSrcA ?  A : PC;
	assign ALUwire2 = ctrlALUSrcB == 2'b00 ? B :  (ctrlALUSrcB ==2'b01 ? 1 :   (ctrlALUSrcB == 2'b10  ? {{8{immediate[7]}}, immediate[7:0]}  : 0)) ;
	
	assign nextPC = (ctrlPCSource == 0 ? C : ( ctrlPCSource == 1 ? ALUOut : {PC[15:12],inst[11:0]} ));	 
	
	assign writeData = ctrlMemtoReg == 2'b00  ? ALUOut  : (ctrlMemtoReg == 2'b01 ? MemoryDataReg : (ctrlMemtoReg == 2'b10 ? PC : {immediate,8'b00000000}  )) ;
	assign Memwritewire = B;
	//assign data2 = 	Memwritewire;
	
											 
	RegisterFiles rf (ctrlRegWrite, readReg1, readReg2, writeReg, writeData, clk, reset_n, readData1, readData2);
	ALU alu ( ALUwire1, ALUwire2, ctrlALUOp, C, OverflowFlag);   	  															  
	
	
	always @(posedge clk) begin	 	   
		if(reset_n == 0) begin
			PC = 0;				
			output_port = `WORD_SIZE'd0;				 
		end					
		
		else begin	
																																							 
			inst = data1;
			A = readData1;
			B = readData2;								
			if(readM2)
				MemoryDataReg = readDataTemp;
		   ALUOut = C;	  
		   
		   
		   
		   if(ctrlWritePort == 1) begin
			 output_port = ALUOut;  	 		   
		   end
		   
		   if(ctrlPCWrite == 1 || (ctrlPCWriteCond && doBranch)) begin
			   PC = nextPC;											 
		   end
		   //num_inst = num_inst + 1'd1;
		   if(is_halted == 1'd1)
			   PC = 16'd0;
		  
		end
		
	end
		
endmodule				