module tx_module
(
    CLK, RSTn,
	 TX_Data, Send_Sig,
	 TX_Done_Sig, TX_Pin_Out,BPS_CLK,en_TX,readyFlag_TX,clk_1MHz_TX
);
     input CLK;
	  input RSTn;
	  input [7:0]TX_Data;
	  input Send_Sig;
	  output TX_Done_Sig;
	  output TX_Pin_Out;
	  output BPS_CLK; 
	  output en_TX; 
	  input readyFlag_TX;
	  output clk_1MHz_TX;
	  /********************************/
	  wire BPS_CLK;
	  tx_bps_module U2
	  (
	      .CLK( CLK ),
			.RSTn( RSTn ),
			.Count_Sig( 1'b1 ),    // input - from U2
			.BPS_CLK( BPS_CLK ),
			.clk_1MHz_TX(clk_1MHz_TX)         // output - to U2
	  );
	  /*********************************/
	  tx_control_module U3
	  (
	      .CLK( CLK ),
			.RSTn( RSTn ),
			.Send_Sig( Send_Sig ),    // input - from top
			.TX_Data( TX_Data ),        // input - from top
			.BPS_CLK( BPS_CLK ),        // input - from U2
			.TX_Done_Sig( TX_Done_Sig ),  // output - to top
			.TX_Pin_Out( TX_Pin_Out ),
			.en_TX(en_TX),
			.readyFlag_TX(readyFlag_TX)     // output - to top
	  );
	  /***********************************/
endmodule

