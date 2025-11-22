module SPI_Top_Block_tb;

	// Inputs
	reg PCLK;
	reg PRESET_n;
	reg PWRITE;
	reg PSEL;
	reg PENABLE;
	reg miso;
	reg [2:0] PADDR;
	reg [7:0] PWDATA;

	// Outputs
	wire ss;
	wire sclk;
	wire spi_interrupt_request;
	wire mosi;
	wire PREADY;
	wire PSLVERR;
	wire [7:0] PRDATA;

	// Instantiate the Unit Under Test (UUT)
	SPI_Top_Block uut (
		.PCLK(PCLK), 
		.PRESET_n(PRESET_n), 
		.PWRITE(PWRITE), 
		.PSEL(PSEL), 
		.PENABLE(PENABLE), 
		.miso(miso), 
		.PADDR(PADDR), 
		.PWDATA(PWDATA), 
		.ss(ss), 
		.sclk(sclk), 
		.spi_interrupt_request(spi_interrupt_request), 
		.mosi(mosi), 
		.PREADY(PREADY), 
		.PSLVERR(PSLVERR), 
		.PRDATA(PRDATA)
	);

         // Initialize Inputs


	task Initialize();
	begin
		PCLK = 0;
		PRESET_n = 0;
		PWRITE = 0;
		PSEL = 0;
		PENABLE = 0;
		miso = 0;
		PADDR = 0;
		PWDATA = 0;

	end
        endtask

	//Generate the clock 
        
	always
	begin
          #5 PCLK = 1'b0;
	  #5 PCLK = 1'b1;
        end

	// Task for reset 
	
	task reset();
	  begin
	    // @(negedge PCLK);
	     PRESET_n=1'b0;
	     @(negedge PCLK);
	     PRESET_n=1'b1;
	   end
        endtask

	 // task for writing the data 

	 task APB_Write(input [2:0]address, input [7:0] data);
            begin
		PSEL = 1'b1;
		PWRITE = 1'b1;
		PADDR = address;
		PWDATA = data;
		PENABLE = 1'b0;

		@(posedge PCLK);
		PENABLE = 1'b1;
                 wait(PREADY)
		@(posedge PCLK);
		PENABLE = 1'b0;
		//PSEL = 1'b0;
	    end
       endtask

       //task for reading the data

       task APB_Read(input [2:0]address);
            begin
		PSEL = 1'b1;
		PWRITE = 1'b0;
		PADDR = address;
		PENABLE = 1'b0;

		@(posedge PCLK);
		PENABLE = 1'b1;
                wait(PREADY)
		@(posedge PCLK);
		
		PENABLE = 1'b0;
		PSEL = 1'b0;
	    end
       endtask

     integer i;  

       task miso_en(input [7:0]value);
	       begin
		   miso = value[0];
		   @(negedge sclk);
		   for(i=1;i<8;i=i+1)
		   begin
			   miso=value[i];
			   @(negedge sclk);
	           end
		end
	endtask

     initial
	begin
         Initialize;
	 reset;
	 APB_Write(3'd0,8'b0101_0001);
	 APB_Write(3'd1,8'b0000_0000);
	 APB_Write(3'd2,8'b0000_0001);
	 APB_Write(3'd5,8'b1010_0100);
         miso_en(8'b0101_0101);
	 repeat(2)
	 @(posedge PCLK);
	 APB_Read(3'd5);


	 #200 $finish;

       end
endmodule

