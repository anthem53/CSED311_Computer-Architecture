// Title         : vending_machine.v
// Author      : Jae-Eon Jo (Jojaeeon@postech.ac.kr) 
//					   Dongup Kwon (nankdu7@postech.ac.kr) (2015.03.30)

`include "vending_machine_def.v"

module vending_machine (

	clk,							// Clock signal
	reset_n,						// Reset signal (active-low)
	
	i_input_coin,				// coin is inserted.
	i_select_item,				// item is selected.
	i_trigger_return,			// change-return is triggered 
	
	o_available_item,			// Sign of the item availability
	o_output_item,			// Sign of the item withdrawal
	o_return_coin				// Sign of the coin return
);

	// Ports Declaration
	// Do not modify the module interface
	input clk;
	input reset_n;
	
	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0] i_select_item;
	input i_trigger_return;
		
	output [`kNumItems-1:0] o_available_item;
	output [`kNumItems-1:0] o_output_item;
	output [`kNumCoins-1:0] o_return_coin;
 
	// Normally, every output is register,
	//   so that it can provide stable value to the outside.
	reg [`kNumItems-1:0] o_available_item;
	reg [`kNumItems-1:0] o_output_item;
	reg [`kNumCoins-1:0] o_return_coin;
	
	// Net constant values (prefix kk & CamelCase)
	// Please refer the wikepedia webpate to know the CamelCase practive of writing.
	// http://en.wikipedia.org/wiki/CamelCase
	// Do not modify the values.
	wire [31:0] kkItemPrice [`kNumItems-1:0];	// Price of each item
	wire [31:0] kkCoinValue [`kNumCoins-1:0];	// Value of each coin
	assign kkItemPrice[0] = 400;
	assign kkItemPrice[1] = 500;
	assign kkItemPrice[2] = 1000;
	assign kkItemPrice[3] = 2000;
	assign kkCoinValue[0] = 100;
	assign kkCoinValue[1] = 500;
	assign kkCoinValue[2] = 1000;


	// NOTE: integer will never be used other than special usages.
	// Only used for loop iteration.
	// You may add more integer variables for loop iteration.
	integer i, j, k;

	// Internal states. You may add your own net & reg variables.
	reg [`kTotalBits-1:0] current_total;
	reg [`kItemBits-1:0] num_items [`kNumItems-1:0];
	reg [`kCoinBits-1:0] num_coins [`kNumCoins-1:0];
	
	// Next internal states. You may add your own net and reg variables.
	reg [`kTotalBits-1:0] current_total_nxt;
	reg [`kItemBits-1:0] num_items_nxt [`kNumItems-1:0];
	reg [`kCoinBits-1:0] num_coins_nxt [`kNumCoins-1:0];
	
	// Variables. You may add more your own registers.
	reg [`kTotalBits-1:0] input_total, output_total, return_total;
	
	reg [`kTotalBits-1:0] counter, counter_next;

	
	
	// Combinational logic for the next states
	always @(*) begin
		// TODO: current_total_nxt
		// You don't have to worry about concurrent activations in each input vector (or array).
		if (i_input_coin[0]) input_total = kkCoinValue[0];
		else if (i_input_coin[1]) input_total = kkCoinValue[1];
		else if (i_input_coin[2]) input_total = kkCoinValue[2];
		else input_total = 0;
		
		// You don't have to worry about concurrent activations in each input vector (or array).
		if (o_output_item[0]) output_total = kkItemPrice[0];	
		else if (o_output_item[1]) output_total = kkItemPrice[1];
		else if (o_output_item[2]) output_total = kkItemPrice[2];
		else if (o_output_item[3]) output_total = kkItemPrice[3];
		else output_total = 0;
		
		// You don't have to worry about concurrent activations in each input vector (or array).
		if (o_return_coin[0]) return_total = kkCoinValue[0];	
		else if (o_return_coin[1]) return_total = kkCoinValue[1];
		else if (o_return_coin[2]) return_total = kkCoinValue[2];
		else return_total = 0;
		
		// Calculate the next current_total state.
		current_total_nxt = current_total + input_total - output_total - return_total;
																	   
		// TODO: num_items_nxt   WHY IS THIS HERE???
		for (i = 0; i < `kNumItems; i = i+1) begin
			num_items_nxt[i] = num_items[i] - o_output_item[i];	
		end
		
		// TODO: num_coins_nxt	 WHY IS THIS TOO HERE???
		for (i = 0; i < `kNumCoins; i = i+1) begin
			num_coins_nxt[i] = num_coins[i] - o_return_coin[i] + i_input_coin[i];
		end
		
		// You may add more next states.
		if({i_input_coin, i_select_item} == 0)
			counter_next = counter + 1;
		else
			counter_next = 0;
		if(counter > 10)
			counter_next = 0;
			
		if(i_trigger_return == 1)
			counter_next = 11;
	end

	
	
	// Combinational logic for the outputs
	always @(*) begin
		// TODO: o_available_item
		for (i=0; i<`kNumItems; i=i+1) begin
			if (current_total >= kkItemPrice[i]) begin
				o_available_item[i] = 1'b1;
			end
			else begin
				o_available_item[i] = 1'b0;
			end
		end

		// TODO: o_output_item
		for (i=0; i<`kNumItems; i=i+1) begin
			if (o_available_item[i] && i_select_item[i]) begin
				o_output_item[i] = 1'b1;
			end
			else begin
				o_output_item[i] = 1'b0;
			end
		end

		// TODO: o_return_coin
		if(counter > 10) begin
			if(current_total >= kkCoinValue[2])
				o_return_coin = 3'b100;	 	
			else if(current_total >= kkCoinValue[1] && kkCoinValue[2] > current_total)
				o_return_coin = 3'b010;
			else if(current_total >= kkCoinValue[0] && kkCoinValue[1] > current_total)
				o_return_coin = 3'b001;
			else
				o_return_coin = 3'b000;   
																	
		end
		else
			o_return_coin = 3'b000;
			
	end
 
	
	
	// Sequential circuit to reset or update the states
	always @(posedge clk) begin
		
		if (!reset_n) begin
			// TODO: reset all states.
			current_total <= `kTotalBits'd0;
			for (j=0; j<`kNumItems; j=j+1) begin
				num_items[j] <= `kItemBits'd50;
			end
			for (k=0; k<`kNumCoins; k=k+1) begin
				num_coins[k] <= `kCoinBits'd50;
			end
		end
		else begin
			// TODO: update all states
				
			counter <= counter_next;
				
			current_total <= current_total_nxt;
			//$monitor("vm : %d", current_total);
			
			for (j=0; j<`kNumItems; j=j+1) begin
				num_items[j] <= num_items_nxt[j];
			end
			
			for (k=0; k<`kNumCoins; k=k+1) begin
				num_coins[k] <= num_coins_nxt[k];
			end			
		end
	end
	
	
	initial begin
		counter = 0;
	end

endmodule