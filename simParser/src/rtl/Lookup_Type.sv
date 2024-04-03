/****************************************************/
//  Module name: Lookup_Type
//  Authority @ lijunnan (lijunnan@nudt.edu.cn)
//  Last edited time: 2024/01/02
//  Function outline: lookup type & output resutl
//  Note:
//    1) top bit of i_offset is valid info;
/****************************************************/


`timescale 1ns/1ps


module Lookup_Type
#(
  parameter     LOOKUP_NO_DELAHY= 1
)
(
  input   wire                                              i_clk,
  input   wire                                              i_rst_n,
  input   wire  [`TYPE_NUM-1:0][`TYPE_WIDTH-1:0]            i_type,
  output  wire  [`KEY_FILED_NUM-1:0][`KEY_OFFSET_WIDTH:0]   o_result,
  output  wire  [`HEAD_SHIFT_WIDTH-1:0]                     o_headShift,
  output  wire  [`META_SHIFT_WIDTH-1:0]                     o_metaShift,
  input   wire  [`RULE_NUM-1:0]                             i_rule_wren,
  input   wire                                              i_typeRule_valid,
  input   wire  [`TYPE_NUM-1:0][`TYPE_WIDTH-1:0]            i_typeRule_typeData,
  input   wire  [`TYPE_NUM-1:0][`TYPE_WIDTH-1:0]            i_typeRule_typeMask,
  input   wire  [`KEY_FILED_NUM-1:0][`KEY_OFFSET_WIDTH:0]   i_typeRule_keyOffset,
  input   wire  [`HEAD_SHIFT_WIDTH-1:0]                     i_typeRule_headShift,
  input   wire  [`META_SHIFT_WIDTH-1:0]                     i_typeRule_metaShift
);


  //====================================================================//
  //*   internal reg/wire/param declarations
  //====================================================================//
  (* mark_debug = "true"*)reg   [`RULE_NUM-1:0]                                          r_rule_valid;
  reg   [`RULE_NUM-1:0][`TYPE_NUM-1:0][`TYPE_WIDTH-1:0]             r_rule_typeData;
  reg   [`RULE_NUM-1:0][`TYPE_NUM-1:0][`TYPE_WIDTH-1:0]             r_rule_typeMask;
  reg   [`RULE_NUM-1:0][`KEY_FILED_NUM-1:0][`KEY_OFFSET_WIDTH:0]    r_rule_keyOffset;
  reg   [`RULE_NUM-1:0][`HEAD_SHIFT_WIDTH-1:0]                      r_rule_headShift;
  reg   [`RULE_NUM-1:0][`META_SHIFT_WIDTH-1:0]                      r_rule_metaShift;
  (* mark_debug = "true"*)logic [`RULE_NUM-1:0]                                          w_hit_rule;
  logic [`TYPE_NUM*`TYPE_WIDTH-1:0]                                 w_type;
  logic [`KEY_FILED_NUM-1:0][`KEY_OFFSET_WIDTH:0]                   w_result;
  logic [`HEAD_SHIFT_WIDTH-1:0]                                     w_headShift;
  logic [`META_SHIFT_WIDTH-1:0]                                     w_metaShift;
  reg   [`KEY_FILED_NUM-1:0][`KEY_OFFSET_WIDTH:0]                   r_result;
  reg   [`HEAD_SHIFT_WIDTH-1:0]                                     r_headShift;
  reg   [`META_SHIFT_WIDTH-1:0]                                     r_metaShift;
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//

  //====================================================================//
  //*   configure rules
  //====================================================================//
  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
      for (integer i = 0; i < `RULE_NUM; i++) begin
        r_rule_valid[i]         <= 'b0;
      end
    end else begin
      for (integer i = 0; i < `RULE_NUM; i++) begin
         r_rule_valid[i]        <= i_rule_wren[i]? i_typeRule_valid:    r_rule_valid[i];
         r_rule_typeData[i]     <= i_rule_wren[i]? i_typeRule_typeData: r_rule_typeData[i];
         r_rule_typeMask[i]     <= i_rule_wren[i]? i_typeRule_typeMask: r_rule_typeMask[i];
         r_rule_keyOffset[i]    <= i_rule_wren[i]? i_typeRule_keyOffset:r_rule_keyOffset[i];
         r_rule_headShift[i]    <= i_rule_wren[i]? i_typeRule_headShift:r_rule_headShift[i];
         r_rule_metaShift[i]    <= i_rule_wren[i]? i_typeRule_metaShift:r_rule_metaShift[i];
      end
    end
  end
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//

  //====================================================================//
  //*   lookup rules
  //====================================================================//
  //* combine type fields;
  always_comb begin
    for (integer i = 0; i < `TYPE_NUM; i++) begin
      w_type[i*`TYPE_WIDTH+:`TYPE_WIDTH]  = i_type[i]; 
    end
  end
  //* check rules
  always_comb begin
    for (integer i = 0; i < `RULE_NUM; i++) begin
      w_hit_rule[i] = r_rule_valid[i];
      for(integer j = 0; j < `TYPE_NUM; j++)
        w_hit_rule[i] = w_hit_rule[i] & ((r_rule_typeMask[i][j] & i_type[j]) == r_rule_typeData[i][j]);
    end
  end
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
  
  //====================================================================//
  //*   output result
  //====================================================================//
  assign o_result     = (LOOKUP_NO_DELAHY)? w_result: r_result;
  assign o_headShift  = (LOOKUP_NO_DELAHY)? w_headShift: r_headShift;
  assign o_metaShift  = (LOOKUP_NO_DELAHY)? w_metaShift: r_metaShift;
  `ifdef RULE_W_PRIORITY
    logic [7:0]  w_hit_rule_8b, w_hit_rule_oneHot;
    generate 
      if(`RULE_NUM < 8)
        assign w_hit_rule_8b  = {{{1'b0}},w_hit_rule};
      else
        assign w_hit_rule_8b  = w_hit_rule[7:0];
    endgenerate
    //* gen w_hit_rule_oneHot
    always_comb begin
      case(w_hit_rule_8b) inside
        8'b????_???1: w_hit_rule_oneHot = 8'h1;
        8'b????_??10: w_hit_rule_oneHot = 8'h2;
        8'b????_?100: w_hit_rule_oneHot = 8'h4;
        8'b????_1000: w_hit_rule_oneHot = 8'h8;
        8'b???1_0000: w_hit_rule_oneHot = 8'h10;
        8'b??10_0000: w_hit_rule_oneHot = 8'h20;
        8'b?100_0000: w_hit_rule_oneHot = 8'h40;
        8'b1000_0000: w_hit_rule_oneHot = 8'h80;
        default:      w_hit_rule_oneHot = 8'h0;
      endcase
    end
    //* get result
    always_comb begin
      for(integer j = 0; j < `KEY_FILED_NUM; j++) begin
        w_result[j]   = 'b0;
        for(integer i = 0; i < `RULE_NUM; i++)
          w_result[j] = {(`KEY_OFFSET_WIDTH+1){w_hit_rule_oneHot[i]}} & r_rule_keyOffset[i][j] | w_result[j];
      end
      w_headShift     = 'b0;
      w_metaShift     = 'b0;
      for(integer i=0; i< `RULE_NUM; i++) begin
        w_headShift   = {`HEAD_SHIFT_WIDTH{w_hit_rule_oneHot[i]}} & r_rule_headShift[i] | w_headShift;
        w_metaShift   = {`HEAD_SHIFT_WIDTH{w_hit_rule_oneHot[i]}} & r_rule_metaShift[i] | w_metaShift;
      end
    end
  `else
    always_comb begin
      for(integer j = 0; j < `KEY_FILED_NUM; j++) begin
        w_result[j]   = 'b0;
        for(integer i = 0; i < `RULE_NUM; i++)
          w_result[j] = {(`KEY_OFFSET_WIDTH+1){w_hit_rule[i]}} & r_rule_keyOffset[i][j] | w_result[j];
      end
      w_headShift     = 'b0;
      w_metaShift     = 'b0;
      for(integer i=0; i< `RULE_NUM; i++) begin
        w_headShift   = {`HEAD_SHIFT_WIDTH{w_hit_rule[i]}} & r_rule_headShift[i] | w_headShift;
        w_metaShift   = {`HEAD_SHIFT_WIDTH{w_hit_rule[i]}} & r_rule_metaShift[i] | w_metaShift;
      end
    end
  `endif
  always_ff @(posedge i_clk) begin
    r_result          <= w_result;
    r_headShift       <= w_headShift;
    r_metaShift       <= w_metaShift;
  end
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//

endmodule