
/*
 *  Project:            Pipelined-Packet-Parser.
 *  Module name:        Testbench.
 *  Description:        Testbench of Pipelined-Packet-Parser.
 *  Last updated date:  2024.04.07.
 *
 *  Copyright (C) 2021-2024 Junnan Li <lijunnan@nudt.edu.cn>.
 *  Copyright and related rights are licensed under the MIT license.
 *
 */

  /*------------------------------------------------------------------------------------
   *     name    | offset  |  description
   *------------------------------------------------------------------------------------
   * i_rule_addr |  [16]   | 1: conf type_offset, 0: conf rules
   *------------------------------------------------------------------------------------
   * [16] is 1   |  [3:0]  | type id, e.g., 2; while i_rule_wdata is offset;
   *------------------------------------------------------------------------------------
   *             |         | 0: write rules; while i_rule_wdata[0] is valid info
   * [16] is 0   |  [10:8] | 1: conf type data & type mask; while i_rule_addr[3:0] is type id
   *             |         | 2: conf key offset; while i_rule_addr[5:0] is keyField id; 
   *             |         |     while i_rule_wdata[16] is valid info
   *             |         | 3: conf head shift; while i_rule_addr[5:0] is keyField id
   *             |         | 4: conf meta shift; while i_rule_addr[5:0] is keyField id
   *------------------------------------------------------------------------------------*/

`timescale 1ns/1ps
// `define SIM_PKT_IO

module Testbench_wrapper(
);

`ifdef DUMP_FSDB
  initial begin
    $fsdbDumpfile("wave.fsdb");
    $fsdbDumpvars(0);
    $fsdbDumpMDA();
    $vcdpluson;
    $vcdplusmemon;
  end
`endif
  reg                   clk,rst_n;


  reg                   r_data_valid;
  reg   [133:0]         r_data;
  wire                  w_data_valid;
  wire  [133:0]         w_data;

  HyPipe_Top HyPipe_Top(
    .i_clk          (clk),
    .i_rst_n        (rst_n),
    .i_data_valid   (r_data_valid),
    .i_data         (r_data),
    .o_data_valid   (w_data_valid),
    .o_data         (w_data)
  );


  initial begin
    clk = 0;
    rst_n = 1;
    #2  rst_n = 0;
    #10 rst_n = 1;
    forever #1 clk = ~clk;
  end
  initial begin    
    `ifndef SIM_PKT_IO
      #2000 $finish;
    `endif
      // #2000 $finish;
  end
  

