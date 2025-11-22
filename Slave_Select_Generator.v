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

	assign target_s = (BaudRateDivisor_i * 5'd16)/2;

	assign tip_o = ~ss_o;

               
        // This is the always block of slave select output to selecting the
	// the slave



	always@(posedge PCLK or negedge PRESET_n)
	   begin
		   if(!PRESET_n)
		       begin
		         ss_o<=1;
			 rcv_s<=0;
			count_s<=16'hFFFF;
                       end
		   else if((!spiswa_i) && (mstr_i == 1'b1) && ((spi_mode_i == RUN)||(spi_mode_i == WAIT)))
			begin
		            if(send_data_i)	
				   begin				  
			        	ss_o<=0;
			                count_s<=0;
	           			rcv_s<=rcv_s;
			            end			
			    else if(count_s<=(target_s-1)) 
				   begin
				          		 ss_o<=0;
                    			  		 count_s <= count_s + 1'b1;
						         if((count_s==(target_s-1)))
						            rcv_s<=1'b1;
						         else 
						             rcv_s<=0;						
				    end
      	                      						
		           else begin					     
			         ss_o<=1;
	              		 rcv_s<=0;
		        	 count_s<=16'hFFFF;
				 end	
		       end
		  else
		       	begin						     
				    ss_o<=1;
				      rcv_s<=0;
				      count_s<=16'hFFFF;
			end	
        								 	          	                	   
	               
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
