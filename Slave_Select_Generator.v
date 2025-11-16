module Slave_Select_Generator(
	input PCLK,PRESET_n,mstr_i,send_data_i,spiswa_i,
	input [1:0]spi_mode_i,
	input [11:0]BaudRateDivisor_i,
	output reg ss_o,receive_data_o,
	output tip_o);
  
      // Declare the parameter for run,wait,stop mode
        parameter RUN = 2'b00,
		  WAIT =2'b01,
		  STOP =2'b10;

       // Declare the internal signals wire and register data type
	reg [15:0]count_s;
	wire [15:0]target_s;
	reg rcv_s;

	assign target_s = BaudRateDivisor_i * 5'd16;

	assign tip_o = ~ss_o;

       // Generate the counter for we can reach the target and disconnect the
       // slave select

         always@(posedge PCLK or negedge PRESET_n)
	    begin
		 if(!PRESET_n)
			 count_s<=16'hffff;
		 else
	            begin
	                 if((!spiswa_i) && (mstr_i == 1'b1) && ((spi_mode_i == RUN)||(spi_mode_i == WAIT)))
	                      begin
	                         if(send_data_i==1'b1)
				 begin
		                      if(count_s==(target_s-1'b1))
				        count_s<=16'hffff;
			              else
  				        count_s<=count_s + 1'b1;
				  end
	                          else
			                count_s<=16'b0;
			          end
		              else
			        count_s<=16'hffff;
		               end
	               end



        // This is the always block of slave select output to selecting the
	// the slave



	always@(posedge PCLK or negedge PRESET_n)
	   begin
		   if(!PRESET_n)
		       begin
		           ss_o<=1;
                        end
		     else
			    if((!spiswa_i) && (mstr_i == 1'b1) && ((spi_mode_i == RUN)||(spi_mode_i == WAIT)))
				begin
					if(send_data_i==1'b0)					  
						ss_o<=1;			
					 else 
					     if(count_s<=(target_s-1))
					         ss_o<=0;					     
					     else					      
						   ss_o<=1;
					      
				  end
			              else		               
		                         ss_o<=1;
	                    	                	   
	       end	
          

	   //This is the always block for receive the data rcv   

         always@(posedge PCLK or negedge PRESET_n)
	   begin
		   if(!PRESET_n)
		       begin
		           rcv_s<=1;
                        end
		     else
			    if((!spiswa_i) && (mstr_i == 1'b1) && ((spi_mode_i == RUN)||(spi_mode_i == WAIT)))
				begin
					if(send_data_i==1'b0)					  
						rcv_s<=1;			
					 else 
					     if(count_s<=(target_s-1))
					         rcv_s<=0;					     
					     else					      
						  rcv_s<=1;
					      
				  end
			              else		               
		                         rcv_s<=1;
	                    	                	   
	       end	
          


       // This is the block of receive the data from rcv


        always@(posedge PCLK or negedge PRESET_n)
	   begin	
               if(!PRESET_n)
		       receive_data_o<=0;
	       else
		       receive_data_o<=rcv_s;
	   end


endmodule
