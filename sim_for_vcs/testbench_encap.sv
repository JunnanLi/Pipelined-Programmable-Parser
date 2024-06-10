
/*
 *  Project:            Pipelined-Packet-Parser.
 *  Module name:        Testbench.
 *  Description:        Testbench of Pipelined-Packet-Parser.
 *  Last updated date:  2024.04.21.
 *
 *  Copyright (C) 2021-2024 Junnan Li <lijunnan@nudt.edu.cn>.
 *  Copyright and related rights are licensed under the MIT license.
 *
 */

`timescale 1ns/1ps
// `define TEST_DECAP
`define TEST_ENCAP

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
  
  reg   [`HEAD_WIDTH+`TAG_WIDTH-1:0]  r_head;
  wire  [`HEAD_WIDTH+`TAG_WIDTH-1:0]  w_head;
  reg   [`META_WIDTH+`TAG_WIDTH-1:0]  r_meta;
  wire  [`META_WIDTH+`TAG_WIDTH-1:0]  w_meta;
  reg   [                       3:0]  r_metaSliceOffset;
  reg   [`HEAD_SHIFT_WIDTH-1:0]       r_metaDataOffset;
  reg   [`META_SHIFT_WIDTH-1:0]       r_decapLength,r_encapLength;
  reg   [`ENCAP_WIDTH-1:0]            r_encapField;
