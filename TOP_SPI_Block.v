module SPI_Top_Block(
  input PCLK,PRESET_n,PADDR_i,PWRITE_i,PSEL_i,PENABLE_i,miso_i,
  input [7:0]PWDATA_i,
  output ss_o,sclk_o,spi_interrupt_request_o,mosi_o,PREADY_o,PSLVERR_o,
  output [7:0]PRDATA_o);


  wire [1:0] spi_mode;
  wire [2:0] sppr,spr;
  wire [7:0] data_miso,mosi_data;
  wire [11:0] baudratedivisor;


  // Instantiate the Baud_Rate_Generator RTL module with named base
  
	Baud_Rate_Generator module_1(
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


  // Instantiate the Slave_Select_Generator RTL module with named base
  
	Slave_Select_Generator module_2(
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

  
  // Instantiate the SPI_Shifter RTL module with named base

  
	SPI_Shifter module_3(
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


  // Instantiate the APB_Slave_Interface RTL module with named base
  
	APB_Slave_Interface module_4(
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

