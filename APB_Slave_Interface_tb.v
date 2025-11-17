`timescale 1ns / 1ps
module APB_Slave_Interface_tb;

	// Inputs
	reg PCLK;
	reg PRESET_n;
	reg PWRITE_i;
	reg PSEL_i;
	reg PENABLE_i;
	reg ss_i;
	reg receive_data_i;
	reg tip_i;
	reg [2:0] PADDR_i;
	reg [7:0] PWDATA_i;
	reg [7:0] miso_data_i;

	// Outputs
	wire mstr_o;
	wire cpol_o;
	wire cpha_o;
	wire lsbfe_o;
	wire spiswai_o;
	wire PREADY_o;
	wire PSLVERR_o;
	wire [1:0] spi_mode_o;
	wire send_data_o;
	wire spi_interrupt_request_o;
	wire [7:0] mosi_data_o;
	wire [2:0] sppr_o;
	wire [2:0] spr_o;
	wire [7:0] PRDATA_o;

	// Instantiate the Unit Under Test (UUT)
	APB_Slave_Interface uut (
		.PCLK(PCLK), 
		.PRESET_n(PRESET_n), 
		.PWRITE_i(PWRITE_i), 
		.PSEL_i(PSEL_i), 
		.PENABLE_i(PENABLE_i), 
		.ss_i(ss_i), 
		.receive_data_i(receive_data_i), 
		.tip_i(tip_i), 
		.PADDR_i(PADDR_i), 
		.PWDATA_i(PWDATA_i), 
		.miso_data_i(miso_data_i), 
		.mstr_o(mstr_o), 
		.cpol_o(cpol_o), 
		.cpha_o(cpha_o), 
		.lsbfe_o(lsbfe_o), 
		.spiswai_o(spiswai_o), 
		.PREADY_o(PREADY_o), 
		.PSLVERR_o(PSLVERR_o), 
		.spi_mode_o(spi_mode_o), 
		.send_data_o(send_data_o), 
		.spi_interrupt_request_o(spi_interrupt_request_o), 
		.mosi_data_o(mosi_data_o), 
		.sppr_o(sppr_o), 
		.spr_o(spr_o), 
		.PRDATA_o(PRDATA_o)
	);


	// Initialize Inputs

           task initialize();
             begin
		PCLK = 0;
		PRESET_n = 0;
		PWRITE_i = 0;
		PSEL_i = 0;
		PENABLE_i = 0;
		ss_i = 1;
		receive_data_i = 0;
		tip_i = 0;
		PADDR_i = 0;
		PWDATA_i = 0;
		miso_data_i = 0;
	     end
           endtask

	 //clock generation 

	 always
           begin
	     #5 PCLK = 1'b0;
	     #5 PCLK = 1'b1;
          end 


	  //Task for reset 

	  task reset();
            begin
	      @(negedge PCLK);
	      PRESET_n = 1'b0;
	      @(negedge PCLK);
	      PRESET_n = 1'b1;
	     end
	   endtask

	   task spi_cr1_write();
	      begin
		  @(posedge PCLK);
		  PADDR_i = 3'b000;
		  PWRITE_i = 1'b1;
		  PSEL_i = 1'b1;
		  PENABLE_i = 1'b0;
		  PWDATA_i = 8'hFF;
		  @(posedge PCLK);
		  PENABLE_i = 1'b1;
		  @(posedge PCLK);
		  PENABLE_i = 1'b0;
		  PSEL_i = 1'b0;
	      end
	    endtask

	    task spi_cr1_read();
	      begin
		  @(posedge PCLK);
		  PADDR_i = 3'b000;
		  PWRITE_i = 1'b0;
		  PSEL_i = 1'b1;
		  PENABLE_i = 1'b0;
		  @(posedge PCLK);
		  PENABLE_i = 1'b1;
		  @(posedge PCLK);
		  PENABLE_i = 1'b0;
		   @(posedge PCLK);
		  PSEL_i = 1'b0;
	      end
	    endtask




	    task spi_cr2_write();
	      begin
		  @(posedge PCLK);
		  PADDR_i = 3'b001;
		  PWRITE_i = 1'b1;
		  PSEL_i = 1'b1;
		  PENABLE_i = 1'b0;
		  PWDATA_i = 8'hAA;
		  @(posedge PCLK);
		  PENABLE_i = 1'b1;
		  @(posedge PCLK);
		  PENABLE_i = 1'b0;
		  PSEL_i = 1'b0;
	      end
	    endtask


	    task spi_br_write();
	      begin
		  @(posedge PCLK);
		  PADDR_i = 3'b010;
		  PWRITE_i = 1'b1;
		  PSEL_i = 1'b1;
		  PENABLE_i = 1'b0;
		  PWDATA_i = 8'h01;
		  @(posedge PCLK);
		  PENABLE_i = 1'b1;
		  @(posedge PCLK);
		  PENABLE_i = 1'b0;
		  PSEL_i = 1'b0;
	      end
	    endtask


	    task spi_sr_read();
	      begin
		  @(posedge PCLK);
		  PADDR_i = 3'b011;
		  PWRITE_i = 1'b0;
		  PSEL_i = 1'b1;
		  PENABLE_i = 1'b0;
		  @(posedge PCLK);
		  PENABLE_i = 1'b1;
		  @(posedge PCLK);
		  PENABLE_i = 1'b0;
		   @(posedge PCLK);
		  PSEL_i = 1'b0;
	      end
	    endtask


	    task spi_dr_write();
	      begin
		  @(posedge PCLK);
		  PADDR_i = 3'b101;
		  PWRITE_i = 1'b1;
		  PSEL_i = 1'b1;
		  PENABLE_i = 1'b0;
		  PWDATA_i = 8'h55;
		  @(posedge PCLK);
		  PENABLE_i = 1'b1;
		  @(posedge PCLK);
		  PENABLE_i = 1'b0;
		  PSEL_i = 1'b0;
	      end
	    endtask



	    initial
	      begin
		 initialize;
		 reset;
		 spi_br_write;
		 spi_cr1_write;
		 spi_cr2_write;
		 spi_dr_write;
		 spi_cr1_read;
		 spi_sr_read;
	      end


	   initial
		#2000 $finish;

    
endmodule
