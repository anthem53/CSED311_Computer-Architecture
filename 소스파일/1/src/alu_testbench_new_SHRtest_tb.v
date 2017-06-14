/* 
 [CSED311-2017]  
  ALU testbench				   
 Modified version of last years' ALU testbenches
 Modified by Saehoon Kim
 Originally written by ...
 */ 

`include "ALU.v"
`timescale 100ps / 100ps

// Arithmetic operations
`define	FUNC_ADD	3'b000
`define	FUNC_SUB	3'b001
//  Bitwise Boolean operations
`define	FUNC_AND	3'b010
`define	FUNC_ORR	3'b011								    
`define	FUNC_NOT	3'b100
`define	FUNC_TCP	3'b101
// Shift operations
`define	FUNC_SHL	3'b110
`define	FUNC_SHR	3'b111	   

`define	NumBits	16	

module ALU_tb_new_SHRtest;

//Internal signals declarations:
reg [`NumBits-1:0]A;
reg [`NumBits-1:0]B;
reg [2:0]FuncCode;
wire [`NumBits-1:0]C;
wire OverflowFlag;

reg [25:0] Passed;
reg [25:0] Failed;

// Unit Under Test port map
// TODO : If your module and its pin have different name, you should change the mapping.
	ALU UUT (
		.A(A),
		.B(B),		
		.FuncCode(FuncCode),
		.C(C),
		.OverflowFlag(OverflowFlag));

initial begin
	Passed = 0;
	Failed = 0;
	
	ArithmeticTest;
	BitwiseBooleanTest;
	ShiftingTest;
	
	$display("Passed = %0d, Failed = %0d", Passed, Failed);	
	$finish;
end

task ArithmeticTest;
	AddTest;
	SubTest;
endtask					 

task BitwiseBooleanTest;
	AndTest;
	OrrTest;
	NotTest;
	TcpTest;	
endtask


task ShiftingTest;
	ShlTest;
	ShrTest;
endtask


task AddTest;
	FuncCode = `FUNC_ADD;
	
	Test("Add-1", 16'h0001, 16'h0001, 16'h0002, 0);
	Test("Add-2", 16'hffff, 16'h0001, 0, 0);		
	Test("Add-3", 16'h7fff, 16'h0005, 16'h8004, 1);			
	Test("Add-4", 16'h8000, 16'h8001, 16'h0001, 1);			
	Test("Add-5", 16'h0fff, 16'h0001, 16'h1000, 0);
	Test("Add-6", 16'h7fff, 16'h0001, 16'h8000, 1);			
endtask

task SubTest;
	FuncCode = `FUNC_SUB;

	Test("Sub-1", 0, 0, 0, 0);									 
	Test("Sub-2", 16'h0003, 16'h0001, 16'h0002, 0);
	Test("Sub-3", 16'hffff, 16'h8001, 16'h7ffe, 0);
	Test("Sub-4", 16'h7fff, 16'hffff, 16'h8000, 1);
	Test("Sub-5", 16'h0002, 16'h0003, 16'hffff, 0);
endtask		  

task AndTest;
	FuncCode = `FUNC_AND;

	Test("AND-1", 0, 0, 0, 0); 
	Test("AND-2", 16'hffff, 16'h0001, 16'h0001, 0);	
endtask


task OrrTest;
	FuncCode = `FUNC_ORR;

	Test("ORR-1", 0, 0, 0, 0); 
	Test("ORR-2", 16'hffff, 16'h0001, 16'hffff, 0);	
endtask			


task NotTest;
	FuncCode = `FUNC_NOT;

	Test("NOT-1", 16'hffff, 0, 16'h0000, 0); 
	Test("NOT-2", 16'h0800, 0, 16'hf7ff, 0);	
endtask

task TcpTest;
	FuncCode = `FUNC_TCP;

	Test("TCP-1", 16'hffff, 0, 16'h0001, 0); 
	Test("TCP-2", 16'h0800, 0, 16'hf800, 0);
	Test("TCP-3", 16'hf0f1, 0, 16'h0f0f, 0);	
endtask	   


task ShlTest;
	FuncCode = `FUNC_SHL;

	Test("SHL-1", 16'h0800, 0, 16'h1000, 0); 
	Test("SHL-2", 16'h8000, 0, 16'h0000, 0);	
endtask


task ShrTest;
	FuncCode = `FUNC_SHR;

	Test("SHR-1", 16'h0800, 0, 16'h0400, 0); 
	Test("SHR-2", 16'h8000, 0, 16'hc000, 0);
	Test("SHR-3", 16'hf001, 0, 16'hf800, 0);	
endtask


task Test; 
	input [16 * 8 : 0] Testname;
	input [`NumBits-1:0] A_;
	input [`NumBits-1:0] B_;	
	input [`NumBits-1:0] C_expected;
	input OF_expected;  
	$display("TEST %s :", Testname);
	A = A_;
	B = B_;	
	#1;
	if (C == C_expected && OverflowFlag == OF_expected)
		begin
			$display("PASSED");
			Passed = Passed + 1;
		end
	else
		begin
			$display("FAILED");
			$display("A = %0h, B = %0h, C = %0h (Ans : %0h), Cout = %0b (Ans : %0b)", A_, B_, C, C_expected, OverflowFlag, OF_expected);
			Failed = Failed + 1;
		end	
endtask

endmodule