`include "opcodes.v" 

module Datapath (Clk, Reset_N, i_address, i_data, d_readM, d_writeM, d_address, d_data, output_port, 	   
inst, isJR,  functionCode, 
ctrlPCSrc, ctrlPCWrite, ctrlInstRegWrite, ctrlASrc, ctrlBSrc, ctrlALUOp, ctrlRegDst, ctrlMemtoReg, ctrlRegWrite, ctrlPortWrite,
regDstExe, regDstMem, rs, rt, ctrlRsSrc, ctrlRtSrc,
ctrlGreater,  ctrlLess, ctrlEqual	,
cacheStall);	

	input Clk;
	input Reset_N;
	output [15:0] i_address;
	inout [15:0] i_data;
	output [15:0] d_address;
	inout [15:0] d_data;
	output reg [15:0] output_port;

	output [15:0] inst;
	output isJR;
	output [5:0] functionCode;	 
	
	input [1:0] ctrlPCSrc;	   
	input ctrlPCWrite;
	input ctrlInstRegWrite;
	input [1:0] ctrlASrc;
	input [1:0] ctrlBSrc;
	input [1:0] ctrlALUOp;
	input [1:0] ctrlRegDst;
	input ctrlMemtoReg;
	input ctrlRegWrite;
	input ctrlPortWrite;
	
	
	output [1:0] regDstExe;
	output [1:0] regDstMem;
	output [1:0] rs;
	output [1:0] rt;
	input [1:0] ctrlRsSrc;
	input [1:0] ctrlRtSrc;		
	
	input d_readM;
	input d_writeM;
				   
	output ctrlGreater;
	output ctrlLess;
	output ctrlEqual;	  
	
	input cacheStall;
	
	/*	 *****************************************	*/
	
	
	/* start IF*/
	reg[15:0] PC;
	wire [15:0] nPC;			  /* Pc -> PC + 1*/
															  
	
	/* start ID before EX*/
	reg [15:0]inst_d;
	reg [15:0]PCplus1_d;
	wire [1:0] readReg1;
	wire [1:0] readReg2;
	wire [1:0] writeReg;
	wire [7:0] imme;
	wire [15:0] WriteData;
	wire [15:0] readData1;		 /* from register */
	wire [15:0] readData2;		 /* from register */
	wire [15:0] To_A;
	wire [15:0] To_B;			   
	wire [15:0] jPC;               /* jump instruction */
	wire [15:0] bPC;              /* branch instruction */
	wire [15:0] jrPC;              /* jmp regiser instrucion*/
	
	/* start EX before MEM*/
	reg [15:0]PCplus1_e;
	reg [15:0]A_e;
	reg [15:0]B_e;
	reg [7:0]imme_e;       /* Immediate number in I type */
	reg [1:0]rs_e;
	reg [1:0]rt_e;
	reg [1:0]rd_e;  
	wire [15:0] C;
	wire [15:0]  ALUwire1;
	wire [15:0]  ALUwire2;
	wire [1:0] WriteReg_e;
	
	
	/* start MEM before WB*/
	reg [15:0]ALUout_m;
	reg [15:0]B_m;
	reg [1:0]WR_m; 
	wire [15:0] Memout_m;
	wire [15:0] ALUoutwire_m;
	wire [15:0] To_WB_m;		  
	
	/* start WB*/
	reg [15:0]writedata_w;
	reg [1:0]WR_w;
	
	
	
	wire OverflowFlag;	  
	wire [2:0] realALUOp;
	
	
	
	/*assign part From IF to ID*/
	assign nPC =  ctrlPCSrc == 0 ? PC+1 : ( ctrlPCSrc == 1 ? jrPC : (ctrlPCSrc == 2 ? jPC : bPC )); 
	assign i_address = PC;				   
	
	
	assign isJR = ( (inst_d[15:12] == 9) || (inst_d[15:12] == 10) || ((inst_d[15:12] == 15 )&&(inst_d[5:0] == 25))  || ((inst_d[15:12] == 15 )&&(inst_d[5:0] == 26)) )? 1 : 0 ; // Not branch only jump; 
	assign inst = inst_d;					  
	assign functionCode = inst_d[5:0];	   
	
	/*assign part From ID to EX*/
	assign readReg1 = inst_d[11:10];
	assign rs = inst_d[11:10];
	assign rt = inst_d[9:8];
	assign readReg2 = inst_d[9:8];
	
	assign imme = inst_d[7:0];					    
	assign To_A = ctrlRsSrc == 0 ? readData1 : (ctrlRsSrc == 1 ? C : To_WB_m ); 
	assign To_B = ctrlRtSrc == 0 ? readData2 : (ctrlRtSrc == 1 ? C : To_WB_m ); 
	assign 	WriteReg_e =  ctrlRegDst == 2'b00 ? rt_e : ( ctrlRegDst == 2'b01 ? rd_e : 2);    /* All cover, R type, I type and JAL type*/  
	assign jPC =  {PCplus1_d[15:12],inst_d[11:0]};
	assign bPC =   PCplus1_d + {{8{inst_d[7]}}, imme}; 
	assign jrPC = 	To_A; 
	
	assign ctrlEqual = (To_A == To_B);
	assign ctrlLess = (To_A[15] == 1);
	assign ctrlGreater = (To_A[15] == 0 && To_A != 0);
	
	/*assign part From EX to MEM*/
	assign ALUwire1 = (ctrlASrc == 0) ?  PCplus1_e : ((ctrlASrc == 1) ? A_e : {imme_e,8'b00000000}  ); 
	assign ALUwire2 = (ctrlBSrc == 0) ? B_e: (ctrlBSrc == 1 ? 0 : { {8{imme_e[7]}}, imme_e });	/* guess zero is for LHI */
	assign regDstExe = WriteReg_e;
	assign regDstMem = WR_m;
	
	/*assign part From MEM to WB*/
	assign d_address =   ALUout_m;																					  															   
	reg [15:0] readDataTemp;		  
	assign readDataTemp = (d_readM==1 ? d_data : 16'hzzzz);
	assign d_data = (d_writeM==1 ? B_m : 16'hzzzz);
	
	
	/*assign part From WB*/
	assign To_WB_m = (ctrlMemtoReg == 0) ? readDataTemp :  ALUout_m;	 
	assign 	writeReg = WR_w;
	
	assign realALUOp = (ctrlALUOp==2 ? imme_e[2:0] : ctrlALUOp);
	
	RegisterFiles rf (ctrlRegWrite, readReg1, readReg2, writeReg, writedata_w, Clk, Reset_N, readData1, readData2);
	ALU alu ( ALUwire1, ALUwire2, realALUOp, C, OverflowFlag);		  
	
	
	initial begin	   												   
		PC = 0;	   
		output_port = 0;	 
		inst_d = 0;
		PCplus1_d = 0;	 
		
		PCplus1_e = 0;
		A_e = 0;
		B_e = 0;
		imme_e = 0;
		rs_e = 0;
		rt_e = 0;
		rd_e = 0;  
		
		ALUout_m = 0;
		B_m = 0;
		WR_m = 0; 	 
		
		writedata_w = 0;
		WR_w = 0;
	end					   
		
	always @(posedge Clk) begin	
		if(cacheStall != 1) begin 
			/* MEM -> WB stage*/	   
		   	if(ctrlPortWrite == 1) begin
				output_port = writedata_w; 	
			end
			writedata_w =  To_WB_m;
			WR_w = WR_m;	   
			
			/* EX -> MEM stage*/	
			WR_m = 	WriteReg_e;
			ALUout_m = C;
			B_m = B_e;	
			
			/* ID -> EX stage*/	
			PCplus1_e = PCplus1_d;
			A_e = To_A;
			B_e = To_B;	
			imme_e = imme;
			rs_e = 	 inst_d[11:10];
			rt_e = 	 inst_d[9:8];
			rd_e = 	 inst_d[7:6];  
			
			/* IF -> iD stage */	
			if (ctrlInstRegWrite == 1)  begin
				inst_d = i_data;	 
				PCplus1_d = PC + 1;
			end							   
			if(ctrlPCWrite == 1)  begin
				PC = nPC;
			end
		end

	end  // clock always		 
		
		always @(posedge Reset_N) begin
			PC = 0;	 
			output_port = 15'd0;	 
			inst_d = 0;
			PCplus1_d = 0;	  
		
			PCplus1_e = 0;
			A_e = 0;
			B_e = 0;
			imme_e = 0;
			rs_e = 0;
			rt_e = 0;
			rd_e = 0;  
			
			ALUout_m = 0;
			B_m = 0;
			WR_m = 0; 	 
			
			writedata_w = 0;
			WR_w = 0;
		end
	
	
endmodule				