`timescale 1ns / 1ps
module Slave_Select_generator_tb();

	// Inputs  ports as a reg type data type
	reg PCLK;
	reg PRESET_n;
	reg mstr_i;
	reg send_data_i;
	reg spiswa_i;
	reg [1:0] spi_mode_i;
	reg [11:0] BaudRateDivisor_i;

	// Outputs ports as a wire type data type

	wire ss_o;
	wire receive_data_o;
	wire tip_o;

	// Instantiate the Unit Under Test (UUT)
	Slave_Select_Generator uut (
		.PCLK(PCLK), 
		.PRESET_n(PRESET_n), 
		.mstr_i(mstr_i), 
		.send_data_i(send_data_i), 
		.spiswa_i(spiswa_i), 
		.spi_mode_i(spi_mode_i), 
		.BaudRateDivisor_i(BaudRateDivisor_i), 
		.ss_o(ss_o), 
		.receive_data_o(receive_data_o), 
		.tip_o(tip_o)
	);


	// clock generator block
             initial
	     begin 
	       PCLK = 1'b0;
	       forever
	       #5 PCLK = ~PCLK;
	     end

	     //Task for initialize the input
            task Initialize();
		 begin
	 	   mstr_i = 0;
		   send_data_i = 0;
		   spiswa_i = 1;
	    	   BaudRateDivisor_i = 0;
	        end
              endtask



	     // task for reset the module

	     task reset();
		begin
		  PRESET_n = 1'b0;
		  #20;
		  PRESET_n =1'b1;
 		end
	    endtask
 


            // Task for giving the value as a input
            task stimulus();
	     begin
	        @(negedge PCLK);
                  send_data_i=1'b1;
		  spiswa_i = 1'b0;
		  spi_mode_i=2'b00;
		  mstr_i = 1'b1;
	     end 
             endtask
                  		  


	       //calling the all task in the initial block


	      initial
	      begin
		  Initialize;
		  reset;
		  BaudRateDivisor_i = 4;
		  stimulus;
		  #800;
		  @(negedge PCLK);
		  send_data_i=0;
		  #1000 $finish;
	     end






	endmodule
