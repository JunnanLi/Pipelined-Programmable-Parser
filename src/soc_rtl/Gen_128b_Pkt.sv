/*************************************************************/
//  Module name: Gen_128b_Pkt
//  Authority @ lijunnan (lijunnan@nudt.edu.cn)
//  Last edited time: 2024/07/03
//  Function outline: 512b PHV -> 128b Pkt
//  Noted: 
//    1) TAG_START_BIT, '1' is first slice  
//    1) TAG_TAIL_BIT,  '1' is last slice  
//    2) TAG_SHIFT_BIT, '1' is to shift;
//    3) TAG_VALID_BIT, '1' is valid
/*************************************************************/
import parser_pkg::*;

module Gen_128b_Pkt
#(
  parameter   PKT_NUM           = HEAD_WIDTH/128
)
(
  input   wire                  i_clk,
  input   wire                  i_rst_n,

  output  reg                   o_pkt_valid,
  output  reg   [133:0]         o_pkt,
  input   wire                  i_phv_valid,
  input   wire  [HEAD_WIDTH+TAG_WIDTH-1:0]  i_phv
);
  localparam PKT_NUM_WIDTH = $clog2(PKT_NUM);

  //====================================================================//
  //*   internal reg/wire/param declarations
  //====================================================================//
  reg   [1:0]                         r_cnt_pkt;
  //* fifo
  reg                                 r_rden_head;
  wire  [HEAD_WIDTH+TAG_WIDTH-1:0]    w_dout_head;
  reg   [HEAD_WIDTH+TAG_WIDTH-1:0]    q_dout_head;
  wire                                w_empty_head;
  reg   [3:0]                         r_cnt_head;
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//

  wire w_inc_cnt = i_phv_valid & i_phv[TAG_TAIL_BIT+HEAD_WIDTH];
  wire w_dec_cnt = r_rden_head & w_dout_head[TAG_START_BIT+HEAD_WIDTH];
  integer i;
  always @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
      r_rden_head       <= 1'b0;
      o_pkt_valid       <= 1'b0;
      r_cnt_pkt         <= '0;
      r_cnt_head        <= '0;
    end else begin
      r_rden_head       <= 1'b0;
      o_pkt_valid       <= 1'b0;
      r_cnt_pkt         <= 2'd1 + r_cnt_pkt;
      q_dout_head       <= r_rden_head? w_dout_head: q_dout_head;
      o_pkt[133:132]    <= (o_pkt_valid == 1'b0)? 2'b01: 
                            (r_cnt_pkt == 2'd3 && w_empty_head == 1'b1)? 2'b10: 2'b0;
      o_pkt[131:128]    <= 4'hf;
      //* start reading phv;
      if(|r_cnt_head & ~o_pkt_valid & ~r_rden_head) begin
        r_rden_head     <= 8'd1;
        r_cnt_pkt       <= 2'd0;
      end
      //* continue reading phv;
      else if(o_pkt_valid == 1'b1 && r_cnt_pkt == 2'd3 && w_empty_head == 1'b0) begin
        r_rden_head     <= 8'd1;
        r_cnt_pkt       <= 2'd0;
      end
      if(r_rden_head == 1'b1 || (r_cnt_pkt != 2'd0 && o_pkt_valid == 1'b1)) begin
        case(r_cnt_pkt)
          2'd0: o_pkt[127:0]  <= w_dout_head[128*3+:128];
          2'd1: o_pkt[127:0]  <= q_dout_head[128*2+:128];
          2'd2: o_pkt[127:0]  <= q_dout_head[128*1+:128];
          2'd3: o_pkt[127:0]  <= q_dout_head[128*0+:128]; 
        endcase
      end
      //* o_pkt_valid
      o_pkt_valid <= r_rden_head? 1'b1:
                      (r_cnt_pkt == 2'd0 && r_rden_head == 1'b0)? 1'b0: o_pkt_valid;

      case({w_dec_cnt, w_inc_cnt})
        2'b10: r_cnt_head     <= r_cnt_head - 'd1;
        2'b01: r_cnt_head     <= r_cnt_head + 'd1;
        default: r_cnt_head   <= r_cnt_head;
      endcase
    end
  end


  `ifdef XILINX_FIFO_RAM
    //* fifo used to buffer dma's pkt;
    fifo_512b_512 fifo_head (
      .clk              (i_clk                    ),  //* input wire clk
      .srst             (!i_rst_n                 ),  //* input wire srst
      .din              (i_phv                    ),  //* input wire [133 : 0] din
      .wr_en            (i_phv_valid              ),  //* input wire wr_en
      .rd_en            (r_rden_head              ),  //* input wire rd_en
      .dout             (w_dout_head              ),  //* output wire [133 : 0] dout
      .full             (                         ),  //* output wire full
      .empty            (w_empty_head             )   //* output wire empty
    );
  `elsif SIM_FIFO_RAM
    //* fifo used to buffer dma's pkt;
    syncfifo fifo_head (
      .clock            (i_clk                    ),  //* ASYNC WriteClk, SYNC use wrclk
      .aclr             (!i_rst_n                 ),  //* Reset the all signal
      .data             (i_phv                    ),  //* The Inport of data 
      .wrreq            (i_phv_valid              ),  //* active-high
      .rdreq            (r_rden_head              ),  //* active-high
      .q                (w_dout_head              ),  //* The output of data
      .empty            (w_empty_head             ),  //* Read domain empty
      .usedw            (                         ),  //* Usedword
      .full             (                         )   //* Full
    );
    defparam  fifo_head.width = HEAD_WIDTH+TAG_WIDTH,
              fifo_head.depth = 9,
              fifo_head.words = 512;
  `endif


            
endmodule