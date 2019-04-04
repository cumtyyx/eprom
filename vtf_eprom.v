`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:54:20 03/20/2019
// Design Name:   eprom
// Module Name:   C:/myfpga/project/eprom/vtf_eprom.v
// Project Name:  eprom
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: eprom
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module vtf_eprom;

	// Inputs
	reg rst;
	reg clk;
	reg [7:0] data;
	reg [7:0] address;
	reg write_ctrl;

	// Outputs
	wire ack;

	// Bidirs
	wire sda;

	// Instantiate the Unit Under Test (UUT)
	eprom uut (
		.rst(rst), 
		.clk(clk), 
		.data(data), 
		.address(address), 
		.sda(sda), 
		.ack(ack), 
		.write_ctrl(write_ctrl)
	);

	initial 
		fork
			rst = 1;
			clk = 0;
			data = 0;
			address = 0;
			write_ctrl = 0;
			#50 write_ctrl = 1;
			#60 rst = 0;
			#120 rst = 1;
			#49500 write_ctrl = 0;
			#49800 $stop;
		join
		
	always #50 clk = ~clk;
	  
	always @ (posedge ack)
		begin
			data <= data + 1;
			address <= address + 1;
		end
		
endmodule

