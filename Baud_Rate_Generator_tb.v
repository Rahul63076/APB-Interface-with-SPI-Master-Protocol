`timescale 1ns / 1ps

module Boud_Rate_Generator_tb();

	// Inputs Port declaration as a reg data type
	reg PCLK;
	reg PRESET_n;
	reg spiswai_i;
	reg cpol_i;
	reg cpha_i;
	reg ss_i;
	reg [2:0] sppr_i;
	reg [2:0] spr_i;
	reg [1:0] spi_mode_i;

	// Outputs ports declaration as a wire data type
	wire miso_receive_sclk_o;
	wire miso_receive_sclk0_o;
	wire mosi_send_sclk_o;
	wire mosi_send_sclk0_o;
	wire sclk_o;
	wire [11:0] BaudRateDivisor_o;

	// Instantiate the Unit Under Test (UUT) or RTL module with named base
	Baud_Rate_Generator uut (
		.PCLK(PCLK), 
		.PRESET_n(PRESET_n), 
		.spiswai_i(spiswai_i), 
		.cpol_i(cpol_i), 
		.cpha_i(cpha_i), 
		.ss_i(ss_i), 
		.sppr_i(sppr_i), 
		.spr_i(spr_i), 
		.spi_mode_i(spi_mode_i), 
		.miso_receive_sclk_o(miso_receive_sclk_o), 
		.miso_receive_sclk0_o(miso_receive_sclk0_o), 
		.mosi_send_sclk_o(mosi_send_sclk_o), 
		.mosi_send_sclk0_o(mosi_send_sclk0_o), 
		.sclk_o(sclk_o), 
		.BaudRateDivisor_o(BaudRateDivisor_o)
	);


        // Generate the PCLK system clock for data transfer
	
	always
	  begin
	     PCLK = 1'b0;
	     forever
	     #10 PCLK = ~PCLK;
	  end


	 //Write task for Initialize the inputs

	task Initialize();
	   begin
		spiswai_i = 0;
		cpol_i = 0;
		cpha_i = 0;
		ss_i = 1;
	    end
	endtask

        // Write task for PRESET to reset the all ports
	
        task Reset();
	  begin
	    PRESET_n = 1'b0;
            #20;
            PRESET_n = 1'b1;
          end
        endtask

       // Write task for stimulus to give the input

       task stimulus(input i,input j);
	  begin
             @(negedge PCLK);
	      cpol_i = i;
	      cpha_i = j;
	      ss_i = 1'b0;
      	      spi_mode_i = 2'b00;
	      sppr_i = 3'b000;
	      spr_i = 3'b010;
	  end
       endtask


       //Call all the task inside the initial block
        
       initial
	   begin
             Initialize;
	     Reset;
	     stimulus(0,0);
	     #500;
	     stimulus(0,1);
	     #1000 $finish;
           end  

       	
endmodule
