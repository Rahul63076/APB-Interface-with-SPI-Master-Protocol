`define SPI_APB_DATA_WIDTH = 8 
`define SPI_REG_WIDTH = 8
`define SPI_APB_ADDR_WIDTH =3
module APB_Slave_Interface(
       input PCLK,PRESET_n,PWRITE_i,PSEL_i,PENABLE_i,ss_i,receive_data_i,tip_i,
       input [`SPI_APB_ADDR_WIDTH-1 :0]PADDR_i,
       input [`SPI_APB_DATA_WIDTH-1 :0]PWDATA_i,
       input [`SPI_REG_WIDTH-1 :0]miso_data_i,
       output mstr_o,cpol_o,cpha_o,lsbfe_o,spiswai_o,spi_interrupt_request_o,
       output PREADY_o,PSLVERR_o,send_data_o,mosi_data_o,spi_mode_o,
       output [`SPI_APB_ADDR_WIDTH-1 :0]sppr_o,spr_o,
       output [`SPI_APB_DATA_WIDTH-1 :0]PRDATA_o);

       

	//Declaration of Control / Status / Baud / Data registers
	
	reg [7:0]SPI_CR_1;//SPI control 1
	reg [7:0]SPI_CR_2;//SPI control 2
	reg [7:0]SPI_BR;//SPI BaudRate
	reg [7:0]SPI_SR;//SPI Status
	reg [7:0] SPI_DR;//SPI Data 

	//Declaration of Write and read enable signals

	wire wr_enb, rd_enb;
        
	//Declaration of Flags for interrupts and status
	
	//wire mstr,cpol,cpha,lsbfe,spiswai;
	wire spie,spe,sptie,ssoe_o;
	wire modfen;
	wire modf;
	reg spif,sptef;

	 //FSM State declaration of APB and SPI
        reg [1:0]apb_ps,apb_ns;//APB
        reg [1:0]spi_ps,spi_ns;//SPI
	
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

	always@(pasedge PCLK or negedge PRESET_n)
		begin
			if(PRESET_n)
				apb_ps<=IDLE;
			else
				apb_ps<=apb_ns;
		end
	
	always@(*)
		begin
			case(apb_ps)
				IDLE: if(PSEL && (!PENABLE_i))
					      apb_ns<=SETUP;
				      else
						  apb_ns<=IDLE;
				SETUP:if(PSEL && (!PENABLE_i))
					      apb_ns<=SETUP;
				else if(PSEL && (PENABLE_i))
					      apb_ns<=ENABLE;
				     else
						 apb_ns<=IDLE;
				ENABLE:if(PSEL)
					     apb_ns<=SETUP;
				       else
						 apb_ns<=IDLE;
				default:apb_ns<=IDLE;
			endcase
		end

	 //SPI state and next state block

	always@(pasedge PCLK or negedge PRESET_n)
		begin
			if(PRESET_n)
				spi_ps<=spi_run;
			else
				spi_ps<=spi_ns;
		end
					       
	 always@(*)
		begin
			case(spi_ps)
				spi_run:if(!spe)
					        spi_ns<=spi_wait;
				        else
							spi_ns<=spi_run;
				spi_wait:if(spiswai_o)
					        spi_ns<=spi_stop;
				         else if (!spe)
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


	assign SPI_SR = (!PRESET_n)?8'b0010_0000:{spif,1'b0,sptef,modf,4'b0};

	and  flag(modf,!ss_i,mstr_o,modfen,!ssoe_o);

	// sequential block of SPI_CR 1

	always@(pasedge PCLK or negedge PRESET_n)
		begin
			if(PRESET_n)
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
					else
						SPI_CR_1<=8'h04;
				end
		end

	// sequential block of SPI_CR 2

	always@(pasedge PCLK or negedge PRESET_n)
		begin
			if(PRESET_n)
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
					else
						SPI_CR_2<=8'h00;
				end
		end

	// sequential block of SPI_BR

	always@(pasedge PCLK or negedge PRESET_n)
		begin
			if(PRESET_n)
				SPI_BR<=8'h00;
			else
				begin
				  if(wr_enb)
					  begin
						  if(PADDR_i == 3'b010)
							  SPI_CR_2<=(PWDATA_i & br_mask);
						  else
							  SPI_BR<=SPI_BR;
					  end
					else
						SPI_BR<=8'h00;
				end
		end

	// sequential block of Send data 

	always@(pasedge PCLK or negedge PRESET_n)
		begin
			if(PRESET_n)
				send_data_o<=1'b0;
			else
				begin
				  if(wr_enb)
					  begin
						  if((spi_mode_o == spi_run || spi_mode_o == spi_wait) && (SPI_DR == PWDATA_i) && (SPI_DR != miso_data_i))
							  send_data_o<=1'b1;
						  else
							   send_data_o<=1'b0;
					  end
					else
						send_data_o<=1'b0;
				end
		end

	// sequential block of mosi data 

	always@(pasedge PCLK or negedge PRESET_n)
		begin
			if(PRESET_n)
				mosi_data_o<=8'b0;
			else
				begin
				   if((spi_mode_o == spi_run || spi_mode_o == spi_wait) && (SPI_DR == PWDATA_i) && (SPI_DR != miso_data_i))
							  mosi_data_o<=SPI_DR;
				   else
							   mosi_data_o<=mosi_data_o;
					  end
					
		end

	//combinational block is for DRDATA

	always@(*)
		begin
			if(!rd_enb)
				PRDATA = 8'b0;
			else
				begin
					case(PADDR)
						3'd0:PRDATA = SPI_CR_1;
						3'd1:PRDATA = SPI_CR_2;
						3'd2:PRDATA = SPI_BR;
						3'd3:PRDATA = SPI_SR;
						3'd4:PRDATA = 8'b0;
						3'd5:PRDATA = SPI_DR;
						3'd6:PRDATA = 8'b0;
						3'd7:PRDATA = 8'b0;
						default:PRDATA = 8'b0;
					endcase
				end
		end
	
						
				
	

endmodule
