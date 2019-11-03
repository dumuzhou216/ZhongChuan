module tx_control_module
(
    CLK, RSTn,
	Send_Sig, TX_Data, BPS_CLK, 
    TX_Done_Sig, TX_Pin_Out,en_TX,readyFlag_TX
);
     input CLK;
	 input RSTn; 
	 input Send_Sig;
	 input [7:0]TX_Data;
	 input BPS_CLK;
	 input readyFlag_TX;
	 output TX_Done_Sig;
	 output TX_Pin_Out;
	 output en_TX;
	 /********************************************************/
	 reg [7:0] i;
	 reg [7:0] TX_Buf;
	 reg [7:0] count;
	 reg [15:0]count_ready;
	 reg rTX;
	 reg isDone;
	 reg en;
	 always @ ( posedge CLK or negedge RSTn )
	    if( !RSTn )
		    begin
		        i 		<= 8'd100;
		        TX_Buf	<= 8'd0;
				rTX 	<= 1'b1;
				isDone 	<= 1'b1;
				count   <= 1'b0;
				count_ready <= 16'd0;
			end
		else 
		 case(i)
		        8'd100:
		          if( Send_Sig)
                          begin i <= 8'd101;TX_Buf <= TX_Data;isDone <= 1'b0; end
		        8'd101:if( BPS_CLK )begin
		      	       if(count_ready == 16'd1) begin i <= 8'd0; en <= 1'b1; end
		      	end
		      	8'd102:
                          if( Send_Sig)
                              begin i <= 8'd0;TX_Buf <= TX_Data;isDone <= 1'b0; end
		//      	8'd101:
		//      	begin i <= 8'd0;TX_Buf <= TX_Data;isDone <= 1'b0; end
			    8'd0 :
				if( BPS_CLK ) begin i <= i + 1'b1; rTX <= 1'b0;count <= count + 1'b1;end
				
				8'd1, 8'd2, 8'd3, 8'd4, 8'd5, 8'd6, 8'd7, 8'd8 :
				if( BPS_CLK ) begin i <= i + 1'b1; rTX <= TX_Buf[ i - 1 ]; end
				8'd9 :
				if( BPS_CLK ) 
				    begin if( count == 1638 ) 
				                 begin  i <= 8'd11; rTX <= 1'b1;count <= 1'b0;end
				                 else  
				                     begin  i <= 8'd10; rTX <= 1'b1;end
				      end
				8'd11, 8'd12, 8'd13, 8'd14:
				if( BPS_CLK )  begin i <= i + 1'b1;end      
				8'd15:
				if( BPS_CLK )  begin i <= 8'd100;isDone <= 1'b1;end  
				     
				8'd10 :
				begin i <= 8'd102; isDone <= 1'b1; end
//              ********************************
//				8'd10 :
//				if(count == 8'd203) 
//			 	   begin i <= 8'd102;end
//				     else
//				         begin i <= 8'd100;isDone <= 1'b1;end
//				8'd102, 8'd103, 8'd104, 8'd105, 8'd106, 8'd107, 8'd108:
//                if( BPS_CLK ) begin i <= i + 1'b1; rTX <= 0; end
//                8'd109 :
//                if( BPS_CLK ) begin i <= i + 1'b1; rTX <= 1;count   <= 1'b0; en <= 1'b1;end
//              ********************************
			endcase
			
always @ ( posedge BPS_CLK or negedge RSTn )
               if( !RSTn )
                   begin
                       en <= 1'b0;
                       count_ready   <= 16'd0;
                   end
                else
                begin
                	
                    if(readyFlag_TX)
                       begin
//                            if((count_ready == 16'd1) && Send_Sig)
//                            begin en <= 1'b1;count_ready  <=count_ready + 16'd1; end
//                            else
                            count_ready  <=count_ready + 16'd1;
                       end
                    else
                    begin
                        count_ready   <= 16'd0;
                    end

                    if(count_ready == 16'd16385)
                       begin  
                       	en <= 1'b0;  
                       	count_ready   <= 16'd0; 
                       end
                    else if(count_ready > 16'd16385)
                        count_ready   <= 16'd0;
                end
    /********************************************************/
	 assign TX_Pin_Out = rTX;
	 assign TX_Done_Sig = isDone;
	 assign en_TX = en;
//	 assign I=i;
//	 assign Count=count;
	 /*********************************************************/
endmodule


