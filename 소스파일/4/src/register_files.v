`include "opcodes.v"

module RegisterFiles(ctrlRegWrite, readReg1, readReg2, writeReg, writeData, clk, reset_n, readData1, readData2);	 
	input ctrlRegWrite;
	input [1:0] readReg1;
	input [1:0] readReg2;	
	input [1:0] writeReg;
	input [`WORD_SIZE-1:0] writeData; 
	input clk;														
	input reset_n;														
	output reg [`WORD_SIZE-1:0] readData1;
	output reg [`WORD_SIZE-1:0] readData2; 
																					 
	reg [`WORD_SIZE-1:0] registers[`NUM_REGS-1:0];	   
	
	always @(*) begin
		readData1 = registers[readReg1];
		readData2 = registers[readReg2];
	end
	
	always @(posedge clk) begin	  																									 
		if(ctrlRegWrite == 1)
			registers[writeReg] = writeData;
		
		if(reset_n == 0) begin
			for(int i = 0; i < `NUM_REGS; i++) begin
				registers[i] = 0;
			end
		end
	end
	  
endmodule