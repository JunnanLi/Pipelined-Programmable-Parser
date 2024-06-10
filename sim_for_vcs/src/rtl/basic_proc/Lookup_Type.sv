/****************************************************/
//  Module name: Lookup_Type
//  Authority @ lijunnan (lijunnan@nudt.edu.cn)
//  Last edited time: 2024/01/02
//  Function outline: lookup type & output resutl
//  Note:
//    1) top bit of i_offset is valid info;
/****************************************************/
import parser_pkg::*;

module Lookup_Type
#(
  parameter     INSERT_ONE_CLK = 0,
  parameter     DEPARSER = 0
)
(
  input   wire                                    i_clk,
  input   wire                                    i_rst_n,
  input   wire  [TYPE_NUM-1:0][TYPE_WIDTH-1:0]    i_type,
  output  lookup_rst_t                            o_lookup_rst,
  input   wire  [RULE_NUM-1:0]                    i_rule_wren,
  input   type_rule_t                             i_type_rule
);


  //====================================================================//
  //*   internal reg/wire/param declarations
  //====================================================================//
  type_rule_t                                     r_type_rule[RULE_NUM-1:0];
  (* mark_debug = "true"*)logic [RULE_NUM-1:0]    w_hit_rule;
  logic [TYPE_NUM*TYPE_WIDTH-1:0]                 w_type;
  lookup_rst_t                                    r_lookup_rst, w_lookup_rst;
  logic [TYPE_NUM-1:0][TYPE_OFFSET_WIDTH-1:0]     w_typeOffset;
  logic [KEY_FILED_NUM-1:0]                       w_keyOffset_v;
  logic [KEY_FILED_NUM-1:0][KEY_OFFSET_WIDTH-1:0] w_keyOffset;
  logic [HEAD_SHIFT_WIDTH-1:0]                    w_headShift;
  logic [META_SHIFT_WIDTH-1:0]                    w_metaShift;
  logic [META_CANDI_NUM-1:0][REP_OFFSET_WIDTH:0]  w_replaceOffset, w_rule_replaceOffset;
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//

  //====================================================================//
  //*   configure rules
  //====================================================================//
  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
      for (integer i = 0; i < RULE_NUM; i++) begin
        r_type_rule[i].typeRule_valid   <= 'b0;
      end
    end else begin
      for (integer i = 0; i < RULE_NUM; i++) begin
         r_type_rule[i]         <= i_rule_wren[i]? i_type_rule: r_type_rule[i];
         r_type_rule[i].typeRule_keyReplaceOffset <= w_rule_replaceOffset;
      end
    end
  end
  //* gen w_rule_replaceOffset
  always_comb begin
    for(integer j=0; j<META_CANDI_NUM; j++) begin
      w_rule_replaceOffset[j]   = 'b0;
      for(integer k=0; k<KEY_FILED_NUM; k++)
        if(i_type_rule.typeRule_keyOffset[k] == j && i_type_rule.typeRule_keyOffset_v[k] == 1'b1) begin
          w_rule_replaceOffset[j][REP_OFFSET_WIDTH]    = 1'b1;
          w_rule_replaceOffset[j][REP_OFFSET_WIDTH-1:0]= w_rule_replaceOffset[j][REP_OFFSET_WIDTH-1:0] | k;
        end
    end
  end
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//

  //====================================================================//
  //*   lookup rules
  //====================================================================//
  //* combine type fields;
  always_comb begin
    for (integer i = 0; i < TYPE_NUM; i++) begin
      w_type[i*TYPE_WIDTH+:TYPE_WIDTH]  = i_type[i]; 
    end
  end
  //* check rules
  always_comb begin
    for (integer i = 0; i < RULE_NUM; i++) begin
      w_hit_rule[i] = r_type_rule[i].typeRule_valid;
      for(integer j = 0; j < TYPE_NUM; j++)
        w_hit_rule[i] = w_hit_rule[i] & ((r_type_rule[i].typeRule_typeMask[j] & i_type[j]) == r_type_rule[i].typeRule_typeData[j]);
    end
  end
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
  
  //====================================================================//
  //*   output result
  //====================================================================//
  assign o_lookup_rst = (INSERT_ONE_CLK)? r_lookup_rst: w_lookup_rst;
  `ifdef RULE_W_PRIORITY
    logic [7:0]  w_hit_rule_8b, w_hit_rule_oneHot;
    generate 
      if(RULE_NUM < 8)
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
      for(integer j = 0; j < KEY_FILED_NUM; j++) begin
        w_keyOffset[j]   = 'b0;
        for(integer i = 0; i < RULE_NUM; i++)
          w_keyOffset[j] = {(KEY_OFFSET_WIDTH+1){w_hit_rule_oneHot[i]}} & r_type_rule[i].typeRule_keyOffset[j] | w_keyOffset[j];
      end
      for(integer j = 0; j < KEY_FILED_NUM; j++) begin
        w_keyOffset_v[j] = 'b0;
        for(integer i = 0; i < RULE_NUM; i++)
          w_keyOffset_v[j] = {(KEY_OFFSET_WIDTH+1){w_hit_rule_oneHot[i]}} & r_type_rule[i].typeRule_keyOffset_v[j] | w_keyOffset_v[j];
      end
      for(integer j = 0; j < TYPE_NUM; j++) begin
        w_typeOffset[j]   = 'b0;
        for(integer i = 0; i < RULE_NUM; i++)
          w_typeOffset[j] = {TYPE_OFFSET_WIDTH{w_hit_rule_oneHot[i]}} & r_type_rule[i].typeRule_typeOffset[j] | w_typeOffset[j];
      end
      w_headShift     = 'b0;
      w_metaShift     = 'b0;
      for(integer i=0; i< RULE_NUM; i++) begin
        w_headShift   = {HEAD_SHIFT_WIDTH{w_hit_rule_oneHot[i]}} & r_type_rule[i].typeRule_headShift | w_headShift;
        w_metaShift   = {HEAD_SHIFT_WIDTH{w_hit_rule_oneHot[i]}} & r_type_rule[i].typeRule_metaShift | w_metaShift;
      end
      for(integer j = 0; j < META_CANDI_NUM; j++) begin
        w_replaceOffset[j]  = 'b0;
        for(integer i = 0; i < RULE_NUM; i++)
          w_replaceOffset[j] = {(REP_OFFSET_WIDTH+1){w_hit_rule_oneHot[i]}} & r_type_rule[i].typeRule_keyReplaceOffset[j] | w_replaceOffset[j];
      end
    end
  `else
    always_comb begin
      for(integer j = 0; j < KEY_FILED_NUM; j++) begin
        w_keyOffset[j]   = 'b0;
        for(integer i = 0; i < RULE_NUM; i++)
          w_keyOffset[j] = {(KEY_OFFSET_WIDTH+1){w_hit_rule[i]}} & r_type_rule[i].typeRule_keyOffset[j] | w_keyOffset[j];
      end
      for(integer j = 0; j < KEY_FILED_NUM; j++) begin
        w_keyOffset_v[j]   = 'b0;
        for(integer i = 0; i < RULE_NUM; i++)
          w_keyOffset_v[j] = {(KEY_OFFSET_WIDTH+1){w_hit_rule[i]}} & r_type_rule[i].typeRule_keyOffset_v[j] | w_keyOffset_v[j];
      end
      for(integer j = 0; j < TYPE_NUM; j++) begin
        w_typeOffset[j]   = 'b0;
        for(integer i = 0; i < RULE_NUM; i++)
          w_typeOffset[j] = {TYPE_OFFSET_WIDTH{w_hit_rule[i]}} & r_type_rule[i].typeRule_typeOffset[j] | w_typeOffset[j];
      end
      w_headShift     = 'b0;
      w_metaShift     = 'b0;
      for(integer i=0; i< RULE_NUM; i++) begin
        w_headShift   = {HEAD_SHIFT_WIDTH{w_hit_rule[i]}} & r_type_rule[i].typeRule_headShift | w_headShift;
        w_metaShift   = {HEAD_SHIFT_WIDTH{w_hit_rule[i]}} & r_type_rule[i].typeRule_metaShift | w_metaShift;
      end
      for(integer j = 0; j < META_CANDI_NUM; j++) begin
        w_replaceOffset[j]  = 'b0;
        for(integer i = 0; i < RULE_NUM; i++)
          w_replaceOffset[j] = {(REP_OFFSET_WIDTH+1){w_hit_rule[i]}} & r_type_rule[i].typeRule_keyReplaceOffset[j] | w_replaceOffset[j];
      end
    end
  `endif
  always_ff @(posedge i_clk) begin
    r_lookup_rst.typeOffset <= w_typeOffset;
    r_lookup_rst.keyOffset_v<= w_keyOffset_v;
    r_lookup_rst.keyOffset  <= w_keyOffset;
    r_lookup_rst.headShift  <= w_headShift;
    r_lookup_rst.metaShift  <= w_metaShift;
  end
  if(DEPARSER) begin
    always_ff @(posedge i_clk) begin
      r_lookup_rst.replaceOffset <= w_replaceOffset;
    end
  end
  else begin
    always_ff @(posedge i_clk) begin
      r_lookup_rst.replaceOffset <= 'b0;
    end
  end
  assign w_lookup_rst.typeOffset  = w_typeOffset;
  assign w_lookup_rst.keyOffset_v = w_keyOffset_v;
  assign w_lookup_rst.keyOffset   = w_keyOffset;
  assign w_lookup_rst.headShift   = w_headShift;
  assign w_lookup_rst.metaShift   = w_metaShift;
  if(DEPARSER) begin
    assign w_lookup_rst.replaceOffset = w_replaceOffset;
  end
  else begin
    assign w_lookup_rst.replaceOffset = 'b0;
  end
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//

endmodule