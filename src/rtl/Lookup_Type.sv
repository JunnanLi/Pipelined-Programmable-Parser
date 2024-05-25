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
  input   wire                                            i_clk,
  input   wire                                            i_rst_n,
  input   wire  [TYPE_NUM-1:0][TYPE_WIDTH-1:0]            i_type,
  output  reg   [TYPE_NUM-1:0][TYPE_OFFSET_WIDTH-1:0]     o_typeOffset,
  output  wire  [KEY_FILED_NUM-1:0][KEY_OFFSET_WIDTH:0]   o_keyOffset,
  output  wire  [HEAD_SHIFT_WIDTH-1:0]                    o_headShift,
  output  wire  [META_SHIFT_WIDTH-1:0]                    o_metaShift,
  input   wire  [RULE_NUM-1:0]                            i_rule_wren,
  input   type_rule_t                                     i_type_rule
);


  //====================================================================//
  //*   internal reg/wire/param declarations
  //====================================================================//
  (* mark_debug = "true"*)reg   [RULE_NUM-1:0]                                          r_rule_valid;
  type_rule_t   r_type_rule[RULE_NUM-1:0];
  // reg   [RULE_NUM-1:0][TYPE_NUM-1:0][TYPE_WIDTH-1:0]            r_rule_typeData;
  // reg   [RULE_NUM-1:0][TYPE_NUM-1:0][TYPE_WIDTH-1:0]            r_rule_typeMask;
  // reg   [RULE_NUM-1:0][TYPE_NUM-1:0][TYPE_OFFSET_WIDTH-1:0]     r_rule_typeOffset;
  // reg   [RULE_NUM-1:0][KEY_FILED_NUM-1:0][KEY_OFFSET_WIDTH:0]   r_rule_keyOffset;
  // reg   [RULE_NUM-1:0][HEAD_SHIFT_WIDTH-1:0]                    r_rule_headShift;
  // reg   [RULE_NUM-1:0][META_SHIFT_WIDTH-1:0]                    r_rule_metaShift;
  (* mark_debug = "true"*)logic [RULE_NUM-1:0]                                          w_hit_rule;
  logic [TYPE_NUM*TYPE_WIDTH-1:0]                                 w_type;
  logic [TYPE_NUM-1:0][TYPE_OFFSET_WIDTH-1:0]                     w_typeOffset;
  logic [KEY_FILED_NUM-1:0][KEY_OFFSET_WIDTH:0]                   w_keyOffset;
  logic [HEAD_SHIFT_WIDTH-1:0]                                    w_headShift;
  logic [META_SHIFT_WIDTH-1:0]                                    w_metaShift;
  reg   [TYPE_NUM-1:0][TYPE_OFFSET_WIDTH-1:0]                     r_typeOffset;
  reg   [KEY_FILED_NUM-1:0][KEY_OFFSET_WIDTH:0]                   r_keyOffset;
  reg   [HEAD_SHIFT_WIDTH-1:0]                                    r_headShift;
  reg   [META_SHIFT_WIDTH-1:0]                                    r_metaShift;
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
         // r_rule_valid[i]        <= i_rule_wren[i]? i_typeRule_valid:      r_rule_valid[i];
         // r_rule_typeData[i]     <= i_rule_wren[i]? i_typeRule_typeData:   r_rule_typeData[i];
         // r_rule_typeMask[i]     <= i_rule_wren[i]? i_typeRule_typeMask:   r_rule_typeMask[i];
         // r_rule_typeOffset[i]   <= i_rule_wren[i]? i_typeRule_typeOffset: r_rule_typeOffset[i];
         // r_rule_keyOffset[i]    <= i_rule_wren[i]? i_typeRule_keyOffset:  r_rule_keyOffset[i];
         // r_rule_headShift[i]    <= i_rule_wren[i]? i_typeRule_headShift:  r_rule_headShift[i];
         // r_rule_metaShift[i]    <= i_rule_wren[i]? i_typeRule_metaShift:  r_rule_metaShift[i];
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
  assign o_typeOffset = (INSERT_ONE_CLK)? r_typeOffset: w_typeOffset;
  assign o_keyOffset  = (INSERT_ONE_CLK)? r_keyOffset:  w_keyOffset;
  assign o_headShift  = (INSERT_ONE_CLK)? r_headShift:  w_headShift;
  assign o_metaShift  = (INSERT_ONE_CLK)? r_metaShift:  w_metaShift;
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
    end
  `else
    always_comb begin
      for(integer j = 0; j < KEY_FILED_NUM; j++) begin
        w_keyOffset[j]   = 'b0;
        for(integer i = 0; i < RULE_NUM; i++)
          w_keyOffset[j] = {(KEY_OFFSET_WIDTH+1){w_hit_rule[i]}} & r_type_rule[i].typeRule_keyOffset[j] | w_keyOffset[j];
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
    end
  `endif
  always_ff @(posedge i_clk) begin
    r_typeOffset      <= w_typeOffset;
    r_keyOffset       <= w_keyOffset;
    r_headShift       <= w_headShift;
    r_metaShift       <= w_metaShift;
  end
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//

endmodule