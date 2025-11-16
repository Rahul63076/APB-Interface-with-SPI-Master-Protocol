`timescale 1ns / 1ps

module SPI_Shifter_tb;

	// Inputs ports
	reg PCLK;
	reg PRESET_n;
	reg ss_i;
	reg send_data_i;
	reg lsbfe_i;
	reg cpol_i;
	reg cpha_i;
	reg receive_data_i;
	reg miso_i;
	reg miso_receive_sclk_o;
	reg mosi_send_sclk_o;
	reg miso_receive_sclk0_o;
	reg mosi_send_sclk0_o;
	reg [7:0] data_mosi_i;

	// Outputs ports
	wire mosi_o;
	wire [7:0] data_miso_o;

	// Instantiate the Unit Under Test (UUT)
	SPI_Shifter uut (
		.PCLK(PCLK), 
		.PRESET_n(PRESET_n), 
		.ss_i(ss_i), 
		.send_data_i(send_data_i), 
		.lsbfe_i(lsbfe_i), 
		.cpol_i(cpol_i), 
		.cpha_i(cpha_i), 
		.receive_data_i(receive_data_i), 
		.miso_i(miso_i), 
		.miso_receive_sclk_o(miso_receive_sclk_o), 
		.mosi_send_sclk_o(mosi_send_sclk_o), 
		.miso_receive_sclk0_o(miso_receive_sclk0_o), 
		.mosi_send_sclk0_o(mosi_send_sclk0_o), 
		.data_mosi_i(data_mosi_i), 
		.mosi_o(mosi_o), 
		.data_miso_o(data_miso_o)
	);

	//Generate the clock of time period of 10

	initial
	begin
            PCLK = 1'b0;
	    forever
	    #5 PCLK = ~PCLK;
          end 

        // Task for reset 
	
	task reset();
		begin
		    PRESET_n=1'b0;
		    #20;
		    PRESET_n=1'b1;
	    end
         endtask

        // task for initialization 
	task Initialize();
		begin
		ss_i = 1;
		send_data_i = 0;
		receive_data_i = 0;
		miso_receive_sclk_o = 0;
		mosi_send_sclk_o = 0;
		miso_receive_sclk0_o = 0;
		mosi_send_sclk0_o = 0;
		

	end
       endtask

       // task for sending the data 

       task send_data(input [7:0]spi_data, input lsb_first);
	  begin
		  send_data_i = 1;
		  data_mosi_i = spi_data;
		  lsbfe_i = lsb_first;
		  #10;
		  send_data_i=0;
          end
       endtask
   

	
       //task for stimulus for initialize the flags with input
       
       task stimulus(input i,input j,input k,input l,input m);
	  begin
	        ss_i = i;
		miso_receive_sclk_o = j;
		mosi_send_sclk_o = k;
		miso_receive_sclk0_o = l;
		mosi_send_sclk0_o = m;
		#150;
		ss_i = ~i;
		end
       endtask


       //call the all task in initial block

       initial
       begin
	    Initialize;
	    reset;
	    send_data(8'hA9,1);
	    miso_i=1;
	    cpol_i=0;
	    cpha_i=1;
            stimulus(0,0,0,1,1);
	    receive_data_i=1;
	    
           #500 $finish;
    end       
endmodule
