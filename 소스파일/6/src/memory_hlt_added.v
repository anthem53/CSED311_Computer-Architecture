`timescale 1ns/1ns
`define PERIOD1 100
`define MEMORY_SIZE 256	//	size of memory is 2^8 words (reduced size)
`define WORD_SIZE 16	//	instead of 2^16 words to reduce memory
			//	requirements in the Active-HDL simulator 

module Memory(clk, reset_n, i_readM, i_writeM, i_address, i_data, d_readM, d_writeM, d_address, d_data);
	input clk;
	wire clk;
	input reset_n;
	wire reset_n;
	
	// Instruction memory interface
	input i_readM;
	wire i_readM;
	input i_writeM;
	wire i_writeM;
	input [`WORD_SIZE-1:0] i_address;
	wire [`WORD_SIZE-1:0] i_address;
	inout i_data;
	wire [`WORD_SIZE-1:0] i_data;
	
	// Data memory interface
	input d_readM;
	wire d_readM;
	input d_writeM;
	wire d_writeM;
	input [`WORD_SIZE-1:0] d_address;
	wire [`WORD_SIZE-1:0] d_address;
	inout d_data;
	wire [`WORD_SIZE-1:0] d_data;
	
	reg [`WORD_SIZE-1:0] memory [0:`MEMORY_SIZE-1];
	reg [`WORD_SIZE-1:0] i_outputData;
	reg [`WORD_SIZE-1:0] d_outputData;
	
	assign i_data = i_readM?i_outputData:`WORD_SIZE'bz;
	assign d_data = d_readM?d_outputData:`WORD_SIZE'bz;
	
	always@(posedge clk)
		if(!reset_n)
			begin											  
				memory[16'h0] <= 16'h6000;
				memory[16'h1] <= 16'h6000;
				memory[16'h2] <= 16'hf01c;
				memory[16'h3] <= 16'h6100;
				memory[16'h4] <= 16'hf41c;
				memory[16'h5] <= 16'h6200;
				memory[16'h6] <= 16'hf81c;
				memory[16'h7] <= 16'h6300;
				memory[16'h8] <= 16'hfc1c;
				memory[16'h9] <= 16'h4401;
				memory[16'ha] <= 16'hf01c;
				memory[16'hb] <= 16'h4001;
				memory[16'hc] <= 16'hf01c;
				memory[16'hd] <= 16'h5901;
				memory[16'he] <= 16'hf41c;
				memory[16'hf] <= 16'h5502;	 				
				memory[16'h10] <= 16'hf41c;
				memory[16'h11] <= 16'h5503;
				memory[16'h12] <= 16'hf41c;
				memory[16'h13] <= 16'hf2c0;
				memory[16'h14] <= 16'hfc1c;
				memory[16'h15] <= 16'hf6c0;
				memory[16'h16] <= 16'hfc1c;
				memory[16'h17] <= 16'hf1c0;
				memory[16'h18] <= 16'hfc1c;
				memory[16'h19] <= 16'hf2c1;
				memory[16'h1a] <= 16'hfc1c;
				memory[16'h1b] <= 16'hf8c1;
				memory[16'h1c] <= 16'hfc1c;
				memory[16'h1d] <= 16'hf6c1;
				memory[16'h1e] <= 16'hfc1c;
				memory[16'h1f] <= 16'hf9c1;
				memory[16'h20] <= 16'hfc1c;
				memory[16'h21] <= 16'hf1c1;
				memory[16'h22] <= 16'hfc1c;
				memory[16'h23] <= 16'hf4c1;
				memory[16'h24] <= 16'hfc1c;
				memory[16'h25] <= 16'hf2c2;
				memory[16'h26] <= 16'hfc1c;
				memory[16'h27] <= 16'hf6c2;
				memory[16'h28] <= 16'hfc1c;
				memory[16'h29] <= 16'hf1c2;
				memory[16'h2a] <= 16'hfc1c;
				memory[16'h2b] <= 16'hf2c3;
				memory[16'h2c] <= 16'hfc1c;
				memory[16'h2d] <= 16'hf6c3;
				memory[16'h2e] <= 16'hfc1c;
				memory[16'h2f] <= 16'hf1c3;
				memory[16'h30] <= 16'hfc1c;
				memory[16'h31] <= 16'hf0c4;
				memory[16'h32] <= 16'hfc1c;
				memory[16'h33] <= 16'hf4c4;
				memory[16'h34] <= 16'hfc1c;
				memory[16'h35] <= 16'hf8c4;
				memory[16'h36] <= 16'hfc1c;
				memory[16'h37] <= 16'hf0c5;
				memory[16'h38] <= 16'hfc1c;
				memory[16'h39] <= 16'hf4c5;
				memory[16'h3a] <= 16'hfc1c;
				memory[16'h3b] <= 16'hf8c5;
				memory[16'h3c] <= 16'hfc1c;
				memory[16'h3d] <= 16'hf0c6;
				memory[16'h3e] <= 16'hfc1c;
				memory[16'h3f] <= 16'hf4c6;
				memory[16'h40] <= 16'hfc1c;
				memory[16'h41] <= 16'hf8c6;
				memory[16'h42] <= 16'hfc1c;
				memory[16'h43] <= 16'hf0c7;
				memory[16'h44] <= 16'hfc1c;
				memory[16'h45] <= 16'hf4c7;
				memory[16'h46] <= 16'hfc1c;
				memory[16'h47] <= 16'hf8c7;
				memory[16'h48] <= 16'hfc1c;
				memory[16'h49] <= 16'h785b;
				memory[16'h4a] <= 16'hf01c;
				memory[16'h4b] <= 16'h795c;
				memory[16'h4c] <= 16'hf41c;
				memory[16'h4d] <= 16'h895b;
				memory[16'h4e] <= 16'h885c;
				memory[16'h4f] <= 16'h785b;
				memory[16'h50] <= 16'hf01c;
				memory[16'h51] <= 16'h795c;
				memory[16'h52] <= 16'hf41c;	 	  
				memory[16'h53] <= 16'hf01d; // HLT
				memory[16'h54] <= 16'h6000;
				memory[16'h55] <= 16'h6000;
				memory[16'h56] <= 16'h6000;
				memory[16'h57] <= 16'h6000;
				memory[16'h58] <= 16'h6000;
				memory[16'h59] <= 16'h6000;
				memory[16'h5a] <= 16'h6000;
				memory[16'h5b] <= 16'h1;
				memory[16'h5c] <= 16'hffff;	 
						 				
			end
		else
			begin
				if(i_readM)i_outputData <= memory[i_address];
				if(i_writeM)memory[i_address] <= i_data;
				if(d_readM)d_outputData <= memory[d_address];
				if(d_writeM)memory[d_address] <= d_data;
			end
endmodule