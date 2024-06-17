
/*
 *  Project:            Pipelined-Packet-Parser.
 *  Module name:        Testbench.
 *  Description:        Testbench of Pipelined-Packet-Parser.
 *  Last updated date:  2024.04.12.
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
   *             |         |     while i_rule_wdata[16] is valid info, and                *
   *             |         |     i_rule_wdata[8+:5] is replaceOffset info                 *
   *--------------------------------------------------------------------------------------*
   * [10:8] is 4 |         | conf head shift                                              *
   *--------------------------------------------------------------------------------------*
   * [10:8] is 5 |         | conf meta shift                                              *
   *--------------------------------------------------------------------------------------*/

`timescale 1ns/1ps
import parser_pkg::*;
`define AUTO_CONF

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
  reg                   clk,rst_n;

  reg           r_rule_wren;
  reg   [31:0]  r_rule_addr;
  reg   [31:0]  r_rule_wdata;
  reg   [HEAD_WIDTH+TAG_WIDTH-1:0]   r_phv_in;
  wire  [HEAD_WIDTH+TAG_WIDTH-1:0]   w_phv_out;
  reg   [META_WIDTH+TAG_WIDTH-1:0]   r_meta_in;
  wire  [META_WIDTH+TAG_WIDTH-1:0]   w_meta_out;
  
  //* parser pkt;
  Deparser_Top deparser_top(
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
  

  localparam NORMAL_ARP       = {48'h0001_0203_0405,48'h060708090a0b,16'h0806,16'h0001,
                                  128'h0800_0604_0001_0607_0809_0a0b_c0a8_eefa,
                                  48'h0001_0203_0405,48'h060708090a0b,16'h0806,16'h0001,
                                  128'h0};
  localparam NORMAL_TCP       = {128'h000a_3500_0102_00e0_4d6d_a7b3_0800_4500,
                                  128'h0028_e84b_4000_4006_ce61_c0a8_010a_c0a8,
                                  128'h01c8_1389_c001_3876_6005_0000_1986_5010,
                                  128'hfad8_843d_0000_3876_6005_0000_1986_5010};
  localparam REPLACE_META     = {128'h1111_2222_3333_4444_5555_6666_0800_0006,
                                  128'haaaa_bbbb_cccc_dddd_00ee_00ff_0000_0000,
                                  128'h0,128'h0};
`ifdef AUTO_CONF
`else

  initial begin
    //* layer_0: ethernet
    //* type offset;
    force deparser_top.layer_info_0.type_offset[0]  = 12;
    force deparser_top.layer_info_0.type_offset[1]  = 13;
    //* key offset;
    force deparser_top.layer_info_0.key_offset_v    = 8'h3f;
    force deparser_top.layer_info_0.key_offset[0]   = 0;
    force deparser_top.layer_info_0.key_offset[1]   = 1;
    force deparser_top.layer_info_0.key_offset[2]   = 2;
    force deparser_top.layer_info_0.key_offset[3]   = 3;
    force deparser_top.layer_info_0.key_offset[4]   = 4;
    force deparser_top.layer_info_0.key_offset[5]   = 5;
    //* head len;
    force deparser_top.layer_info_0.headShift       = 6;
    //* meta len;
    force deparser_top.layer_info_0.metaShift       = 7;
    force deparser_top.layer_info_0.key_replaceOffset[0] = 0;
    force deparser_top.layer_info_0.key_replaceOffset[1] = 1;
    force deparser_top.layer_info_0.key_replaceOffset[2] = 2;
    force deparser_top.layer_info_0.key_replaceOffset[3] = 3;
    force deparser_top.layer_info_0.key_replaceOffset[4] = 4;
    force deparser_top.layer_info_0.key_replaceOffset[5] = 5;
    force deparser_top.layer_info_0.key_replaceOffset_v  = 32'h3f;
    
    //* layer_1: IPv4
    //* rule is valid;
    force deparser_top.deparser_layer1.lookup_type.r_type_rule[0].typeRule_valid          = 1;
    //* type value;
    force deparser_top.deparser_layer1.lookup_type.r_type_rule[0].typeRule_typeData[0]    = 8'h0;
    force deparser_top.deparser_layer1.lookup_type.r_type_rule[0].typeRule_typeData[1]    = 8'h0;
    //* type mask;
    force deparser_top.deparser_layer1.lookup_type.r_type_rule[0].typeRule_typeMask[0]    = 8'h0;
    force deparser_top.deparser_layer1.lookup_type.r_type_rule[0].typeRule_typeMask[1]    = 8'h0;
    //* next type offset;
    force deparser_top.deparser_layer1.lookup_type.r_type_rule[0].typeRule_typeOffset[0]  = 9;
    force deparser_top.deparser_layer1.lookup_type.r_type_rule[0].typeRule_typeOffset[1]  = 9;
    //* next key offset;
    force deparser_top.deparser_layer1.lookup_type.r_type_rule[0].typeRule_keyOffset_v    = 8'hf;
    force deparser_top.deparser_layer1.lookup_type.r_type_rule[0].typeRule_keyOffset[0]   = 0;
    force deparser_top.deparser_layer1.lookup_type.r_type_rule[0].typeRule_keyOffset[1]   = 1;
    force deparser_top.deparser_layer1.lookup_type.r_type_rule[0].typeRule_keyOffset[2]   = 2;
    force deparser_top.deparser_layer1.lookup_type.r_type_rule[0].typeRule_keyOffset[3]   = 3;
    force deparser_top.deparser_layer1.lookup_type.r_type_rule[0].typeRule_keyReplaceOffset[0]  = 6;
    force deparser_top.deparser_layer1.lookup_type.r_type_rule[0].typeRule_keyReplaceOffset[1]  = 7;
    force deparser_top.deparser_layer1.lookup_type.r_type_rule[0].typeRule_keyReplaceOffset[2]  = 8;
    force deparser_top.deparser_layer1.lookup_type.r_type_rule[0].typeRule_keyReplaceOffset[3]  = 9;
    //* next head len;
    force deparser_top.deparser_layer1.lookup_type.r_type_rule[0].typeRule_headShift      = 4;
    //* next meta len;
    force deparser_top.deparser_layer1.lookup_type.r_type_rule[0].typeRule_metaShift      = 10;
    
    //* layer_2: TCP/UDP
    //* rule is valid;
    force deparser_top.deparser_layer2.lookup_type.r_type_rule[0].typeRule_valid          = 1;
    //* type value;
    force deparser_top.deparser_layer2.lookup_type.r_type_rule[0].typeRule_typeData[0]    = 8'h0;
    force deparser_top.deparser_layer2.lookup_type.r_type_rule[0].typeRule_typeData[1]    = 8'h0;
    //* type mask;
    force deparser_top.deparser_layer2.lookup_type.r_type_rule[0].typeRule_typeMask[0]    = 8'h0;
    force deparser_top.deparser_layer2.lookup_type.r_type_rule[0].typeRule_typeMask[1]    = 8'h0;
    //* next type offset;
    force deparser_top.deparser_layer2.lookup_type.r_type_rule[0].typeRule_typeOffset[0]  = 0;
    force deparser_top.deparser_layer2.lookup_type.r_type_rule[0].typeRule_typeOffset[1]  = 0;
    //* next key offset;
    force deparser_top.deparser_layer2.lookup_type.r_type_rule[0].typeRule_keyOffset_v    = 6'h3;
    force deparser_top.deparser_layer2.lookup_type.r_type_rule[0].typeRule_keyOffset[0]   = 0;
    force deparser_top.deparser_layer2.lookup_type.r_type_rule[0].typeRule_keyOffset[1]   = 1;
    force deparser_top.deparser_layer2.lookup_type.r_type_rule[0].typeRule_keyReplaceOffset[0]  = 0;
    force deparser_top.deparser_layer2.lookup_type.r_type_rule[0].typeRule_keyReplaceOffset[1]  = 1;
    //* next head len;
    force deparser_top.deparser_layer2.lookup_type.r_type_rule[0].typeRule_headShift      = 2;
    //* next meta len;
    force deparser_top.deparser_layer2.lookup_type.r_type_rule[0].typeRule_metaShift      = 10;

  end

`endif

  initial begin
    #100 begin
      force deparser_top.layer_info_0.head = {4'b1101,{TAG_START_BIT{1'b1}}, REPLACE_META};
      force deparser_top.layer_info_0.meta = {4'b1111,{TAG_START_BIT{1'b1}}, NORMAL_TCP};
    end
    #2 begin
      force deparser_top.layer_info_0.head = 'b0;
      force deparser_top.layer_info_0.meta = 'b0;
    end 
  end


endmodule
