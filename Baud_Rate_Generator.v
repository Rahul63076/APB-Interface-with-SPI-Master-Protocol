module Baud_Rate_Generator(
	input PCLK,PRESET_n,spiswai_i,cpol_i,cpha_i,ss_i,
	input [2:0] sppr_i,spr_i,
	input [1:0] spi_mode_i,
	output reg miso_receive_sclk_o,miso_receive_sclk0_o,mosi_send_sclk_o,mosi_send_sclk0_o,
	output reg sclk_o,
	output [11:0] BaudRateDivisor_o);
          
      // Declare Internal Signals
        wire pre_sclk_s;
	reg [11:0]count_s;
      
      //Declare the mode of spi using parameter
      
       parameter RUN = 2'b00,
	         WAIT =2'b01,
		 STOP =2'b10;
	
	//Compute Boud Rate Divisor Using assign statement and operator
	
	assign BaudRateDivisor_o = ((sppr_i + 1'b1)*(2**(spr_i+1'b1)));

      //Generate The Initial of SCLK Polarity using combinatinal assign
      //statement with conditional operator
        
      assign pre_sclk_s = cpol_i ? 1'b1:1'b0; 
	   
      //Generate SPI Clock (SCLK) using Sequential Block

         always@(posedge PCLK or negedge PRESET_n)
	 begin
		 if(!PRESET_n)
		   begin
	             count_s<=0;
	             sclk_o<=pre_sclk_s;
	           end
                 else if((ss_i == 1'b0) && (spiswai_i == 1'b0) && (spi_mode_i ==RUN) || (spi_mode_i == WAIT))
		     begin
			   if(count_s == ((BaudRateDivisor_o/2)-1'b1))
			   begin
				sclk_o<=~sclk_o;
				count_s<=0;
			   end	
			   else
				count_s<=count_s + 1'b1;
		      end
	          else
	            begin
	                sclk_o<=pre_sclk_s;
			count_s<=1'b0;
		    end
           end	

	 // Generate MISO receive signals clock using sclk at the posedge of PCLK in sequential always block
      
      always@(posedge PCLK or negedge PRESET_n)
      begin
	      if(!PRESET_n)
	      begin
		      miso_receive_sclk_o<=0;
		      miso_receive_sclk0_o<=0;
	      end
	      else
	         begin
		     if((!cpha_i && cpol_i) || (cpha_i && !cpol_i))
		       begin
		        if(sclk_o == 1'b1)
		         begin
		            if(count_s == ((BaudRateDivisor_o/2)-1'b1))
                                 miso_receive_sclk0_o<=1'b1;
			    else
				 miso_receive_sclk0_o<=1'b0;
		          end
		         else 
			         miso_receive_sclk0_o<=0;
		        end
		        else 
		         begin
	                    miso_receive_sclk0_o<=0;
                         end		    
                   

		    if((!cpha_i && !cpol_i) || (cpha_i && cpol_i))
		       begin
		          if(sclk_o == 1'b0)
		           begin
		            if(count_s == ((BaudRateDivisor_o/2)-1'b1))
                                 miso_receive_sclk_o<=1'b1;
			    else
				 miso_receive_sclk_o<=1'b0;
		           end
		             else 
			         miso_receive_sclk_o<=0;
		          end
	               else
			   begin
	                    miso_receive_sclk_o<=0;
                          end		
			
	          end
	        
        end

   
	 // Generate MOSI send signals clock using sclk at the posedge of PCLK in sequential always block
      
     always@(posedge PCLK or negedge PRESET_n)
      begin
	      if(!PRESET_n)
	      begin
		      mosi_send_sclk_o<=0;
		      mosi_send_sclk0_o<=0;
	      end
	      else
	         begin
		     if((!cpha_i && cpol_i) || (cpha_i && !cpol_i))
		       begin
		        if(sclk_o == 1'b1)
		         begin
		            if(count_s == ((BaudRateDivisor_o/2)-2'b10))
                                 mosi_send_sclk0_o<=1'b1;
			    else
				 mosi_send_sclk0_o<=1'b0;
		          end
		         else 
			         mosi_send_sclk0_o<=0;
		        end
		        else 
		         begin
	                    mosi_send_sclk0_o<=0;
                         end		    
                   

		    if((!cpha_i && !cpol_i) || (cpha_i && cpol_i))
		       begin
		          if(sclk_o == 1'b0)
		           begin
		            if(count_s == ((BaudRateDivisor_o/2)-2'b10))
                                 mosi_send_sclk_o<=1'b1;
			    else
				 mosi_send_sclk_o<=1'b0;
		           end
		             else 
			         mosi_send_sclk_o<=0;
		          end
	               else
			   begin
	                    mosi_send_sclk_o<=0;
                          end		
			
	          end
	        
        end

endmodule


	

