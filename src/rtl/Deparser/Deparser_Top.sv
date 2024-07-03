/*************************************************************/
//  Module name: Deparser_Top
//  Authority @ lijunnan (lijunnan@nudt.edu.cn)
//  Last edited time: 2024/04/11
//  Function outline: Top module of Pipelined-Packet-Parser
//  Note:
//    1) head tag:
//      a) TAG_VALID_BIT: head/meta is valid
//      b) TAG_SHIFT_BIT: to shift head/meta
//      c) TAG_TAIL_BIT:  tail  of head/meta
//      d) TAG_START_BIT: start of head/meta
//      e) TAG_OFFSET:    last valid data of head/meta's slice
//    2) rule's addr [31:24] is used to choose parser layer
/*************************************************************/

import parser_pkg::*;

module Deparser_Top(
  input   wire                              i_clk,
  input   wire                              i_rst_n,
  //---conf--//
  input   wire                              i_rule_valid,
  input   wire  [7:0]                       i_layerID,
  input   wire  [RULE_NUM-1:0]              i_ruleID,
  input   type_rule_t                       i_type_rule,
  //--data--//
  input   wire  [HEAD_WIDTH+TAG_WIDTH-1:0]  i_head,
  output  wire  [HEAD_WIDTH+TAG_WIDTH-1:0]  o_head,
  input   wire  [META_WIDTH+TAG_WIDTH-1:0]  i_meta,
  output  wire  [META_WIDTH+TAG_WIDTH-1:0]  o_meta
);

  //====================================================================//
  //*   internal reg/wire/param declarations
  //====================================================================//
  layer_info_t  layer_info_0, layer_info_1, layer_info_2, layer_info_3;
  reg   [KEY_FILED_NUM-1:0][KEY_OFFSET_WIDTH-1:0] r_key_ReplaceOffset;
  logic [META_CANDI_NUM-1:0][REP_OFFSET_WIDTH-1:0]l_key_replaceOffset;
  logic [META_CANDI_NUM-1:0]                      l_key_replaceOffset_v;
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
  assign layer_info_0.head = i_head;
  assign layer_info_0.meta = i_meta;
  assign o_head = layer_info_3.head;
  assign o_meta = layer_info_3.meta;
  
  //* layer 1: ethernet
  Deparser_Layer deparser_layer1(
    .i_clk                (i_clk          ),
    .i_rst_n              (i_rst_n        ),
    //---conf--//
    .i_rule_valid         (i_rule_valid & 
                            i_ruleID == LAYER_1 ),
    .i_rule_wren          (i_ruleID       ),
    .i_type_rule          (i_type_rule    ),
    
    .i_layer_info         (layer_info_0   ),
    .o_layer_info         (layer_info_1   )
  );
  //* layer 2: ip/arp
  Deparser_Layer deparser_layer2(
    .i_clk                (i_clk          ),
    .i_rst_n              (i_rst_n        ),
    //---conf--//
    .i_rule_valid         (i_rule_valid & 
                            i_ruleID == LAYER_2 ),
    .i_rule_wren          (i_ruleID       ),
    .i_type_rule          (i_type_rule    ),

    .i_layer_info         (layer_info_1   ),
    .o_layer_info         (layer_info_2   )
  );  
  //* layer 3: tcp/udp
  Deparser_Layer deparser_layer3(
    .i_clk                (i_clk          ),
    .i_rst_n              (i_rst_n        ),
    //---conf--//
    .i_rule_valid         (i_rule_valid & 
                            i_ruleID == LAYER_3 ),
    .i_rule_wren          (i_ruleID       ),
    .i_type_rule          (i_type_rule    ),

    .i_layer_info         (layer_info_2   ),
    .o_layer_info         (layer_info_3   )
  );

  //* gen w_rule_replaceOffset
  always_comb begin
    for(integer j=0; j<META_CANDI_NUM; j++) begin
      l_key_replaceOffset[j]   = 'b0;
      for(integer k=0; k<KEY_FILED_NUM; k++)
        if(r_key_ReplaceOffset[k] == j && layer_info_0.key_offset_v[k] == 1'b1) begin
          l_key_replaceOffset_v[j]  = 1'b1;
          l_key_replaceOffset[j]    = l_key_replaceOffset[j] | k;
        end
    end
  end
  
  always_ff @(posedge i_clk ) begin: layer_0
    layer_info_0.key_replaceOffset        <= l_key_replaceOffset;
    layer_info_0.key_replaceOffset_v      <= l_key_replaceOffset_v;
    layer_info_0.key_replaceOffset_carry  <= 1'b0;
    layer_info_0.total_metaShift          <= 'b0;
    layer_info_0.metaShift_carry          <= 1'b0;
    if(i_rule_valid == 1'b1 && i_layerID == LAYER_0 ) begin
      layer_info_0.type_offset    <= i_type_rule.typeRule_typeOffset;
      layer_info_0.key_offset_v   <= i_type_rule.typeRule_keyOffset_v;
      layer_info_0.key_offset     <= i_type_rule.typeRule_keyOffset;
      layer_info_0.headShift      <= i_type_rule.typeRule_headShift;
      layer_info_0.metaShift      <= i_type_rule.typeRule_metaShift;
      r_key_ReplaceOffset         <= i_type_rule.typeRule_keyReplaceOffset;
    end
    else begin
      layer_info_0.type_offset    <= layer_info_0.type_offset;
      layer_info_0.key_offset_v   <= layer_info_0.key_offset_v;
      layer_info_0.key_offset     <= layer_info_0.key_offset;
      layer_info_0.headShift      <= layer_info_0.headShift ;
      layer_info_0.metaShift      <= layer_info_0.metaShift ;
      r_key_ReplaceOffset         <= r_key_ReplaceOffset;
    end
  end

endmodule