
/*
 *  Project:            Pipelined-Packet-Parser.
 *  Module name:        Testbench.
 *  Description:        Testbench of Pipelined-Packet-Parser.
 *  Last updated date:  2024.06.07.
 *
 *  Copyright (C) 2021-2024 Junnan Li <lijunnan@nudt.edu.cn>.
 *  Copyright and related rights are licensed under the MIT license.
 *
 */

  /*--------------------------------------------------------------------------------------*
   *  rule_addr (offset)   |  description                                                 *
   *--------------------------------------------------------------------------------------*
   * [10:8] is 0 |         | write rules; while i_rule_wdata[0] is valid info             *
   *--------------------------------------------------------------------------------------*
   * [10:8] is 1 |  [3:0]  | conf type data & type mask; while i_rule_addr[3:0] is type id*
   *--------------------------------------------------------------------------------------*
   * [10:8] is 2 |  [3:0]  | conf type offset                                             *
   *--------------------------------------------------------------------------------------*
   * [10:8] is 3 |  [5:0]  | conf key offset; while i_rule_addr[5:0] is keyField id;      *
   *             |         |     while i_rule_wdata[16] is valid info                     *
   *--------------------------------------------------------------------------------------*
   * [10:8] is 4 |         | conf head shift                                              *
   *--------------------------------------------------------------------------------------*
   * [10:8] is 5 |         | conf meta shift                                              *
   *--------------------------------------------------------------------------------------*/

`timescale 1ns/1ps
import parser_pkg::*;

module Testbench_wrapper(
);

`ifdef DUMP_FSDB
  initial begin
    $fsdbDumpfile("wave.fsdb");
    $fsdbDumpvars(0,"+all");
    $fsdbDumpMDA();
    $vcdpluson;
    $vcdplusmemon;
  end
