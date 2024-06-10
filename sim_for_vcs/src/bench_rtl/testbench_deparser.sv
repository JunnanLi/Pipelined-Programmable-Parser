
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
// `define READ_CONF

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
  

`ifdef READ_CONF
`else

  initial begin
    //* layer_0: ethernet
    //* type offset;
    force deparser_top.layer_info_0.type_offset[0]  = 12;
    force deparser_top.layer_info_0.type_offset[1]  = 13;
    //* key offset;
    force deparser_top.layer_info_0.key_offset_v[0] = 1;
    force deparser_top.layer_info_0.key_offset[0]   = 0;
    force deparser_top.layer_info_0.key_offset_v[1] = 1;
    force deparser_top.layer_info_0.key_offset[1]   = 1;
    force deparser_top.layer_info_0.key_offset_v[2] = 1;
    force deparser_top.layer_info_0.key_offset[2]   = 2;
    force deparser_top.layer_info_0.key_offset_v[3] = 1;
    force deparser_top.layer_info_0.key_offset[3]   = 3;
    force deparser_top.layer_info_0.key_offset_v[4] = 1;
    force deparser_top.layer_info_0.key_offset[4]   = 4;
    force deparser_top.layer_info_0.key_offset_v[5] = 1;
    force deparser_top.layer_info_0.key_offset[5]   = 5;
    force deparser_top.layer_info_0.key_offset_v[6] = 0;
    force deparser_top.layer_info_0.key_offset[6]   = 6;
    force deparser_top.layer_info_0.key_offset_v[7] = 0;
    //* head len;
    force deparser_top.layer_info_0.headShift       = 7;
    //* meta len;
    force deparser_top.layer_info_0.metaShift       = 6;
    
    //* layer_1: IPv4
    //* rule is valid;
    force deparser_top.parser_layer1.lookup_type.r_type_rule[0].typeRule_valid          = 1;
    //* type value;
    force deparser_top.parser_layer1.lookup_type.r_type_rule[0].typeRule_typeData[0]    = 8'h8;
    force deparser_top.parser_layer1.lookup_type.r_type_rule[0].typeRule_typeData[1]    = 8'h0;
    //* type mask;
    force deparser_top.parser_layer1.lookup_type.r_type_rule[0].typeRule_typeMask[0]    = 8'hff;
    force deparser_top.parser_layer1.lookup_type.r_type_rule[0].typeRule_typeMask[1]    = 8'hff;
    //* next type offset;
    force deparser_top.parser_layer1.lookup_type.r_type_rule[0].typeRule_typeOffset[0]  = 9;
    force deparser_top.parser_layer1.lookup_type.r_type_rule[0].typeRule_typeOffset[1]  = 9;
    //* next key offset;
    force deparser_top.parser_layer1.lookup_type.r_type_rule[0].typeRule_keyOffset_v[0] = 1;
    force deparser_top.parser_layer1.lookup_type.r_type_rule[0].typeRule_keyOffset[0]   = 4;
    force deparser_top.parser_layer1.lookup_type.r_type_rule[0].typeRule_keyOffset_v[1] = 1;
    force deparser_top.parser_layer1.lookup_type.r_type_rule[0].typeRule_keyOffset[1]   = 6;
    force deparser_top.parser_layer1.lookup_type.r_type_rule[0].typeRule_keyOffset_v[2] = 1;
    force deparser_top.parser_layer1.lookup_type.r_type_rule[0].typeRule_keyOffset[2]   = 7;
    force deparser_top.parser_layer1.lookup_type.r_type_rule[0].typeRule_keyOffset_v[3] = 1;
    force deparser_top.parser_layer1.lookup_type.r_type_rule[0].typeRule_keyOffset[3]   = 8;
    force deparser_top.parser_layer1.lookup_type.r_type_rule[0].typeRule_keyOffset_v[4] = 1;
    force deparser_top.parser_layer1.lookup_type.r_type_rule[0].typeRule_keyOffset[4]   = 9;
    force deparser_top.parser_layer1.lookup_type.r_type_rule[0].typeRule_keyOffset_v[5] = 0;
    force deparser_top.parser_layer1.lookup_type.r_type_rule[0].typeRule_keyOffset_v[6] = 0;
    force deparser_top.parser_layer1.lookup_type.r_type_rule[0].typeRule_keyOffset_v[7] = 0;
    //* next head len;
    force deparser_top.parser_layer1.lookup_type.r_type_rule[0].typeRule_headShift      = 10;
    //* next meta len;
    force deparser_top.parser_layer1.lookup_type.r_type_rule[0].typeRule_metaShift      = 3;
    
    //* layer_2: TCP
    //* rule is valid;
    force deparser_top.parser_layer2.lookup_type.r_type_rule[0].typeRule_valid       = 1;
    //* type value;
    force deparser_top.parser_layer2.lookup_type.r_type_rule[0].typeRule_typeData[0]    = 8'h6;
    force deparser_top.parser_layer2.lookup_type.r_type_rule[0].typeRule_typeData[1]    = 8'h0;
    //* type mask;
    force deparser_top.parser_layer2.lookup_type.r_type_rule[0].typeRule_typeMask[0]    = 8'hff;
    force deparser_top.parser_layer2.lookup_type.r_type_rule[0].typeRule_typeMask[1]    = 8'h00;
    //* next type offset;
    force deparser_top.parser_layer2.lookup_type.r_type_rule[0].typeRule_typeOffset[0]  = 0;
    force deparser_top.parser_layer2.lookup_type.r_type_rule[0].typeRule_typeOffset[1]  = 0;
    //* next key offset;
    force deparser_top.parser_layer2.lookup_type.r_type_rule[0].typeRule_keyOffset_v[0] = 1;
    force deparser_top.parser_layer2.lookup_type.r_type_rule[0].typeRule_keyOffset[0]   = 0;
    force deparser_top.parser_layer2.lookup_type.r_type_rule[0].typeRule_keyOffset_v[1] = 1;
    force deparser_top.parser_layer2.lookup_type.r_type_rule[0].typeRule_keyOffset[1]   = 1;
    force deparser_top.parser_layer2.lookup_type.r_type_rule[0].typeRule_keyOffset_v[2] = 0;
    force deparser_top.parser_layer2.lookup_type.r_type_rule[0].typeRule_keyOffset_v[3] = 0;
    force deparser_top.parser_layer2.lookup_type.r_type_rule[0].typeRule_keyOffset_v[4] = 0;
    force deparser_top.parser_layer2.lookup_type.r_type_rule[0].typeRule_keyOffset_v[5] = 0;
    force deparser_top.parser_layer2.lookup_type.r_type_rule[0].typeRule_keyOffset_v[6] = 0;
    force deparser_top.parser_layer2.lookup_type.r_type_rule[0].typeRule_keyOffset_v[7] = 0;
    //* next head len;
    force deparser_top.parser_layer2.lookup_type.r_type_rule[0].typeRule_headShift      = 10;
    //* next meta len;
    force deparser_top.parser_layer2.lookup_type.r_type_rule[0].typeRule_metaShift      = 2;

    force deparser_top.layer_info_0.head = 'b0;
    force deparser_top.layer_info_0.meta = 'b0;    
  end

`endif

  // initial begin
  //   #100 begin
  //     force deparser_top.layer_info_0.head = {4'b1101,{TAG_START_BIT{1'b1}}, NORMAL_ARP};
  //     force deparser_top.layer_info_0.meta = {4'b1111,{TAG_START_BIT+META_WIDTH{1'b0}}};
  //   end
  //   #2 begin
  //     force deparser_top.layer_info_0.head = 'b0;
  //     force deparser_top.layer_info_0.meta = 'b0;
  //   end 
  //   #100 begin
  //     force deparser_top.layer_info_0.head = {4'b1101,{TAG_START_BIT{1'b1}}, NORMAL_TCP};
  //     force deparser_top.layer_info_0.meta = {4'b1111,{TAG_START_BIT+META_WIDTH{1'b0}}};
  //   end
  //   #2 begin
  //     force deparser_top.layer_info_0.head = 'b0;
  //     force deparser_top.layer_info_0.meta = 'b0;
  //   end
  // end


endmodule
