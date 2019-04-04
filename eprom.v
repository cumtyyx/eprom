`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:30:15 03/19/2019 
// Design Name: 
// Module Name:    eprom 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module eprom(rst,clk,data,address,sda,ack,write_ctrl
    );
	input rst,clk,write_ctrl;
	input [7:0] data,address;
	inout sda;
	output ack;
	reg ack;
	reg [7:0] sdabuf;
	reg link_sda;
	reg finish_f;
	wire w_c;  //有寄存write_ctrl的上升沿的信号，为1则：开始写
	reg [3:0] state,next_state;
	reg [7:0] state1;
	
	assign sda =(link_sda)?sdabuf[7]:1'bz;
	
	assign w_c = write_ctrl;
		
	parameter
		idle = 4'b0000,  //方便state1也使用此状态，不与bit7状态数重合，设置为0.
		write_address = 4'b0010,
		write_data = 4'b0100,
		stop = 4'b1000;
	parameter
		bit0 = 8'b0000_0001,
		bit1 = 8'b0000_0010,
		bit2 = 8'b0000_0100,
		bit3 = 8'b0000_1000,
		bit4 = 8'b0001_0000,
		bit5 = 8'b0010_0000,
		bit6 = 8'b0100_0000,
		bit7 = 8'b1000_0000;
		
	always @(posedge clk or negedge rst)
		if(!rst)
			begin
				state <= idle;
			end
		else
			state <= next_state;
	always @ (*)
		begin
			casex(state)
				idle: next_state = (w_c == 1)? write_address: idle;
				write_address: next_state = (finish_f == 1)? write_data: write_address;
				write_data: next_state = (finish_f == 1)? stop: write_data;
				stop: next_state = idle;
			endcase
		end
	always @ (posedge clk or negedge rst)
		begin
			if(!rst)
				begin
					link_sda <= 0;
					finish_f <= 0;
					ack <= 0;
					state1 <= idle;
				end
			else
				begin   //每完成一次写入，即完成一次一下循环，需要20个周期。
						//分别为：idle 1个，write_address 8个，write_data 8个，stop 1个。
					casex(next_state)
						idle:
							begin
								ack <= 0;
								link_sda <= 0;
							end
						write_address:
							begin
								state1 <= idle;
								finish_f <= 0;
								sdabuf <= address;
								link_sda <= 1;
								shift8_out;
							end
						write_data:
							begin
								state1 <= idle;
								finish_f <= 0;
								sdabuf <= data;
								shift8_out;
							end
						stop:
							begin
								finish_f <= 0;
								link_sda <= 0;
								ack <= 1;
							end
					endcase
				end						
		end	
	
	
task shift8_out;
	begin
		casex(state1)
			idle:
				begin
					finish_f <= 0;
					state1 <= bit7;
				end
			bit7:
				begin
					sdabuf <= sdabuf << 1;
					state1 <= bit6;
				end
			bit6:
				begin
					sdabuf <= sdabuf << 1;
					state1 <= bit5;
				end
			bit5:
				begin
					sdabuf <= sdabuf << 1;
					state1 <= bit4;
				end
			bit4:
				begin
					sdabuf <= sdabuf << 1;
					state1 <= bit3;
				end
			bit3:
				begin
					sdabuf <= sdabuf << 1;
					state1 <= bit2;
				end
			bit2:
				begin
					sdabuf <= sdabuf << 1;
					state1 <= bit1;
				end	
			bit1:
				begin
					sdabuf <= sdabuf << 1;
					state1 <= bit0;
				end	
			bit0:
				begin
					finish_f <= 1;
				end		
		endcase
	end
endtask
	
endmodule
