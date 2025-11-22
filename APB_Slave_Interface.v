module APB_Slave_Interface(
       input PCLK,PRESET_n,PWRITE_i,PSEL_i,PENABLE_i,ss_i,receive_data_i,tip_i,
       input [2:0]PADDR_i,
       input [7:0]PWDATA_i,
       input [7:0]miso_data_i,
       output mstr_o,cpol_o,cpha_o,lsbfe_o,spiswai_o,
       output PREADY_o,PSLVERR_o,
		 output[1:0] spi_mode_o,
		 output reg send_data_o,spi_interrupt_request_o,
		 output reg [7:0] mosi_data_o,
       output [2:0]sppr_o,spr_o,
       output reg [7:0]PRDATA_o);

        //FSM State declaration of APB and SPI
        reg [1:0]apb_ps,apb_ns;//APB
        reg [1:0]spi_ps,spi_ns;//SPI

	//Declaration of Control / Status / Baud / Data registers
	
	reg [7:0]SPI_CR_1;//SPI control 1
	reg [7:0]SPI_CR_2;//SPI control 2
	reg [7:0]SPI_BR;//SPI BaudRate
	reg [7:0]SPI_SR;//SPI Status
	reg [7:0]SPI_DR;//SPI Data 

	//Declaration of Write and read enable signals

	wire wr_enb, rd_enb;
        
	//Declaration of Flags for interrupts and status
	
	//wire mstr,cpol,cpha,lsbfe,spiswai;
	wire spie_o,spe_o,sptie_o,ssoe_o;
	wire modfen;
	wire modf;
	wire spif,sptef;

        //Declaration of  Parameters for APB states and SPI modes
	
        //Parameters for APB states   

	parameter IDLE = 2'b00,
	          SETUP = 2'b01,
		  ENABLE = 2'b10;
	
	//Parameters for SPI states
         
	parameter spi_run = 2'b00,
	       	  spi_wait= 2'b01,
		     spi_stop= 2'b10;


        // Parameter for control register and baudRate register
	
	parameter cr2_mask = 8'b00011011,
		       br_mask = 8'b01110111;

      //APB state and next state block

	always@(posedge PCLK or negedge PRESET_n)
		begin
		   if(!PRESET_n)
			apb_ps<=IDLE;
		    else
			apb_ps<=apb_ns;
		end
	
	always@(*)
		begin
			case(apb_ps)
				IDLE: if(PSEL_i && (!PENABLE_i))
					   apb_ns<=SETUP;
				      else
					   apb_ns<=IDLE;
				SETUP:if(PSEL_i && (!PENABLE_i))
					    apb_ns<=SETUP;
				else if(PSEL_i && (PENABLE_i))
					    apb_ns<=ENABLE;
				     else
					    apb_ns<=IDLE;
				ENABLE:if(PSEL_i)
					     apb_ns<=SETUP;
				       else
					    apb_ns<=IDLE;
				default:apb_ns<=IDLE;
			endcase
		end

	 //SPI state and next state block

	always@(posedge PCLK or negedge PRESET_n)
		begin
			if(!PRESET_n)
				spi_ps<=spi_run;
			else
				spi_ps<=spi_ns;
		end
					       
	 always@(*)
		begin
		    case(spi_ps)
				spi_run:if(!spe_o)
					    spi_ns<=spi_wait;
				        else
					    spi_ns<=spi_run;
				spi_wait:if(spiswai_o)
					     spi_ns<=spi_stop;
				         else if (!spe_o)
					     spi_ns<=spi_wait;
				          else
					     spi_ns<=spi_run;
				spi_stop:if(!spiswai_o)
					     spi_ns<=spi_wait;
				          else
					      spi_ns<=spi_run;
				default:spi_ns<=spi_run;
		    endcase
		end


        // assignment of spi mode 
	
	assign spi_mode_o = spi_ps;

        //assignment of write and read enable
	
	assign rd_enb = ((!PWRITE_i) && (apb_ps == ENABLE))?1'b1:1'b0;
	assign wr_enb = ((PWRITE_i) && (apb_ps == ENABLE))?1'b1:1'b0;

	//assignment of PREADY 
	
	assign PREADY_o = (apb_ps == ENABLE)?1'b1:1'b0;

	//assignment of PREADY 

	assign PSLVERR_o = (apb_ps == ENABLE)?(~tip_i):1'b0;

       //assignment of SPI control register 1
	assign lsbfe_o = SPI_CR_1[0];
	assign ssoe_o = SPI_CR_1[1];
	assign cpha_o = SPI_CR_1[2];
	assign cpol_o = SPI_CR_1[3];
	assign mstr_o = SPI_CR_1[4];
	assign sptie_o = SPI_CR_1[5];
	assign spe_o = SPI_CR_1[6];
	assign spie_o = SPI_CR_1[7];
	
        //assignment of SPI control register 2
	
	assign modfen = SPI_CR_2[4];
	assign spiswai_o = SPI_CR_2[1];

        //assignment of SPI Baud Rate Register 

	assign spr_o = SPI_BR[2:0];
	assign sppr_o = SPI_BR[6:4];
	
	assign spif = (SPI_DR != 8'h00)?1'b1:1'b0;
	assign sptef = (SPI_DR == 8'h00)?1'b1:1'b0;

        //assignment of all flags
       
	 always@(*)
	    begin
		 if(!PRESET_n)
			 SPI_SR = 8'b0010_0000;
		 else
			 SPI_SR = {spif,1'b0,sptef,modf,4'b0};
	   end
	  
	
	and  flag(modf,!ss_i,mstr_o,modfen,!ssoe_o);

		// sequential block of SPI_CR 1

	always@(posedge PCLK or negedge PRESET_n)
		begin
		   if(!PRESET_n)
			 SPI_CR_1<=8'h04;
		    else
			begin
			   if(wr_enb)
			       begin
				  if(PADDR_i == 3'b000)
				       SPI_CR_1<=PWDATA_i;
				  else
				       SPI_CR_1<=SPI_CR_1;
			        end
			   //else
			       //  SPI_CR_1<=8'h04;
			end
		end

	// sequential block of SPI_CR 2

	always@(posedge PCLK or negedge PRESET_n)
		begin
		    if(!PRESET_n)
			   SPI_CR_2<=8'h00;
		   else
		   begin
		       if(wr_enb)
			      begin
			      if(PADDR_i == 3'b001)
				     SPI_CR_2<=(PWDATA_i & cr2_mask);
			      else
			        SPI_CR_2<=SPI_CR_2;
			      end
			 //  else
			 //   SPI_CR_2<=8'h00;
		   end
		end

	// sequential block of SPI_BR

	always@(posedge PCLK or negedge PRESET_n)
		begin
		    if(!PRESET_n)
			 SPI_BR<=8'h00;
		    else
			begin
			    if(wr_enb)
			       begin
				   if(PADDR_i == 3'b010)
				      SPI_BR<=(PWDATA_i & br_mask);
				   else
				      SPI_BR<=SPI_BR;
				end
			  //  else
			//	 SPI_BR<=8'h00;
			end
		end

	// sequential block of Send data 

	always@(posedge PCLK or negedge PRESET_n)
		begin
		   if(!PRESET_n)
			send_data_o<=1'b0;
		   else
		       begin
				 if((spi_mode_o == spi_run || spi_mode_o == spi_wait) && (SPI_DR == PWDATA_i) && (SPI_DR != miso_data_i))
					send_data_o<=1'b1;
				 else
					send_data_o<=1'b0;
			
			//   else
			//	 send_data_o<=1'b0;
			end
		end

	// sequential block of mosi data 

	always@(posedge PCLK or negedge PRESET_n)
		begin
		   if(!PRESET_n)
		      mosi_data_o<=8'b0;
		else
		    begin
		        if((spi_mode_o == spi_run || spi_mode_o == spi_wait) && (SPI_DR == PWDATA_i) && (SPI_DR != miso_data_i))
			     mosi_data_o<=SPI_DR;
			else
			     mosi_data_o<=mosi_data_o;
		     end
					
		end



		// sequential block of SPI_DR

	always@(posedge PCLK or negedge PRESET_n)
		begin
		  if(!PRESET_n)
		      SPI_DR<=8'h00;
		  else
		     begin
			 if(wr_enb)
			     begin
				 if(PADDR_i == 3'b101)
				     SPI_DR<=PWDATA_i;
				 else
				     SPI_DR<=SPI_DR;
			      end
			else
			   begin
			      if((spi_mode_o == spi_run || spi_mode_o == spi_wait) && (SPI_DR == PWDATA_i) && (SPI_DR != miso_data_i)) 
				     SPI_DR<=8'h00;
			      else
				begin
				    if((spi_mode_o == spi_run || spi_mode_o == spi_wait) && receive_data_i)
                                       SPI_DR<=miso_data_i;
			            else
    				       SPI_DR<=SPI_DR;
				end
                           end
		      end
		end



	//combinational block is for DRDATA

	always@(*)
	     begin
		 if(!rd_enb)
		     PRDATA_o = 8'b0;
		 else
		    begin
			case(PADDR_i)
			   3'd0:PRDATA_o = SPI_CR_1;
		       	   3'd1:PRDATA_o = SPI_CR_2;
 			   3'd2:PRDATA_o = SPI_BR;
			   3'd3:PRDATA_o = SPI_SR;
		           3'd4:PRDATA_o = 8'b0;
			   3'd5:PRDATA_o= SPI_DR;
			   3'd6:PRDATA_o= 8'b0;
			   3'd7:PRDATA_o = 8'b0;
			default:PRDATA_o = 8'b0;
		       endcase
		    end
		end
	
	// combinational block of spi_interrupt_request_o				
	
        always@(*)
	   begin
	      if((!spie_o) && (!sptie_o))
	         spi_interrupt_request_o<=1'b0;
	      else if((spie_o) && (!sptie_o)) 
                        begin
                        if(spif || modf)
	                spi_interrupt_request_o<=1'b1;
                         else
                         spi_interrupt_request_o<=1'b0;
                        end
	      else if((!spie_o) && (sptie_o))
	             spi_interrupt_request_o<=sptef;
	      else
                    begin 
                    if(spif || modf || sptef)
	            spi_interrupt_request_o<=1'b1;
                    else
                     spi_interrupt_request_o<=1'b0;
		    end
	   end
	   
             	 
	

endmodule	 
	  



