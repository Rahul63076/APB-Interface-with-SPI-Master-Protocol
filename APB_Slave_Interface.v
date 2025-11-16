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

        //FSM State declaration of APB and SPI
        reg [1:0]apb_ps,apb_ns;//APB
        reg [1:0]spi_ps,spi_ns;//SPI

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

	 
	  


endmodule
