module SPI_Shifter(
	input PCLK,PRESET_n,ss_i,send_data_i,lsbfe_i,cpol_i,cpha_i,receive_data_i,miso_i,
	input miso_receive_sclk_o,mosi_send_sclk_o,miso_receive_sclk0_o,mosi_send_sclk0_o,
        input [7:0]data_mosi_i,
        output reg mosi_o,
        output [7:0]data_miso_o);


        reg [7:0]shift_register;
	reg [7:0]temp_reg;
	reg [2:0] count,count1,count2,count3;


        // we can write the statement of temp_reg and the data_miso 
	
	assign data_miso_o = (receive_data_i)? temp_reg:8'h00;

	// write the logic for shift_register using asyncronous active low reset
	

	always@(posedge PCLK or negedge PRESET_n)
	   begin
		 if(!PRESET_n)
			 shift_register<=8'h00;
		 else if(send_data_i)
			 shift_register<=data_mosi_i;
		 else
			 shift_register<=shift_register;
	    end


	  //  write the logic for count2 or count3  internal register counter
	  //  and logic for temorary register
	            

	always@(posedge PCLK or negedge PRESET_n)
	   begin
 		if(!PRESET_n)
		  begin
	             temp_reg<=8'b0;
	             count2<=3'b000;
		     count3<=3'b111;
		  end
	        else
	           begin
	             if(!ss_i)
		      begin
			  if(((!cpha_i) && (cpol_i)) || ((cpha_i) && (!cpol_i))) 
			    begin
				if(lsbfe_i)
				begin
				  if(count2<=3'd7)
				     begin
					     if(miso_receive_sclk0_o)begin
						 temp_reg[count2]<=miso_i;
					         count2<=count2+1'b1;
				    end
			                 else
				           count2<=count2;		 
				     end
				  else
			           count2<=3'b000; 
				end
				else
				  begin
					  if(count3>=3'd0)
				     begin
					     if(miso_receive_sclk0_o)begin
						   temp_reg[count3]<=miso_i;				
					           count3<=count3-1'b1;
					   end
			                 else
				           count3<=count3;		 
				     end
				  else
			           count3<=3'b111; 
			           end
			    end
			  else
			    begin
				    if(lsbfe_i)
				begin
				  if(count2<=3'd7)
				     begin
					if(miso_receive_sclk_o)
					   begin
						 temp_reg[count2]<=miso_i;
					         count2<=count2+1'b1;
					    end
			                 else
				           count2<=count2;		 
				     end
				  else
			           count2<=3'b000; 
				end
				else
				  begin
					  if(count3>=3'd0)
				     begin
					if(miso_receive_sclk_o)
					   begin
						   temp_reg[count3]<=miso_i;				
					           count3<=count3-1'b1;
					   end
			                 else
				           count3<=count3;		 
				     end
				  else
			           count3<=3'b111; 
			           end

			    end  
			end

			else
			  begin
			   count2<=count2;
		           count3<=count3;
		           end
	               end		   
           end

	
	
          //  write the logic for count or count1  internal register counter
	  //  and logic for shift register
	            

	always@(posedge PCLK or negedge PRESET_n)
	   begin
 		if(!PRESET_n)
		  begin
		     mosi_o<=1'b0;
	             count<=3'b000;
		     count1<=3'b111;
		  end
	        else
	           begin
	             if(!ss_i)
		      begin
			  if(((!cpha_i) && (cpol_i)) || ((cpha_i) && (!cpol_i))) 
			    begin
				if(lsbfe_i)
				begin
				  if(count<=3'd7)
				     begin
					     if(mosi_send_sclk0_o)
					     begin
						mosi_o<=shift_register[count];
					        count<=count+1'b1;
					      end
			                 else
				           count<=count;		 
				     end
				  else
			           count<=3'b000; 
				end
				else
				  begin
					  if(count1>=3'd0)
				     begin
					if(mosi_send_sclk0_o)
					    begin
						mosi_o<=shift_register[count1];
					        count1<=count1-1'b1;
					      end
			                 else
				           count1<=count1;		 
				     end
				  else
			           count1<=3'b111; 
			           end
			    end
			  else
			    begin
				    if(lsbfe_i)
				begin
				  if(count<=3'd7)
				     begin
					if(mosi_send_sclk_o)
					    begin
						mosi_o<=shift_register[count];
					        count<=count+1'b1;
					      end
			                 else
				           count<=count;		 
				     end
				  else
			           count<=3'b000; 
				end
				else
				  begin
					  if(count1>=3'd0)
				     begin
					if(mosi_send_sclk_o)
					   begin
						mosi_o<=shift_register[count1];
					        count1<=count1-1'b1;
					      end
     					 else
				           count1<=count1;		 
				     end
				  else
			           count1<=3'b111; 
			           end

			    end  
			end

			else
			  begin
			   count<=count;
		           count1<=count1;
		           end
	               end		   
           end	
	
endmodule
