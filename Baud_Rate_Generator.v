module Baud_Rate_Generator(
	input PCLK,PRESET_n,spiswai_i,cpol_i,cpha_i,ss_i,
	input [2:0] sppr_i,spr_i,
	input [1:0] spi_mode_i,
	output reg miso_receive_sclk_o,miso_receive_sclk0_o,mosi_send_sclk_o,mosi_send_sclk0_o,
	output reg sclk_o,
	output [11:0] BaudRateDivisor_o);
          
      // Declare Internal Signals
        wire pre_sclk_s;
	reg [11:0]count_s;
      
      //Declare the mode of spi using parameter
      
       parameter RUN = 2'b00,
	         WAIT =2'b01,
		 STOP =2'b10;

