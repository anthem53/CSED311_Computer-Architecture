`include "opcodes.v"
`include "alu.v" 				   

module ALU_RegFiles(countOp, functionCode, readReg1, readReg2, writeReg, outputData);	
	input [7:0] countOp;	 
	input [2:0] functionCode;
	
	input [1:0] readReg1;
	input [1:0] readReg2;	
	input [1:0] writeReg;
	output [`WORD_SIZE-1:0] outputData;
	
	wire [`WORD_SIZE-1:0] writeData;									  	
	wire overflowFlag;
		
	reg [`WORD_SIZE-1:0] readData1;
	reg [`WORD_SIZE-1:0] readData2;	
	reg isWriteDone;
	reg [`WORD_SIZE-1:0] outputData;
	
	reg [`WORD_SIZE-1:0] regs [0:`NUM_REGS-1];			
	
	ALU alu (readData1, readData2, functionCode, writeData, overflowFlag);			
	
	assign outputData = writeData;
												   
	
	initial begin				
		isWriteDone = 0;
		for(int i = 0; i < `NUM_REGS; i++)
			regs[i] = 16'h0010;
	end
	
	
	always @(countOp) begin
		readData1 = regs[readReg1];
		readData2 = regs[readReg2];
		regs[writeReg] = writeData;
	end
	always @(writeData) begin	  
		regs[writeReg] = writeData;	   
	end		  
	
endmodule