module tx_bps_module
(
    CLK, RSTn,
	 Count_Sig, 
	 BPS_CLK,clk_1MHz_TX
);
    input CLK;
	 input RSTn;
	 input Count_Sig;
	 output BPS_CLK; 
	 output clk_1MHz_TX;
	 /***************************/
	 reg [11:0]Count_BPS;
	 always @ ( posedge CLK or negedge RSTn )
	    if( !RSTn )
		     Count_BPS <= 12'd0;
		     //115200bps = 867
		     //1Mbps = 99
             //2Mbps = 49
		 else if( Count_BPS == 12'd99 )
		     Count_BPS <= 12'd0;
		 else if( Count_Sig )
		     Count_BPS <= Count_BPS + 1'b1;
		 else
		     Count_BPS <= 12'd0;
	 /********************************/
	 //115200bps = 434
	 //1Mbps = 50
	 //2Mbps = 25
    assign BPS_CLK = ( Count_BPS == 12'd50 ) ? 1'b1 : 1'b0;
    assign clk_1MHz_TX = ( Count_BPS > 12'd49 ) ? 1'b1 : 1'b0;
    /*********************************/
endmodule

