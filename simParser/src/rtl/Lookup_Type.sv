/****************************************************/
//  Module name: Lookup_Type
//  Authority @ lijunnan (lijunnan@nudt.edu.cn)
//  Last edited time: 2024/01/02
//  Function outline: 3-stage programmable parser
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
  output  wire  [`KEY_FILED_NUM-1:0][`KEY_OFFSET_WIDTH-1:0] o_result,
  input   wire  [`RULE_NUM-1:0]                             i_rule_wren,
  input   wire                                              i_typeRule_valid,
  input   wire  [`TYPE_NUM-1:0][`TYPE_WIDTH-1:0]            i_typeRule_typeData,
  input   wire  [`TYPE_NUM-1:0][`TYPE_WIDTH-1:0]            i_typeRule_typeMask,
  input   wire  [`KEY_FILED_NUM-1:0][`KEY_OFFSET_WIDTH-1:0] i_typeRule_keyOffset
);


  //====================================================================//
  //*   internal reg/wire/param declarations
  //====================================================================//
  (* mark_debug = "true"*)reg   [`RULE_NUM-1:0]                                          r_rule_valid;
  reg   [`RULE_NUM-1:0][`TYPE_NUM-1:0][`TYPE_WIDTH-1:0]             r_rule_typeData;
  reg   [`RULE_NUM-1:0][`TYPE_NUM-1:0][`TYPE_WIDTH-1:0]             r_rule_typeMask;
  reg   [`RULE_NUM-1:0][`KEY_FILED_NUM-1:0][`KEY_OFFSET_WIDTH-1:0]  r_rule_keyOffset;
  (* mark_debug = "true"*)logic [`RULE_NUM-1:0]                                          w_hit_rule;
  logic [`TYPE_NUM*`TYPE_WIDTH-1:0]                                 w_type;
  logic [`KEY_FILED_NUM-1:0][`KEY_OFFSET_WIDTH-1:0]                 w_result;
  reg   [`KEY_FILED_NUM-1:0][`KEY_OFFSET_WIDTH-1:0]                 r_result;
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
  assign o_result = (LOOKUP_NO_DELAHY)? w_result: r_result;
  always_comb begin
    for(integer j = 0; j < `KEY_FILED_NUM; j++) begin
      w_result[j]   = 'b0;
      for(integer i = 0; i < `RULE_NUM; i++)
        w_result[j] = {`KEY_OFFSET_WIDTH{w_hit_rule[i]}} & r_rule_keyOffset[i][j] | w_result[j];
    end
  end
  always_ff @(posedge i_clk) begin
    r_result        <= w_result;
  end
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//

endmodule