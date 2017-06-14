`include "opcodes.v" 

module Datapath (inst, readM, writeM, address, data, ackOutput, inputReady, reset_n, clk,
	ctrlRegDst, ctrlALUOp, ctrlALUSrc, ctrlRegWrite, ctrlRegWriteSrc, ctrlReadDataDst, ctrlMemRead, ctrlMemWrite, ctrlLHI, ctrlPc, aluControl, C);
	output reg [`WORD_SIZE-1:0] inst;	 
	output reg readM;					   
	output reg writeM;
	output reg [`WORD_SIZE-1:0] address;
	inout [`WORD_SIZE-1:0] data;
	input inputReady;				
	input ackOutput;
	input reset_n;	  
	input clk;		   
	
	input ctrlRegDst;
	input ctrlALUOp;	
	input [1:0] ctrlALUSrc;
	input ctrlRegWrite; 	 
	input ctrlRegWriteSrc;		  
	input ctrlReadDataDst; 
	input ctrlMemRead;
	input ctrlMemWrite;
	input ctrlLHI;		 
	input [1:0] ctrlPc;
	input [2:0] aluControl;
	
	reg [`WORD_SIZE-1:0] PC;
	wire [`WORD_SIZE-1:0] A;				  
	wire [`WORD_SIZE-1:0] B;				  
	wire [`WORD_SIZE-1:0] Breg;
	output [`WORD_SIZE-1:0] C;
	wire [`WORD_SIZE-1:0] Cout;
	
	wire overflowFlag; 
	reg [`WORD_SIZE-1:0] instruction;
	wire [1:0] readReg1;									
	wire [1:0] readReg2;
	wire [1:0] writeReg;
	reg [`WORD_SIZE-1:0] memoryData;
	wire [`WORD_SIZE-1:0] writeData;
	
	wire [`WORD_SIZE-1:0] fourPC;
	wire [`WORD_SIZE-1:0] branchPC;
	wire [`WORD_SIZE-1:0] jumpPC;
	wire [`WORD_SIZE-1:0] nextPC;
	
	assign readReg1 = instruction[11:10]; 	
	assign readReg2 = instruction[9:8];
	assign writeReg = ctrlRegWriteSrc ? instruction[9:8] : instruction[7:6];
	assign writeData = ctrlReadDataDst ? memoryData : Cout;
	assign inst = instruction;
	assign B = ctrlALUSrc ? {{8{instruction[7]}}, instruction[7:0]} : Breg;	
	assign Cout = ctrlLHI ? {instruction[7:0],8'h00} : C;
	
	assign fourPC = PC+1;
	assign branchPC = fourPC + {{8{instruction[7]}}, instruction[7:0]};
	assign jumpPC = {fourPC[15:12], instruction[11:0]};
	assign nextPC = ctrlPc[0] ? jumpPC : (ctrlPc[1] ? branchPC : fourPC);  
	
	reg [`WORD_SIZE-1:0] loadedData;
	assign data = writeM ? loadedData : `WORD_SIZE'bz; 
																 
	RegisterFiles rf (ctrlRegWrite, readReg1, readReg2, writeReg, writeData, clk, reset_n, A, Breg);
	ALU alu (A,B,aluControl,C,overflowFlag);   
	
	always @(PC) begin		 	 
		address = PC;
		readM = 1;								
		wait (inputReady == 1);	   
		readM = 0;					   
		instruction = data;			 
		wait (inputReady == 0);		 	
											 
		address = Cout;
		loadedData = Breg;
		readM = ctrlMemRead;
		writeM = ctrlMemWrite;	 
		if (readM || writeM) begin
			wait (inputReady == 1 || ackOutput == 1);		 
			if (inputReady == 1) begin
				memoryData = data;	  							 
			end
			readM = 0;
			writeM = 0;	  		   								   
		end										 
		wait (inputReady == 0 && ackOutput == 0);			
	end	
	
	always @(posedge reset_n) begin			  
			PC = 0;
			readM = 0;
			writeM = 0;	   
	end
	
	always @(posedge clk) begin	 	   
		PC = nextPC; 	  			    
	end
		
endmodule				