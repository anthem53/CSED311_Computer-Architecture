`include "opcodes.v" 	   

module ControlUnit (Clk, Reset_N, d_readM, d_writeM, num_inst, is_halted,
inst, isJR, functionCode,
ctrlPCSrc, ctrlPCWrite, ctrlInstRegWrite, ctrlASrc, ctrlBSrc, ctrlALUOp, ctrlRegDst, ctrlMemtoReg, ctrlRegWrite, ctrlPortWrite,
regDstExe, regDstMem, rs, rt, ctrlRsSrc, ctrlRtSrc);
		
	input Clk;
	input Reset_N;
	output d_readM;
	output d_writeM;
	output reg [15:0] num_inst;
	output reg is_halted;

	input [15:0] inst;
	input isJR;					   
	input [5:0] functionCode;	 
	
	output [1:0] ctrlPCSrc;	   
	output ctrlPCWrite;
	output ctrlInstRegWrite;
	output [1:0] ctrlASrc;
	output [1:0] ctrlBSrc;
	output [1:0] ctrlALUOp;
	output [1:0] ctrlRegDst;
	output ctrlMemtoReg;
	output ctrlRegWrite;
	output ctrlPortWrite;
					   
	input [1:0] regDstExe;
	input [1:0] regDstMem;
	input [1:0] rs;
	input [1:0] rt;
	output [1:0] ctrlRsSrc;
	output [1:0] ctrlRtSrc;	  
	
	reg [1:0] ctrlASrc;
	reg [1:0] ctrlBSrc;
	reg [1:0] ctrlALUOpTemp;
	reg [1:0] ctrlRegDst;
	
	reg d_readMExe;
	reg d_writeMExe;
	reg ctrlMemtoRegExe;
	
	reg d_readM;
	reg d_writeM;
	reg ctrlMemtoReg;	
	
	reg ctrlRegWriteExe;
	reg ctrlPortWriteExe;
	reg instDoneExe;
	
	reg ctrlRegWriteMem;
	reg ctrlPortWriteMem;
	reg instDoneMem;		   
	
	reg ctrlRegWrite;
	reg ctrlPortWrite;
	reg instDone;	 
	
	reg JmpFlag;
	
	wire isStall;
	wire isFlush;
	
	assign ctrlPCSrc = (inst[15:12]==9||inst[15:12]==10 ? 2 : (inst[15:12]==15&&(inst[5:0]==25||inst[5:0]==26) ? 1 : 0));// 2: use from imm, 1 : use from rs, 0 : +1		
	assign ctrlALUOp = ctrlALUOpTemp;
	
	assign ctrlPCWrite = !isStall;
	assign ctrlInstRegWrite = !isStall;					 
	assign isStall = is_halted==1 ? 1 : (d_readMExe==1&&inst[15:12]!=9&&inst[15:12]!=10 ? 1 : 0);	
	assign isFlush = (isStall==1 || JmpFlag==1 ? 1 : 0);
	//use this to nullify ctrl  and jmpFlag
	//is_halted is not used as input for stall. its input is inputted to stall instead	
	
	assign ctrlRsSrc = (ctrlRegWriteExe==1&&rs==regDstExe ? 1 : (ctrlRegWriteMem==1&&rs==regDstMem ? 2 : 0));
	assign ctrlRtSrc = (ctrlRegWriteExe==1&&rt==regDstExe ? 1 : (ctrlRegWriteMem==1&&rt==regDstMem ? 2 : 0));
	
	always @ (posedge Clk) begin	   	  
		num_inst += instDone;
		ctrlRegWrite = ctrlRegWriteMem;
		ctrlPortWrite = ctrlPortWriteMem;
		instDone = instDoneMem;		
		
		ctrlRegWriteMem = ctrlRegWriteExe;
		ctrlPortWriteMem = ctrlPortWriteExe;
		instDoneMem = instDoneExe;			  
		
		d_readM = d_readMExe;
		d_writeM = d_writeMExe;
		ctrlMemtoReg = ctrlMemtoRegExe;
		
		if(isFlush == 1 || isStall==1) begin
			JmpFlag = 0;				
			instDoneExe = 0;
			ctrlRegWriteExe = 0;
			ctrlPortWriteExe = 0;
			d_readMExe = 0;
			d_writeMExe = 0;
			ctrlMemtoRegExe = 0;		
			ctrlASrc = 0;
			ctrlBSrc = 0;
			ctrlALUOpTemp = 0;
			ctrlRegDst = 0;	 
		end	
		else begin
			JmpFlag = (inst[15:12]==9 || inst[15:12]==10 || (inst[15:12]==15&&(inst[5:0]==25||inst[5:0]==26)) ? 1 : 0);				
			instDoneExe = 1;
			ctrlRegWriteExe = ((inst[15:12]==15 && (inst[5:0]<8 || inst[5:0]==26)) || (inst[15:12]<7) || (inst[15:12]==7) || (inst[15:12]==10) ? 1 : 0);
			ctrlPortWriteExe = (inst[15:12]==15 && inst[5:0]==28 ? 1 : 0);
			d_readMExe = inst[15:12]==7 ? 1 : 0;
			d_writeMExe = inst[15:12]==8 ? 1 : 0;
			ctrlMemtoRegExe = inst[15:12]==7 ? 0 : 1;		
			ctrlASrc = (inst[15:12]==10 || (inst[15:12]==15&&inst[5:0]==26)) ? 0 : (inst[15:12]==6 ? 2 : 1);
			ctrlBSrc = (inst[15:12]==15&&inst[5:0]<8) ? 0 : (inst[15:13]==2 || inst[15:12]==7 || inst[15:12]==8 ? 2 : 1);
			ctrlALUOpTemp = (inst[15:12]==15&&inst[5:0]<8 ? 2 : (inst[15:12]==5 ? 3 : 0));//plus minus func or
			ctrlRegDst = (inst[15:12]==15 ? (inst[5:0]<8 ? 1 : 2) : (inst[15:12]<9 ? 0 : 2));	
		end	  	
		
		if((inst[15:12]==15&&inst[5:0]==29 && !isStall && !isFlush)) begin
			is_halted = 1;						 
		end		
	end
	
	always @ (negedge Reset_N) begin
		is_halted = 1;
	end
	
	always @ (posedge Reset_N) begin	
		num_inst = 0;	
		is_halted = 0;
		
		JmpFlag = 1;				
		instDoneExe = 0;
		ctrlRegWriteExe = 0;
		ctrlPortWriteExe = 0;
		d_readMExe = 0;
		d_writeMExe = 0;
		ctrlMemtoRegExe = 0;		
		ctrlASrc = 0;
		ctrlBSrc = 0;
		ctrlALUOpTemp = 0;
		ctrlRegDst = 0;	 
			
		d_readM = 0;
		d_writeM = 0;
		ctrlMemtoReg = 0;
		
		ctrlRegWriteMem = 0;
		ctrlPortWriteMem = 0;
		instDoneMem = 0;			  
		
		ctrlRegWrite = 0;
		ctrlPortWrite = 0;
		instDone = 0;
	end
	
endmodule