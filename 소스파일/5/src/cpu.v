`include "opcodes.v" 	   

module cpu (clk, reset_n, readM1, address1, data1, readM2, writeM2, address2, data2, num_inst, output_port, is_halted);
	input reset_n;    // active-low RESET signal
	input clk;        // clock signal				
	input [`WORD_SIZE-1:0] data1;	  
	input [`WORD_SIZE-1:0] data2;
	
	output readM1;
	output [`WORD_SIZE-1:0] address1;		   
	output readM2;
	output writeM2;
	output [`WORD_SIZE-1:0] address2;	 
	output [`WORD_SIZE-1:0] num_inst;		// number of instruction during execution
	output [`WORD_SIZE-1:0] output_port;	// this will be used for a "WWD" instruction
	output is_halted;				// set if the cpu is halted
		
		
		
		
																																					  
	wire [`WORD_SIZE-1:0] inst;	
	
	wire ctrlPCWriteCond;
	wire ctrlPCWrite;			 
	wire [1:0] ctrlMemtoReg;
	wire ctrlIRWrite;
	wire [1:0] ctrlPCSource;
	wire [2:0] ctrlALUOp;
	wire [1:0] ctrlALUSrcB;
	wire ctrlALUSrcA;
	wire ctrlRegWrite;
	wire [1:0] ctrlRegDst;				 		
	wire ctrlWritePort;
									  
											   
									   						   	
	// Datapath 
    /*Datapath dpath (clk, reset_n, data1, data2,
	address1, address2, num_inst, output_port, is_halted,
	inst,
	ctrlPCWriteCond, ctrlPCWrite, ctrlIorD, ctrlMemtoReg, ctrlIRWrite, ctrlPCSource, ctrlALUOp, ctrlALUSrcB, ctrlALUSrcA, ctrlRegWrite, ctrlRegDst, ctrlWritePort);*/	
	
	Datapath dpath (clk, reset_n, data1, data2,  readM2, writeM2, is_halted,
	address1, address2, output_port, 
	inst, 
	ctrlPCWriteCond, ctrlPCWrite, ctrlMemtoReg, ctrlIRWrite, ctrlPCSource, ctrlALUOp, ctrlALUSrcB, ctrlALUSrcA, ctrlRegWrite, ctrlRegDst, ctrlWritePort);
																													
	/*ControlUnit ctrl_unit (readM1, readM2, writeM2,
	inst, clk, reset_n,
	ctrlPCWriteCond, ctrlPCWrite, ctrlIorD, ctrlMemtoReg, ctrlIRWrite, ctrlPCSource, ctrlALUOp, ctrlALUSrcB, ctrlALUSrcA, ctrlRegWrite, ctrlRegDst, ctrlWritePort);		 */
	
	ControlUnit ctrl_unit (readM1, readM2, writeM2,	is_halted, num_inst,
	inst, clk, reset_n,
	ctrlPCWriteCond, ctrlPCWrite, ctrlMemtoReg, ctrlIRWrite, ctrlPCSource, ctrlALUOp, ctrlALUSrcB, ctrlALUSrcA, ctrlRegWrite, ctrlRegDst, ctrlWritePort);  
	

endmodule							  																		  