`ifdef TEST_DECAP
  Decap_Head Decap_Head(
    .i_clk              (clk),
    .i_rst_n            (rst_n),
    .i_head             (r_head),
    .o_head             (w_head),
    .i_meta             (r_meta),
    .o_meta             (w_meta),
    .i_metaSliceOffset  (r_metaSliceOffset),
    .i_metaDataOffset   (r_metaDataOffset),
    .i_decapLength      (r_decapLength),
    .i_decapEn          (1'b1)
  );
`endif
`ifdef TEST_ENCAP
  Encap_Head Encap_Head(
    .i_clk              (clk),
    .i_rst_n            (rst_n),
    .i_head             (r_head),
    .o_head             (w_head),
    .i_headShift        ('b0),
    .i_meta             (r_meta),
    .o_meta             (w_meta),
    .i_metaSliceOffset  (r_metaSliceOffset),
    .i_metaDataOffset   (r_metaDataOffset),
    .i_encapLength      (r_encapLength),
    .i_encapField       (r_encapField),
    .i_encapEn          (1'b1)
  );
`endif
  
  initial begin
    clk = 1;
    rst_n = 1;
    #2  rst_n = 0;
    #10 rst_n = 1;
    forever #1 clk = ~clk;
  end
  initial begin    
      #2000 $finish;
  end
  

  localparam DATA0 = {128'h1111_2222_3333_4444_5555_6666_7777_8888,
                      128'h9999_aaaa_bbbb_cccc_dddd_eeee_ffff_0000,
                      128'h1111_2222_3333_4444_5555_6666_7777_8888,
                      128'h9999_aaaa_bbbb_cccc_dddd_eeee_ffff_0000};
  localparam DATA1 = {128'h0011_0022_0033_0044_0055_0066_0077_0088,
                      128'h0099_00aa_00bb_00cc_00dd_00ee_00ff_0000,
                      128'h0011_0022_0033_0044_0055_0066_0077_0088,
                      128'h0099_00aa_00bb_00cc_00dd_00ee_00ff_0000};

  reg   [3:0]  r_cnt_pktData;

  initial begin
    r_head                    <= 'b0;
    r_meta                    <= 'b0;
    r_metaSliceOffset         <= 'b0;
    r_metaDataOffset          <= 'b0;
    r_decapLength             <= 'd12;
    r_encapLength             <= 'd7;
    r_encapField              <= 128'hffff_eeee_dddd_cccc_bbbb_aaaa_9999_8888;
  `ifdef TEST_DECAP  
    #100 begin
      r_meta[`META_WIDTH-1:0] <= DATA0;
      r_meta[`META_WIDTH+`TAG_START_BIT]  <= 1'b1;
      r_meta[`META_WIDTH+`TAG_TAIL_BIT]   <= 1'b0;
      r_meta[`META_WIDTH+`TAG_SHIFT_BIT]  <= 1'b1;
      r_meta[`META_WIDTH+`TAG_VALID_BIT]  <= 1'b1;
      r_meta[`META_WIDTH+:`TAG_START_BIT] <= 'b0;

      r_head[`META_WIDTH-1:0] <= DATA0;
      r_head[`META_WIDTH+`TAG_START_BIT]  <= 1'b1;
      r_head[`META_WIDTH+`TAG_TAIL_BIT]   <= 1'b1;
      r_head[`META_WIDTH+`TAG_SHIFT_BIT]  <= 1'b1;
      r_head[`META_WIDTH+`TAG_VALID_BIT]  <= 1'b1;
      r_head[`META_WIDTH+:`TAG_START_BIT] <= 'b0;
    end
    #2 begin
      r_meta[`META_WIDTH-1:0] <= DATA1;
      r_meta[`META_WIDTH+`TAG_START_BIT]  <= 1'b0;
      r_meta[`META_WIDTH+`TAG_TAIL_BIT]   <= 1'b1;
      r_meta[`META_WIDTH+`TAG_SHIFT_BIT]  <= 1'b1;
      r_meta[`META_WIDTH+`TAG_VALID_BIT]  <= 1'b1;
      r_meta[`META_WIDTH+:`TAG_START_BIT] <= 'b0;

      r_head <= 'b0;
    end
    #2 begin
      r_meta                  <= 'b0;
    end

    #100 begin
      r_metaSliceOffset       <= 'b1;
      r_metaDataOffset        <= 'b1;
      r_decapLength           <= 'd12;

      r_meta[`META_WIDTH-1:0] <= DATA0;
      r_meta[`META_WIDTH+`TAG_START_BIT]  <= 1'b1;
      r_meta[`META_WIDTH+`TAG_TAIL_BIT]   <= 1'b0;
      r_meta[`META_WIDTH+`TAG_SHIFT_BIT]  <= 1'b1;
      r_meta[`META_WIDTH+`TAG_VALID_BIT]  <= 1'b1;
      r_meta[`META_WIDTH+:`TAG_START_BIT] <= 'b0;

      r_head[`META_WIDTH-1:0] <= DATA0;
      r_head[`META_WIDTH+`TAG_START_BIT]  <= 1'b1;
      r_head[`META_WIDTH+`TAG_TAIL_BIT]   <= 1'b1;
      r_head[`META_WIDTH+`TAG_SHIFT_BIT]  <= 1'b1;
      r_head[`META_WIDTH+`TAG_VALID_BIT]  <= 1'b1;
      r_head[`META_WIDTH+:`TAG_START_BIT] <= 'b0;
    end
    #2 begin
      r_meta[`META_WIDTH-1:0] <= DATA1;
      r_meta[`META_WIDTH+`TAG_START_BIT]  <= 1'b0;
      r_meta[`META_WIDTH+`TAG_TAIL_BIT]   <= 1'b1;
      r_meta[`META_WIDTH+`TAG_SHIFT_BIT]  <= 1'b1;
      r_meta[`META_WIDTH+`TAG_VALID_BIT]  <= 1'b1;
      r_meta[`META_WIDTH+:`TAG_START_BIT] <= 'b0;

      r_head <= 'b0;
    end
    #2 begin
      r_meta                  <= 'b0;
    end
  `endif

  `ifdef TEST_ENCAP
    #100 begin
      r_meta[`META_WIDTH-1:0] <= DATA0;
      r_meta[`META_WIDTH+`TAG_START_BIT]  <= 1'b1;
      r_meta[`META_WIDTH+`TAG_TAIL_BIT]   <= 1'b0;
      r_meta[`META_WIDTH+`TAG_SHIFT_BIT]  <= 1'b1;
      r_meta[`META_WIDTH+`TAG_VALID_BIT]  <= 1'b1;
      r_meta[`META_WIDTH+:`TAG_START_BIT] <= 'b0;

      r_head[`META_WIDTH-1:0] <= DATA0;
      r_head[`META_WIDTH+`TAG_START_BIT]  <= 1'b1;
      r_head[`META_WIDTH+`TAG_TAIL_BIT]   <= 1'b1;
      r_head[`META_WIDTH+`TAG_SHIFT_BIT]  <= 1'b1;
      r_head[`META_WIDTH+`TAG_VALID_BIT]  <= 1'b1;
      r_head[`META_WIDTH+:`TAG_START_BIT] <= 'b0;
    end
    #2 begin
      r_meta[`META_WIDTH-1:0] <= DATA1;
      r_meta[`META_WIDTH+`TAG_START_BIT]  <= 1'b0;
      r_meta[`META_WIDTH+`TAG_TAIL_BIT]   <= 1'b1;
      r_meta[`META_WIDTH+`TAG_SHIFT_BIT]  <= 1'b1;
      r_meta[`META_WIDTH+`TAG_VALID_BIT]  <= 1'b1;
      r_meta[`META_WIDTH+:`TAG_START_BIT] <= 'b0;

      r_head <= 'b0;
    end
    #2 begin
      r_meta                  <= 'b0;
    end

    #100 begin
      r_metaSliceOffset       <= 'b1;
      r_metaDataOffset        <= 'b1;
      r_decapLength           <= 'd12;

      r_meta[`META_WIDTH-1:0] <= DATA0;
      r_meta[`META_WIDTH+`TAG_START_BIT]  <= 1'b1;
      r_meta[`META_WIDTH+`TAG_TAIL_BIT]   <= 1'b0;
      r_meta[`META_WIDTH+`TAG_SHIFT_BIT]  <= 1'b1;
      r_meta[`META_WIDTH+`TAG_VALID_BIT]  <= 1'b1;
      r_meta[`META_WIDTH+:`TAG_START_BIT] <= 'b0;

      r_head[`META_WIDTH-1:0] <= DATA0;
      r_head[`META_WIDTH+`TAG_START_BIT]  <= 1'b1;
      r_head[`META_WIDTH+`TAG_TAIL_BIT]   <= 1'b1;
      r_head[`META_WIDTH+`TAG_SHIFT_BIT]  <= 1'b1;
      r_head[`META_WIDTH+`TAG_VALID_BIT]  <= 1'b1;
      r_head[`META_WIDTH+:`TAG_START_BIT] <= 'b0;
    end
    #2 begin
      r_meta[`META_WIDTH-1:0] <= DATA1;
      r_meta[`META_WIDTH+`TAG_START_BIT]  <= 1'b0;
      r_meta[`META_WIDTH+`TAG_TAIL_BIT]   <= 1'b1;
      r_meta[`META_WIDTH+`TAG_SHIFT_BIT]  <= 1'b1;
      r_meta[`META_WIDTH+`TAG_VALID_BIT]  <= 1'b1;
      r_meta[`META_WIDTH+:`TAG_START_BIT] <= 'b0;

      r_head <= 'b0;
    end
    #2 begin
      r_meta                  <= 'b0;
    end
  `endif
  end

endmodule
