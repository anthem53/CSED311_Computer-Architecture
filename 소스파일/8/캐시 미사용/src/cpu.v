`timescale 1ns/1ns
`define WORD_SIZE 16    // data and address word size

module cpu(Clk, Reset_N, i_readM, i_address, i_data, d_readM, d_writeM, d_address, d_data, num_inst, output_port, is_halted, cacheStall);
	input Clk;
	wire Clk;
	input Reset_N;
	wire Reset_N;
	
	// Instruction memory interface
	output i_readM;
	wire i_readM;	   
	wire i_writeM;
	output [`WORD_SIZE-1:0] i_address;
	wire [`WORD_SIZE-1:0] i_address;

	inout [`WORD_SIZE-1:0] i_data;
	wire [`WORD_SIZE-1:0] i_data;
	
	// Data memory interface
	output d_readM;
	wire d_readM;
	output d_writeM;
	wire d_writeM;
	output [`WORD_SIZE-1:0] d_address;
	wire [`WORD_SIZE-1:0] d_address;

	inout [`WORD_SIZE-1:0] d_data;
	wire [`WORD_SIZE-1:0] d_data;

	output [`WORD_SIZE-1:0] num_inst;
	wire [`WORD_SIZE-1:0] num_inst;
	output [`WORD_SIZE-1:0] output_port;
	wire [`WORD_SIZE-1:0] output_port;
	output is_halted;
	wire is_halted;	  
	
	
	assign i_writeM = 0;		  
	assign i_readM = 1;					   
	
	
	//
	
	
	wire [15:0] inst;
	wire isJR;
	wire readMemExe;
	wire [5:0] functionCode;	 
	
	wire [1:0] ctrlPCSrc;	   
	wire ctrlPCWrite;
	wire ctrlInstRegWrite;
	wire [1:0] ctrlASrc;
	wire [1:0] ctrlBSrc;
	wire [1:0] ctrlALUOp;
	wire [1:0] ctrlRegDst;
	wire ctrlMemtoReg;
	wire ctrlRegWrite;
	wire ctrlPortWrite;
	
	wire regWriteExe;
	wire regWriteMem;
	wire [1:0] regDstExe;
	wire [1:0] regDstMem;
	wire [1:0] rs;
	wire [1:0] rt;
	wire [1:0] ctrlRsSrc;
	wire [1:0] ctrlRtSrc;			
	
	wire ctrlGreater;
	wire ctrlEqual;
	wire ctrlLess;					  
	
	input cacheStall;
	

	// TODO : Implement your pipelined CPU!	 				 			
	Datapath dp (Clk, Reset_N, i_address, i_data, d_readM, d_writeM, d_address, d_data, output_port, 	   
		inst, isJR, functionCode, 
		ctrlPCSrc, ctrlPCWrite, ctrlInstRegWrite, ctrlASrc, ctrlBSrc, ctrlALUOp, ctrlRegDst, ctrlMemtoReg, ctrlRegWrite, ctrlPortWrite,
		regDstExe, regDstMem, rs, rt, ctrlRsSrc, ctrlRtSrc,
		ctrlGreater, ctrlLess, ctrlEqual,
		cacheStall);	
		
	ControlUnit cu (Clk, Reset_N, d_readM, d_writeM, num_inst, is_halted,
		inst, isJR, functionCode,
		ctrlPCSrc, ctrlPCWrite, ctrlInstRegWrite, ctrlASrc, ctrlBSrc, ctrlALUOp, ctrlRegDst, ctrlMemtoReg, ctrlRegWrite, ctrlPortWrite,
		regDstExe, regDstMem, rs, rt, ctrlRsSrc, ctrlRtSrc,
		ctrlGreater, ctrlEqual, ctrlLess,
		cacheStall);			

endmodule