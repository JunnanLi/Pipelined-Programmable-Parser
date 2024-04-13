/*************************************************************/
//  Module name: Gen_PHV_and_Conf_Parser
//  Authority @ lijunnan (lijunnan@nudt.edu.cn)
//  Last edited time: 2024/01/06
//  Function outline: 128b pkt -> 1024b PHV
//  Noted: 
//    1) TAG_START_BIT, '1' is first slice  
//    1) TAG_TAIL_BIT,  '1' is last slice  
//    2) TAG_SHIFT_BIT, '1' is to shift;
//    3) TAG_VALID_BIT, '1' is valid
/*************************************************************/

module Gen_PHV_and_Conf_Parser
#(
  parameter   PKT_NUM           = `HEAD_WIDTH/128
)
(
  input   wire                  i_clk,
  input   wire                  i_rst_n,

  input   wire                  i_pkt_valid,
  input   wire  [133:0]         i_pkt,
  output  reg                   o_pkt_valid,
  output  reg   [133:0]         o_pkt,
  input   wire  [7:0]           i_inport,
  output  reg                   o_phv_valid,
  output  reg   [`HEAD_WIDTH+`TAG_WIDTH-1:0]  o_phv,
  output  reg   [`META_WIDTH+`TAG_WIDTH-1:0]  o_meta,

  output  reg                   o_rule_wren,
  output  reg   [31:0]          o_rule_addr,
  output  reg   [31:0]          o_rule_wdata
);
  localparam PKT_NUM_WIDTH = $clog2(PKT_NUM);

  //====================================================================//
  //*   internal reg/wire/param declarations
  //====================================================================//
  reg   [7:0]                         r_cnt_pkt;
  reg                                 r_tag_conf;
  //* fifo
  reg   [`HEAD_WIDTH+`TAG_WIDTH-1:0]  r_din_head;
  reg                                 r_wren_head, r_rden_head;
  wire  [`HEAD_WIDTH+`TAG_WIDTH-1:0]  w_dout_head;
  wire  w_inc_cnt, w_dec_cnt;
  reg   [3:0]                         r_cnt_head;
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//

  integer i;
  always @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
      r_wren_head                       <= 1'b0;
      o_pkt_valid                       <= 1'b0;
      r_tag_conf                        <= 1'b0;
      r_cnt_pkt                         <= 4'b0;
    end else begin
      r_wren_head                       <= 1'b0;
      o_pkt_valid                       <= o_pkt_valid & i_pkt_valid;
      o_pkt                             <= i_pkt;
      if(i_pkt_valid == 1'b1 && i_pkt[133:132] == 2'b01) begin
        r_cnt_pkt                           <= 8'd1;
        r_din_head[`HEAD_WIDTH+:`TAG_WIDTH] <= {4'b1101,{`TAG_START_BIT{1'b1}}};
        r_din_head[`HEAD_WIDTH-1-:128]      <= i_pkt; 
        // r_din_head[8+:8]                    <= i_inport; 

        o_pkt_valid                         <= (i_pkt[31:16] == 16'h9006)? 1'b0: 1'b1;
      end
      else if(i_pkt_valid == 1'b1) begin
        r_cnt_pkt                           <= 8'd1 + r_cnt_pkt;
        for(i=0; i<PKT_NUM; i=i+1)
          if(i == r_cnt_pkt[PKT_NUM_WIDTH-1:0])
            r_din_head[`HEAD_WIDTH-128*i-1-:128] <= i_pkt[127:0];
        if(r_cnt_pkt[PKT_NUM_WIDTH-1:0] == 0)
          r_din_head[`HEAD_WIDTH+:`TAG_WIDTH]    <= {4'b1100,{`TAG_START_BIT{1'b1}}};
        if(r_cnt_pkt[PKT_NUM_WIDTH-1:0] == (PKT_NUM-1) || i_pkt[133:132] == 2'b10)
          r_wren_head                       <= 1'b1;
        if(i_pkt[133:132] == 2'b10)
          r_din_head[`TAG_TAIL_BIT+`HEAD_WIDTH]  <= 1'b1;
      end
      //* tag to conf parser rules;
      if(i_pkt_valid == 1'b1 && i_pkt[133:132] == 2'b01)
        r_tag_conf                      <= (i_pkt[31:16] == 16'h9006);
      else if(i_pkt_valid == 1'b0 || i_pkt[133:132] == 2'b10)
        r_tag_conf                      <= 1'b0;

      o_rule_wren                       <= 1'b0;
      if(i_pkt_valid == 1'b1 && r_tag_conf == 1'b1) begin
        o_rule_wren                     <= 1'b1;
        o_rule_addr                     <= i_pkt[16+:32];
        o_rule_wdata                    <= i_pkt[48+:32];
      end
    end
  end

  assign w_inc_cnt = r_wren_head & r_din_head[`TAG_TAIL_BIT+`HEAD_WIDTH];
  assign w_dec_cnt = r_rden_head & w_dout_head[`TAG_START_BIT+`HEAD_WIDTH];
  always @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
      r_rden_head                       <= 1'b0;
      o_phv[`HEAD_WIDTH+:`TAG_WIDTH]    <= 'b0;
      o_meta[`META_WIDTH+:`TAG_WIDTH]   <= 'b0;
      o_phv_valid                       <= 'b1;
      r_cnt_head                        <= 'b0;
    end else begin
      o_phv_valid                       <= r_rden_head;
      o_phv                             <= (r_rden_head)? w_dout_head: 'b0;
      // o_meta                            <= 'b0;
      o_meta                            <= {48'h1111_1111_1111,48'h2222_2222_2222,32'h3333_3333,32'h4444_4444,
                                            16'h55,16'h66,{(`META_WIDTH-192){1'b0}}};
<<<<<<< HEAD
      if(r_rden_head == 1'b1 & w_dout_head[`HEAD_WIDTH+`TAG_START_BIT]) begin
=======
      if(r_rden_head & w_dout_head[`HEAD_WIDTH+`TAG_START_BIT]) begin
>>>>>>> three_stage_parser
        o_meta[`META_WIDTH+`TAG_VALID_BIT]      <= 1'b1;
        o_meta[`META_WIDTH+`TAG_SHIFT_BIT]      <= 1'b1;
        o_meta[`META_WIDTH+`TAG_START_BIT]      <= 1'b1;
        o_meta[`META_WIDTH+`TAG_TAIL_BIT]       <= 1'b1;
        o_meta[`META_WIDTH+:`META_SHIFT_WIDTH]  <= {`META_SHIFT_WIDTH{1'b0}};
      end
      case({w_dec_cnt, w_inc_cnt})
        2'b10: r_cnt_head               <= r_cnt_head - 'd1;
        2'b01: r_cnt_head               <= r_cnt_head + 'd1;
        default: r_cnt_head             <= r_cnt_head;
      endcase

      if(r_cnt_head != 'b0 && r_rden_head == 1'b0) begin
        r_rden_head                     <= 1'b1;
      end
      else if(r_rden_head == 1'b1 && w_dout_head[`HEAD_WIDTH+`TAG_TAIL_BIT] == 1'b1) begin
        r_rden_head                     <= 1'b0;
      end
    end
  end

  `ifdef XILINX_FIFO_RAM
    //* fifo used to buffer dma's pkt;
    fifo_512b_512 fifo_head (
      .clk              (i_clk                    ),  //* input wire clk
      .srst             (!i_rst_n                 ),  //* input wire srst
      .din              (r_din_head               ),  //* input wire [133 : 0] din
      .wr_en            (r_wren_head              ),  //* input wire wr_en
      .rd_en            (r_rden_head              ),  //* input wire rd_en
      .dout             (w_dout_head              ),  //* output wire [133 : 0] dout
      .full             (                         ),  //* output wire full
      .empty            (                         )   //* output wire empty
    );
  `elsif SIM_FIFO_RAM
    //* fifo used to buffer dma's pkt;
    syncfifo fifo_head (
      .clock            (i_clk                    ),  //* ASYNC WriteClk, SYNC use wrclk
      .aclr             (!i_rst_n                 ),  //* Reset the all signal
      .data             (r_din_head               ),  //* The Inport of data 
      .wrreq            (r_wren_head              ),  //* active-high
      .rdreq            (r_rden_head              ),  //* active-high
      .q                (w_dout_head              ),  //* The output of data
      .empty            (                         ),  //* Read domain empty
      .usedw            (                         ),  //* Usedword
      .full             (                         )   //* Full
    );
    defparam  fifo_head.width = `HEAD_WIDTH+`TAG_WIDTH,
              fifo_head.depth = 9,
              fifo_head.words = 512;
  `endif


            
endmodule