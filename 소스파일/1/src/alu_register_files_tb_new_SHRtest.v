/* 
 [CSED311-2017]  
  ALU_registerfiles testbench				    
 Written by Saehoon Kim 
 */ 


`timescale 1ns/1ns
`include "opcodes.v"

`define PERIOD 100	

module alu_register_tb_new_SHRtest;

	reg [24:0] Passed;
	reg [24:0] Failed;	   
	
	reg [7:0] countOp; 
	reg [2:0] functionCode;	  
	reg [1:0] readReg1;
	reg [1:0] readReg2;	   
	reg [1:0] writeReg;		
	reg clk;					 
	
	wire [`WORD_SIZE-1:0] outputData;


	ALU_RegFiles UUT (
		.countOp(countOp),
		.functionCode(functionCode),		
		.readReg1(readReg1),
		.readReg2(readReg2),
		.writeReg(writeReg),
		.outputData(outputData));

	initial begin
		Passed = 0;
		Failed = 0;
		countOp = 0;  
		clk = 0;		  
		
		#(`PERIOD*50);
		$display("Passed = %0d, Failed = %0d", Passed, Failed);	
		$finish();
	end			   
	
	always #(`PERIOD/2) clk = ~clk;
						   		
		
	always @(posedge clk) begin
		countOp = countOp + 1;
		case (countOp)						 
			/*
				Your registers (4 16-bit registers) should be initialized by `16h0010
			*/
			8'd1: Test(countOp, 3'b000, 2'b00, 2'b01, 2'b10, 16'h0020);	// ADD $2, $0, $1
			8'd2: Test(countOp, 3'b000, 2'b10, 2'b00, 2'b10, 16'h0030);	// ADD $2, $2, $0
			8'd3: Test(countOp, 3'b000, 2'b10, 2'b00, 2'b10, 16'h0040);	// ADD $2, $2, $0 			
			8'd4: Test(countOp, 3'b000, 2'b10, 2'b01, 2'b11, 16'h0050);	// ADD $3, $2, $1	 						
			8'd5: Test(countOp, 3'b000, 2'b10, 2'b11, 2'b01, 16'h0090);	// ADD $1, $2, $3  
			
			8'd6: Test(countOp, 3'b101, 2'b00, 2'bx, 2'b00, 16'hfff0);		// TCP $0, $0
			8'd7: Test(countOp, 3'b101, 2'b01, 2'bx, 2'b01, 16'hff70);		// TCP $1. $1	
			8'd8: Test(countOp, 3'b001, 2'b00, 2'b01, 2'b10, 16'h0080);	// SUB $2, $0, $1		
			8'd9: Test(countOp, 3'b001, 2'b10, 2'b01, 2'b10, 16'h0110);	// SUB $2, $2, $1
			8'd10: Test(countOp, 3'b100, 2'b10, 2'bx, 2'b10, 16'hfeef);	// NOT $2, $2  
			
			8'd11: Test(countOp, 3'b010, 2'b00, 2'b01, 2'b00, 16'hff70);	// AND $0, $0, $1					
			8'd12: Test(countOp, 3'b010, 2'b00, 2'b01, 2'b00, 16'hff70);  // AND $0, $0, $1
			8'd13: Test(countOp, 3'b110, 2'b00, 2'bx, 2'b00, 16'hfee0);	// SHL $0, $0
			8'd14: Test(countOp, 3'b101, 2'b00, 2'bx, 2'b11, 16'h0120);	// TCP $3, $0
			8'd15: Test(countOp, 3'b000, 2'b11, 2'b10, 2'b00, 16'h000f);	// ADD $0, $3, $2	 
			
			8'd16: Test(countOp, 3'b011, 2'b00, 2'b00, 2'b00, 16'h000f);	// ORR $0, $0, $0					
			8'd17: Test(countOp, 3'b011, 2'b11, 2'b11, 2'b11, 16'h0120); // ORR $3, $3, $3						
			8'd18: Test(countOp, 3'b100, 2'b00, 2'bx, 2'b00, 16'hfff0);	    // NOT $0, $0
			8'd19: Test(countOp, 3'b111, 2'b00, 2'bx, 2'b10, 16'hfff8);	  // SHR $2, $0
			8'd20: Test(countOp, 3'b111, 2'b10, 2'bx, 2'b00, 16'hfffc);	  // SHR $0, $2
			
			8'd21: Test(countOp, 3'b010, 2'b00, 2'b10, 2'b01, 16'hfff8);	 // AND $1, $0, $2					
			8'd22: Test(countOp, 3'b010, 2'b01, 2'b01, 2'b10, 16'hfff8);   // AND $2, $1, $1
			8'd23: Test(countOp, 3'b001, 2'b01, 2'b00, 2'b11, 16'hfffc);   // SUB $3, $1, $0
			8'd24: Test(countOp, 3'b101, 2'b11, 2'bx, 2'b00, 16'h0004);	 // TCP $0, $3
			8'd25: Test(countOp, 3'b000, 2'b11, 2'b00, 2'b01, 16'h0000); // SUB $1, $3, $0
		endcase
	end						
	

	task Test; 
		input [7:0] countOp_;
		input [2:0] functionCode_;	  
		input [1:0] readReg1_;
		input [1:0] readReg2_;	   
		input [1:0] writeReg_;		
		input [`WORD_SIZE-1:0] outputData_expected;  
		
		$display("#%d :", countOp_);
		countOp = countOp_;															 
		functionCode = functionCode_;
		readReg1 = readReg1_;
		readReg2 = readReg2_;
		writeReg = writeReg_;
		#10;
		if (outputData == outputData_expected)
			begin
				$display("PASSED");
				Passed = Passed + 1;
			end
		else
			begin
				$display("FAILED");
				$display("countOp = %d, outputData = %0h (Ans : %0h)", countOp_, outputData, outputData_expected);
				Failed = Failed + 1;
			end	
	endtask			   
	
						 
endmodule

   