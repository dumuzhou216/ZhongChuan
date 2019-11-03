`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/30 02:35:54
// Design Name: 
// Module Name: tx_logic
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tx_logic( M_AXIS_Clk, M_AXIS_nRst, 
    M_AXIS_tready, 
    M_AXIS_tvalid,
    M_AXIS_tdata,
    M_AXIS_tkeep,
    M_AXIS_tlast,
    TXD,
    LED,
    clk_1MHz_TX,
    readyFlag_TX,
    en_TX
    );
    
    input   M_AXIS_Clk;
    input   M_AXIS_nRst; 
    output  M_AXIS_tready; 
    input   M_AXIS_tvalid;
    input   M_AXIS_tdata;
    input   M_AXIS_tkeep;
    input   M_AXIS_tlast;
    output TXD;
    output LED;
    output clk_1MHz_TX;
    input readyFlag_TX;
    output en_TX;
  reg M_AXIS_tready;
  wire clk_100m;
  wire reset_n;
  wire [31:0] M_AXIS_tdata;
  wire M_AXIS_tvalid;
  wire [3:0] M_AXIS_tkeep;
  wire M_AXIS_tlast;

  reg [15:0] state;
  reg [15:0] cnt_tx;
  reg [7:0] tx_data;
  reg [31:0] tx_data_buf;
  reg send_sig;
  wire tx_done;
  wire TXD;
  wire clk_1MHz_TX;
  reg last;
  reg [3:0] keep;
  reg LED;
  wire en_TX;
  wire readyFlag_TX;

//LED[0] Show Send Last Done
//LED[1] Show Receive Last
//LED[3] Show Receive axi-fifo S_AXIS_tready ERROR

  always @ (posedge M_AXIS_Clk or negedge M_AXIS_nRst) begin
    if( !M_AXIS_nRst ) begin
      state         <=  16'd0;
      cnt_tx        <=  16'd0;
      M_AXIS_tready <=  1'b0;
      tx_data       <=  8'd0;
      tx_data_buf   <=  32'd0;
      keep          <=  4'b0;
      last          <=  1'b0;
      LED           <=  1'b1;
      send_sig      <=  1'b0;
    end
    else case(state)
      16'd0: begin 
        send_sig        <=  1'b0;
        state           <=  16'd1;
      end
      
      16'd1: if(tx_done & M_AXIS_tvalid) state <= 16'd2;
      
      16'd2: begin
        M_AXIS_tready   <=  1'b1;
        tx_data         <=  M_AXIS_tdata[7:0];
        tx_data_buf[31:0]     <=  M_AXIS_tdata[31:0];
        send_sig        <=  1'b1;
        last            <=  M_AXIS_tlast;
        keep            <=  M_AXIS_tkeep; 
        cnt_tx          <=  16'd0; 
        LED             <=  1'b0;
        state           <=  16'd3;
      end
      
      16'd3: begin
        M_AXIS_tready   <=  1'b0;
        send_sig        <=  1'b0;
        state           <=  16'd4;
      end
      
      16'd4: if( keep[1] == 1'b0 && last == 1'b1 ) state <= 16'd100; else if(tx_done) state <= 16'd5;
      
      16'd5: begin
        tx_data         <=  tx_data_buf[15:8];
        send_sig        <=  1'b1;
        state           <=  16'd6;
      end
      
      16'd6: begin
        send_sig        <=  1'b0;
        state           <=  16'd7;
      end
      
      16'd7: if( keep[2] == 1'b0 && last == 1'b1 ) state <= 16'd100; else if(tx_done) state <= 16'd8;
      
      16'd8: begin
        tx_data         <=  tx_data_buf[23:16];
        send_sig        <=  1'b1;
        state           <=  16'd9;
      end
      
      16'd9: begin
        send_sig        <=  1'b0;
        state           <=  16'd10;
      end
      
      16'd10: if( keep[3] == 1'b0 && last == 1'b1 ) state <= 16'd100; else if(tx_done) state <= 16'd11;
      
      16'd11: begin
        tx_data         <=  tx_data_buf[31:24];
        send_sig        <=  1'b1;
        state           <=  16'd0;
      end

      16'd100: if( cnt_tx < 16'd2000) cnt_tx <= cnt_tx + 1'b1; else state <= 16'd101;

      16'd101: begin
        LED <= 1'b1;
        if( M_AXIS_tlast == 1'b0 && M_AXIS_tvalid == 1'b1) state <=16'd102;
      end
      
     16'd102: begin
        state <= 16'd2;
      end
      
      default: begin
        tx_data         <=  8'hEE;
        send_sig        <=  1'b1;
      end
    endcase
  end

  tx_module U1
  (
    .CLK(M_AXIS_Clk),
    .RSTn(M_AXIS_nRst),
	.TX_Data(tx_data), 
	.Send_Sig(send_sig),
	.TX_Done_Sig(tx_done),
	.TX_Pin_Out(TXD),
	.clk_1MHz_TX(clk_1MHz_TX),
	.readyFlag_TX(readyFlag_TX),
	.en_TX(en_TX)
  );
 
endmodule