`endif
  
  reg clk,rst_n;
  initial begin
    clk = 0;
    rst_n = 1;
    #2  rst_n = 0;
    #10 rst_n = 1;
    forever #1 clk = ~clk;
  end
  initial begin  
      #2000 $finish;
  end

  reg           r_rule_wren;
  reg   [31:0]  r_rule_addr;
  reg   [31:0]  r_rule_wdata;
  reg   [HEAD_WIDTH+TAG_WIDTH-1:0]   r_phv_in;
  wire  [HEAD_WIDTH+TAG_WIDTH-1:0]   w_phv_out;
  reg   [META_WIDTH+TAG_WIDTH-1:0]   r_meta_in;
  wire  [META_WIDTH+TAG_WIDTH-1:0]   w_meta_out;

  //* parser pkt;
  Parser_Top parser_top(
    .i_clk                (clk            ),
    .i_rst_n              (rst_n          ),

    //---conf--//
    .i_rule_wren          (r_rule_wren    ),
    .i_rule_rden          (1'b0           ),
    .i_rule_addr          (r_rule_addr    ),
    .i_rule_wdata         (r_rule_wdata   ),
    .o_rule_rdata_valid   (               ),
    .o_rule_rdata         (               ),

    //--data--//
    .i_head               (r_phv_in       ),
    .o_head               (w_phv_out      ),
    .i_meta               (r_meta_in      ),
    .o_meta               (w_meta_out     )
  );
  
  typedef enum logic [3:0] {IDLE_S, CONF_LAYER_0, CONF_LAYER_1, CONF_LAYER_2, CONF_LAYER_3, 
                            SEND_ARP_S, SEND_TCP_S, TAIL_S} state_t;
  state_t state_cur, state_pre;

  localparam NORMAL_ARP       = {48'h0001_0203_0405,48'h060708090a0b,16'h0806,16'h0001,
                                  128'h0800_0604_0001_0607_0809_0a0b_c0a8_eefa,
                                  48'h0001_0203_0405,48'h060708090a0b,16'h0806,16'h0001,
                                  128'h0};
  localparam NORMAL_TCP       = {128'h000a_3500_0102_00e0_4d6d_a7b3_0800_4500,
                                  128'h0028_e84b_4000_4006_ce61_c0a8_010a_c0a8,
                                  128'h01c8_1389_c001_3876_6005_0000_1986_5010,
                                  128'hfad8_843d_0000_3876_6005_0000_1986_5010};

  reg   [7:0]  r_cnt_ruleData;
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      r_rule_wren               <= 'b0;
      r_rule_addr               <= 'b0;
      r_rule_wdata              <= 'b0;
      r_phv_in                  <= 'b0;
      r_meta_in                 <= 'b0;
      r_cnt_ruleData            <= 'b0;
      state_cur                 <= IDLE_S;
      state_pre                 <= IDLE_S;
    end
    else begin
      r_rule_wren               <= 'b0;
      state_pre                 <= state_cur;
      r_cnt_ruleData            <= r_cnt_ruleData + 4'd1;
      case(state_cur)
        IDLE_S: begin
          case(state_pre)
            IDLE_S:             state_cur   <= CONF_LAYER_0;
            CONF_LAYER_0:       state_cur   <= CONF_LAYER_1;
            CONF_LAYER_1:       state_cur   <= CONF_LAYER_2;
            CONF_LAYER_2:       state_cur   <= SEND_ARP_S;
            SEND_ARP_S:         state_cur   <= SEND_TCP_S;
            // SEND_TCP_S:         state_cur   <= SEND_UDP_S;
            default:            state_cur   <= TAIL_S;
          endcase
          r_cnt_ruleData        <= 'b0;
        end
        CONF_LAYER_0: begin
          r_rule_wren           <= 1'b1;
          case(r_cnt_ruleData) 
            4'd0: begin
                  r_rule_wdata  <= 32'd12;      //* type offset + type id
                  r_rule_addr   <= {24'd2,8'd0}; 
            end
            4'd1: begin
                  r_rule_wdata  <= 32'd13;
                  r_rule_addr   <= {24'd2,8'd1}; 
            end
            4'd2,4'd3,4'd4,4'd5,4'd6,4'd7: begin
                  r_rule_wdata  <= {16'd1,12'b0,r_cnt_ruleData[3:0]-4'd2}; //* key offset + key id;
                  r_rule_addr   <= {24'd3, 4'b0,r_cnt_ruleData[3:0]-4'd2}; 
            end
            4'd8: begin
                  r_rule_wdata  <= 32'd0;       //* disable
                  r_rule_addr   <= {24'd3,8'd6}; 
            end
            4'd9: begin
                  r_rule_wdata  <= 32'd0;       //* disable
                  r_rule_addr   <= {24'd3,8'd7}; 
            end
            4'd10:begin
                  r_rule_wdata  <= 32'd7;       //* head shift
                  r_rule_addr   <= {16'd1,8'd4,8'b0}; 
            end
            4'd11: begin
                  r_rule_wdata  <= 32'd6;       //* meta shift
                  r_rule_addr   <= {16'd1,8'd5,8'b0}; 
                  state_cur     <= IDLE_S;
            end
          endcase
        end
        CONF_LAYER_1: begin
          r_rule_wren           <= 1'b1;
          case(r_cnt_ruleData) 
            4'd0: begin
                  r_rule_wdata  <= {16'h08,16'hff};     //* type + mask
                  r_rule_addr   <= {8'd1,16'd1,8'd0};   //* type id
            end
            4'd1: begin
                  r_rule_wdata  <= {16'h00,16'hff};
                  r_rule_addr   <= {8'd1,16'd1,8'd1}; 
            end
            4'd2: begin
                  r_rule_wdata  <= 32'd9;               //* type offset
                  r_rule_addr   <= {8'd1,16'd2,8'd0};   //* type id
            end
            4'd3: begin
                  r_rule_wdata  <= 32'd9;
                  r_rule_addr   <= {8'd1,16'd2,8'd1}; 
            end
            4'd4: begin
                  r_rule_wdata  <= {16'd1,16'd4};     //* key offset
                  r_rule_addr   <= {8'd1,16'd3,8'd0}; //* key id
            end
            4'd5,4'd6,4'd7,4'd8: begin
                  r_rule_wdata  <= {16'd1,12'b0,r_cnt_ruleData[3:0]+4'd1};      //* key offset
                  r_rule_addr   <= {8'd1,16'd3, 4'b0,r_cnt_ruleData[3:0]-4'd4}; //* key id
            end
            4'd9,4'd10,4'd11: begin
                  r_rule_wdata  <= 32'd0;       //* disable
                  r_rule_addr   <= {8'd1,16'd3,r_cnt_ruleData[3:0]-4'd4}; 
            end
            4'd12:begin
                  r_rule_wdata  <= 32'd10;       //* head shift
                  r_rule_addr   <= {8'd1,16'd4,8'b0}; 
            end
            4'd13: begin
                  r_rule_wdata  <= 32'd5;       //* meta shift
                  r_rule_addr   <= {8'd1,16'd5,8'b0}; 
            end
            4'd14: begin
                  r_rule_wdata  <= 32'd1;       //* enable/disable rule;
                  r_rule_addr   <= {8'd1,16'd0,8'd2}; 
                  state_cur     <= IDLE_S;
            end
          endcase
        end
        CONF_LAYER_2: begin
          r_rule_wren           <= 1'b1;
          case(r_cnt_ruleData) 
            4'd0: begin
                  r_rule_wdata  <= {16'h06,16'hff};     //* type + mask
                  r_rule_addr   <= {8'd2,16'd1,8'd0};   //* type id
            end
            4'd1: begin
                  r_rule_wdata  <= {16'h00,16'h00};
                  r_rule_addr   <= {8'd2,16'd1,8'd1}; 
            end
            4'd2: begin
                  r_rule_wdata  <= 32'd0;               //* type offset
                  r_rule_addr   <= {8'd2,16'd2,8'd0};   //* type id
            end
            4'd3: begin
                  r_rule_wdata  <= 32'd1;
                  r_rule_addr   <= {8'd2,16'd2,8'd1}; 
            end
            4'd4,4'd5: begin
                  r_rule_wdata  <= {16'd1,12'b0,r_cnt_ruleData[3:0]-4'd4};     //* key offset
                  r_rule_addr   <= {8'd2,16'd3,4'b0,r_cnt_ruleData[3:0]-4'd4}; //* key id
            end
            4'd6,4'd7,4'd8,4'd9,4'd10,4'd11: begin
                  r_rule_wdata  <= 32'd0;       //* disable
                  r_rule_addr   <= {8'd2,16'd3,r_cnt_ruleData[3:0]-4'd4}; 
            end
            4'd12:begin
                  r_rule_wdata  <= 32'd0;       //* head shift
                  r_rule_addr   <= {8'd2,16'd4,8'b0}; 
            end
            4'd13: begin
                  r_rule_wdata  <= 32'd0;       //* meta shift
                  r_rule_addr   <= {8'd2,16'd5,8'b0}; 
            end
            4'd14: begin
                  r_rule_wdata  <= 32'd1;       //* enable/disable rule;
                  r_rule_addr   <= {8'd2,16'd0,8'd2}; 
                  state_cur     <= IDLE_S;
            end
          endcase
        end
        SEND_ARP_S: begin
          r_phv_in[HEAD_WIDTH+:TAG_WIDTH] <= {4'b1101,{TAG_START_BIT{1'b1}}};
          r_phv_in[HEAD_WIDTH-1:0]        <= {NORMAL_ARP};
          r_meta_in[META_WIDTH+:TAG_WIDTH]<= {4'b1111,{META_SHIFT_WIDTH{1'b0}}};
          r_meta_in[META_WIDTH-1:0]       <= 'b0;
          state_cur                       <= IDLE_S;
        end
        SEND_TCP_S: begin
          r_phv_in[HEAD_WIDTH+:TAG_WIDTH] <= {4'b1101,{TAG_START_BIT{1'b1}}};
          r_phv_in[HEAD_WIDTH-1:0]        <= {NORMAL_TCP};
          r_meta_in[META_WIDTH+:TAG_WIDTH]<= {4'b1111,{META_SHIFT_WIDTH{1'b0}}};
          r_meta_in[META_WIDTH-1:0]       <= 'b0;
          state_cur                       <= IDLE_S;
        end
        TAIL_S: begin
          r_phv_in                        <= 'b0;
        end
        default: begin
          state_cur             <= IDLE_S;
        end
      endcase
    end
  end

endmodule