`ifdef SIM_PKT_IO
  reg     [2047:0]        pktIn_file, pktIn_file_1, pktOut_file;
  initial begin
    pktIn_file  = "./pktIO/pktIn.txt";
    pktIn_file_1= "./pktIO/pktIn_1.txt";
    pktOut_file = "./pktIO/pktOut.txt";
  end
  reg     [127:0]         memPktIn[0:127];
  //* fifo;
  reg                     rden_pktOut, rden_length;
  wire    [133:0]         dout_pktOut;
  wire    [ 11:0]         dout_length;
  wire                    empty_pktOut, empty_length;
  reg                     wren_length;
  reg     [ 7:0]          data_length;
  reg     [ 3:0]          data_valid;

  reg     [127:0]         pktIn_rdata;
  wire    [ 7:0]          w_cnt_pkt_data[3:0];
  reg     [7:0]           cnt_pkt_data, length_pkt_data;
  reg     [31:0]          cnt_clk;
  reg     [15:0]          tag_pkt;  //* from 0 to 2^16-1;
  reg     [3:0]           tag_pkt_unvalid;  //* from 4'b0 to 4'b1111;
  
  task handle_pktIn_rdata; begin
    if (cnt_pkt_data < 128) begin
      pktIn_rdata = {memPktIn[cnt_pkt_data+2]};
    end
  end endtask

  //* recv pkt;
  typedef enum logic [3:0] {IDLE_S, SEND_PKT_HEAD, WAIT_PKT_TAIL, WAIT_X_S, READ_SIM_PKT} state_t;
  state_t state_cur;
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      r_data_valid              <= 'b0;
      r_data                    <= 'b0;
      cnt_pkt_data              <= 'b0;
      cnt_clk                   <= 'b0;
      state_cur                 <= IDLE_S;
      tag_pkt                   <= 'b0;
    end
    else begin
      case(state_cur)
        IDLE_S: begin
          r_data_valid          <= 'b0;
          cnt_pkt_data          <= 'b0;
          cnt_clk               <= 'b0;
          $readmemh(pktIn_file, memPktIn);
          state_cur            <= SEND_PKT_HEAD;
          handle_pktIn_rdata;
        end
        SEND_PKT_HEAD: begin
          handle_pktIn_rdata;
          if(memPktIn[0][15:0] == tag_pkt)
            state_cur           <= WAIT_X_S;
          else begin
            tag_pkt             <= memPktIn[0][15:0];
            length_pkt_data     <= memPktIn[1][7:0];
            tag_pkt_unvalid     <= memPktIn[1][11:8];

            r_data_valid        <= 1'b1;
            r_data              <= {2'b01,4'b0, pktIn_rdata};
            state_cur           <= WAIT_PKT_TAIL;
            cnt_pkt_data        <= 8'd1 + cnt_pkt_data;
          end
        end
        WAIT_PKT_TAIL: begin
          handle_pktIn_rdata;
          cnt_pkt_data          <= 8'd1 + cnt_pkt_data;
          if(length_pkt_data == (cnt_pkt_data+8'd1)) begin
            r_data              <= {2'b10,tag_pkt_unvalid, pktIn_rdata};
            // state_cur           <= IDLE_S;
            state_cur           <= READ_SIM_PKT;
          end
          else begin
            r_data              <= {2'b00,4'b0, pktIn_rdata};
          end
        end
        WAIT_X_S: begin
          r_data_valid          <= 'b0;
          cnt_clk               <= 32'd1 + cnt_clk;
          if(cnt_clk[15] == 1'b1)
            state_cur           <= READ_SIM_PKT;
        end
        READ_SIM_PKT: begin
          r_data_valid          <= 'b0;
          cnt_pkt_data          <= 'b0;
          cnt_clk               <= 'b0;
          $readmemh(pktIn_file_1, memPktIn);
          state_cur            <= SEND_PKT_HEAD;
          handle_pktIn_rdata;
        end
      endcase
    end
  end


  //* fifo used to buffer pkt;
  syncfifo fifo_pktOut (
    .clock                (clk                      ),  //* ASYNC WriteClk, SYNC use wrclk
    .aclr                 (!rst_n                   ),  //* Reset the all signal
    .data                 (w_data                   ),  //* The Inport of data 
    .wrreq                (w_data_valid             ),  //* active-high
    .rdreq                (rden_pktOut              ),  //* active-high
    .q                    (dout_pktOut              ),  //* The output of data
    .empty                (empty_pktOut             ),  //* Read domain empty
    .usedw                (                         ),  //* Usedword
    .full                 (                         )   //* Full
  );
  defparam  fifo_pktOut.width = 134,
            fifo_pktOut.depth = 7,
            fifo_pktOut.words = 128;

  //* fifo used to buffer pkt;
  syncfifo fifo_length (
    .clock                (clk                      ),  //* ASYNC WriteClk, SYNC use wrclk
    .aclr                 (!rst_n                   ),  //* Reset the all signal
    .data                 ({data_valid,data_length} ),  //* The Inport of data 
    .wrreq                (wren_length              ),  //* active-high
    .rdreq                (rden_length              ),  //* active-high
    .q                    (dout_length              ),  //* The output of data
    .empty                (empty_length             ),  //* Read domain empty
    .usedw                (                         ),  //* Usedword
    .full                 (                         )   //* Full
  );
  defparam  fifo_length.width = 12,
            fifo_length.depth = 7,
            fifo_length.words = 128;

  //* count length;
  always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
      wren_length             <= 1'b0;
      data_length             <= 8'b0;
      data_valid              <= 4'b0;
    end else begin
      if(w_data_valid == 1'b1 && w_data[133:132] == 2'b10) begin
        data_length           <= 8'd1;
      end
      else if(w_data_valid == 1'b1) begin
        data_length           <= 8'd1 + data_length;
      end
      
      wren_length             <= 1'b0;
      if(w_data_valid == 1'b1 && w_data[133:132] == 2'b01) begin
        data_valid            <= w_data[131:128];
        wren_length           <= 1'b1;
      end
    end
  end

  //* write pkt to file;
  integer       handle_wr;
  reg   [3:0]   state_wrPkt;
  reg   [15:0]  cnt_wrPkt;
  parameter     IDLE_WRPKT_S      = 4'd0,
                WR_PKT_S          = 4'd1;
  always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
      rden_length             <= 1'b0;
      rden_pktOut             <= 1'b0;
      cnt_wrPkt               <= 16'b0;
      state_wrPkt             <= IDLE_WRPKT_S;
    end else begin
      case (state_wrPkt)
        IDLE_WRPKT_S: begin
          if(empty_length == 1'b0) begin
            handle_wr = $fopen(pktOut_file,"w");
            state_wrPkt       <= WR_PKT_S;
            rden_length       <= 1'b1;
            rden_pktOut       <= 1'b1;
            cnt_wrPkt         <= 16'b1 + cnt_wrPkt;
            $fwrite(handle_wr,"%08x\n",cnt_wrPkt);
            $fwrite(handle_wr,"%08x\n",dout_length);

          end
        end
        WR_PKT_S: begin
          rden_length         <= 1'b0;
          $fwrite(handle_wr,"%32x\n",dout_pktOut[127:0]);
          if(dout_pktOut[133:132] == 2'b10) begin
            rden_pktOut       <= 1'b0;
            state_wrPkt       <= IDLE_WRPKT_S;
            $fclose(handle_wr);
          end
        end
        default: begin end
      endcase
    end
  end
`else  
  localparam CONF_PKT_DATA0   = {48'h8888_8888_8988,48'h010203040506,16'h9006,16'b0};
  localparam NORMAL_ARP_DATA0 = {48'h0001_0203_0405,48'h060708090a0b,16'h0806,16'h0001};
  localparam NORMAL_ARP_DATA1 = {128'h0800_0604_0001_0607_0809_0a0b_c0a8_eefa};
  localparam NORMAL_ARP_DATA2 = {48'h0001_0203_0405,48'h060708090a0b,16'h0806,16'h0001};
  localparam NORMAL_TCP_DATA0 = {128'h000a_3500_0102_00e0_4d6d_a7b3_0800_4500};
  localparam NORMAL_TCP_DATA1 = {128'h0028_e84b_4000_4006_ce61_c0a8_010a_c0a8};
  localparam NORMAL_TCP_DATA2 = {128'h01c8_1389_c001_3876_6005_0000_1986_5010};
  localparam NORMAL_TCP_DATA3 = {128'hfad8_843d_0000_3876_6005_0000_1986_5010};
  
  typedef enum logic [3:0] {IDLE_S, CONF_LAYER_1, CONF_LAYER_2, CONF_LAYER_3, SEND_ARP_S, SEND_TCP_S} state_t;
  state_t state_cur, state_pre;

  reg   [3:0]  r_cnt_pktData;
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      r_data_valid              <= 'b0;
      r_data                    <= 'b0;
      r_cnt_pktData             <= 'b0;
      state_cur                 <= IDLE_S;
      state_pre                 <= IDLE_S;
    end
    else begin
      r_data_valid              <= 'b0;
      state_pre                 <= state_cur;
      r_cnt_pktData             <= r_cnt_pktData + 4'd1;
      case(state_cur)
        IDLE_S: begin
          case(state_pre)
            IDLE_S:             state_cur   <= CONF_LAYER_1;
            CONF_LAYER_1:       state_cur   <= CONF_LAYER_2;
            CONF_LAYER_2:       state_cur   <= CONF_LAYER_3;
            CONF_LAYER_3:       state_cur   <= SEND_ARP_S;
            SEND_ARP_S:         state_cur   <= SEND_TCP_S;
            // SEND_TCP_S:         state_cur   <= SEND_UDP_S;
          endcase
          r_cnt_pktData         <= 'b0;
        end
        CONF_LAYER_1: begin
          r_data_valid          <= 1'b1;
          case(r_cnt_pktData)
            4'd0: r_data        <= {2'b01,4'h0,CONF_PKT_DATA0};  
            4'd1: r_data        <= {2'b00,4'hf,48'b0,32'd1,      32'd0,          16'b0};  //* type offset + type id
            4'd2: r_data        <= {2'b00,4'hf,48'b0,32'd2,      32'd1,          16'b0}; 
            4'd3: r_data        <= {2'b00,4'hf,48'b0,16'h0,16'h0,16'd1,8'd1,8'd0,16'b0};  //* type + mask + type id
            4'd4: r_data        <= {2'b00,4'hf,48'b0,16'h0,16'h0,16'd1,8'd1,8'd1,16'b0}; 
            4'd5,4'd6,4'd7,4'd8,4'd9,4'd10: 
                  r_data        <= {2'b00,4'hf,48'b0,
                                      16'd1,12'b0,r_cnt_pktData[3:0]-4'd5,
                                      16'd1,8'd2,4'b0,r_cnt_pktData[3:0]-4'd5,16'b0};     //* key offset + key id;
            4'd11:r_data        <= {2'b00,4'hf,48'b0,32'd0,      8'd0,8'd1,8'd2,8'd6,16'b0};  //* disable
            4'd12:r_data        <= {2'b00,4'hf,48'b0,32'd0,      8'd0,8'd1,8'd2,8'd7,16'b0};  //* disable
            4'd13:r_data        <= {2'b00,4'hf,48'b0,32'd6,      16'd1,8'd3,8'b0,16'b0};  //* head shift
            4'd14:r_data        <= {2'b00,4'hf,48'b0,32'd6,      16'd1,8'd4,8'b0,16'b0};  //* meta shift
            4'd15: begin
                  r_data        <= {2'b10,4'hf,48'b0,32'd1,      16'd1,8'd0,8'd2,16'b0};  //* enable/disable rule;
                  state_cur     <= IDLE_S;
            end
          endcase
        end
        CONF_LAYER_2: begin
          r_data_valid          <= 1'b1;
          case(r_cnt_pktData)
            4'd0: r_data        <= {2'b01,4'h0,CONF_PKT_DATA0};  
            4'd1: r_data        <= {2'b00,4'hf,48'b0,32'd0,        8'd1,24'd0,         16'b0};  //* type offset + type id
            4'd2: r_data        <= {2'b00,4'hf,48'b0,32'd1,        8'd1,24'd1,         16'b0};
            4'd3: r_data        <= {2'b00,4'hf,48'b0,16'h08,16'hff,8'd1,8'd1,8'd1,8'd0,16'b0};  //* type + mask + type id
            4'd4: r_data        <= {2'b00,4'hf,48'b0,16'h00,16'hff,8'd1,8'd1,8'd1,8'd1,16'b0}; 
            4'd5: r_data        <= {2'b00,4'hf,48'b0,16'd1,16'd5,  8'd1,8'd1,8'd2,8'd0,16'b0};  //* key offset + key id;
            4'd6: r_data        <= {2'b00,4'hf,48'b0,16'd1,16'd7,  8'd1,8'd1,8'd2,8'd1,16'b0};  //* key offset + key id;
            4'd7: r_data        <= {2'b00,4'hf,48'b0,16'd1,16'd8,  8'd1,8'd1,8'd2,8'd2,16'b0};  //* key offset + key id;
            4'd8: r_data        <= {2'b00,4'hf,48'b0,16'd1,16'd9,  8'd1,8'd1,8'd2,8'd3,16'b0};  //* key offset + key id;
            4'd9: r_data        <= {2'b00,4'hf,48'b0,16'd1,16'd10, 8'd1,8'd1,8'd2,8'd4,16'b0};  //* key offset + key id;
            4'd10:r_data        <= {2'b00,4'hf,48'b0,32'd0,        8'd1,8'd1,8'd2,8'd5,16'b0};  //* disable
            4'd11:r_data        <= {2'b00,4'hf,48'b0,32'd0,        8'd1,8'd1,8'd2,8'd6,16'b0};  //* disable
            4'd12:r_data        <= {2'b00,4'hf,48'b0,32'd0,        8'd1,8'd1,8'd2,8'd7,16'b0};  //* disable
            4'd13:r_data        <= {2'b00,4'hf,48'b0,32'd1,        8'd1,8'd1,8'd3,8'b0,16'b0};  //* head shift
            4'd14:r_data        <= {2'b00,4'hf,48'b0,32'd5,        8'd1,8'd1,8'd4,8'b0,16'b0};  //* meta shift
            4'd15: begin
                  r_data        <= {2'b10,4'hf,48'b0,32'd1,        8'd1,8'd1,8'd0,8'd2,16'b0};  //* enable/disable rule;
                  state_cur     <= IDLE_S;
            end
          endcase
        end
        CONF_LAYER_3: begin
          r_data_valid          <= 1'b1;
          case(r_cnt_pktData)
            4'd0: r_data        <= {2'b01,4'h0,CONF_PKT_DATA0};  
            4'd1: r_data        <= {2'b00,4'hf,48'b0,32'd9,        8'd2,24'd0,         16'b0};  //* type offset + type id
            4'd2: r_data        <= {2'b00,4'hf,48'b0,32'd10,       8'd2,24'd1,         16'b0};
            4'd3: r_data        <= {2'b00,4'hf,48'b0,16'h06,16'h0e,8'd2,8'd1,8'd1,8'd0,16'b0};  //* type + mask + type id
            4'd4: r_data        <= {2'b00,4'hf,48'b0,16'h00,16'h00,8'd2,8'd1,8'd1,8'd1,16'b0}; 
            4'd5: r_data        <= {2'b00,4'hf,48'b0,16'd1,16'd10, 8'd2,8'd1,8'd2,8'd0,16'b0};  //* key offset + key id;
            4'd6: r_data        <= {2'b00,4'hf,48'b0,16'd1,16'd11, 8'd2,8'd1,8'd2,8'd1,16'b0};  //* key offset + key id;
            4'd7: r_data        <= {2'b00,4'hf,48'b0,16'd1,16'd12, 8'd2,8'd1,8'd2,8'd2,16'b0};  //* key offset + key id;
            4'd8: r_data        <= {2'b00,4'hf,48'b0,16'd1,16'd13, 8'd2,8'd1,8'd2,8'd3,16'b0};  //* key offset + key id;
            4'd9: r_data        <= {2'b00,4'hf,48'b0,32'd0,        8'd2,8'd1,8'd2,8'd4,16'b0};  //* disable
            4'd10:r_data        <= {2'b00,4'hf,48'b0,32'd0,        8'd2,8'd1,8'd2,8'd5,16'b0};  //* disable
            4'd11:r_data        <= {2'b00,4'hf,48'b0,32'd0,        8'd2,8'd1,8'd2,8'd6,16'b0};  //* disable
            4'd12:r_data        <= {2'b00,4'hf,48'b0,32'd0,        8'd2,8'd1,8'd2,8'd7,16'b0};  //* disable
            4'd13:r_data        <= {2'b00,4'hf,48'b0,32'd0,        8'd2,8'd1,8'd3,8'b0,16'b0};  //* head shift
            4'd14:r_data        <= {2'b00,4'hf,48'b0,32'd0,        8'd2,8'd1,8'd4,8'b0,16'b0};  //* meta shift
            4'd15: begin
                  r_data        <= {2'b10,4'hf,48'b0,32'd1,        8'd2,8'd1,8'd0,8'd2,16'b0};  //* enable/disable rule;
                  state_cur     <= IDLE_S;
            end
          endcase
        end
        SEND_ARP_S: begin
          r_data_valid          <= 1'b1;
          case(r_cnt_pktData)
            4'd0: r_data        <= {2'b01,4'hf,NORMAL_ARP_DATA0};  
            4'd1: r_data        <= {2'b00,4'hf,NORMAL_ARP_DATA1};
            4'd2: begin
                  r_data        <= {2'b10,4'hf,NORMAL_ARP_DATA2};
                  state_cur     <= IDLE_S;
            end
          endcase
        end
        SEND_TCP_S: begin
          r_data_valid          <= 1'b1;
          case(r_cnt_pktData)
            4'd0: r_data        <= {2'b01,4'hf,NORMAL_TCP_DATA0};  
            4'd1: r_data        <= {2'b00,4'hf,NORMAL_TCP_DATA1}; 
            4'd2: r_data        <= {2'b00,4'hf,NORMAL_TCP_DATA2};
            4'd3: begin
                  r_data        <= {2'b10,4'hf,NORMAL_TCP_DATA3};
                  // state_cur     <= IDLE_S;
            end
            4'd4: begin
                  r_data_valid  <= 1'b0;
                  r_cnt_pktData <= r_cnt_pktData;
                  // state_cur     <= IDLE_S;
            end
          endcase
        end
        default: begin
          state_cur             <= IDLE_S;
        end
      endcase
    end
  end
`endif

endmodule
