/*************************************************************/
//  Module name: Parser_Top
//  Authority @ lijunnan (lijunnan@nudt.edu.cn)
//  Last edited time: 2024/03/04
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
import "DPI-C" function void sim_to_read_head(int layerID, int tag_start, int slice_id, 
  byte unsigned data_head[]);
import "DPI-C" function void sim_to_read_meta(int layerID, int tag_start, int tag_end, int slice_id,
  byte unsigned data_meta[]);
// import "DPI-C" function void sim_to_check_rst(int layerID, byte unsigned data[]);
//* TODO,
import "DPI-C" function void sim_to_read_rule(int layerID, int ruleID, int ruleValid,
  int unsigned typeData[], int unsigned typeMask[], int unsigned typeOffset[],
  int unsigned keyOffset_v[], int unsigned keyOffset[], int unsigned keyReplaceOffset[],
  int headShift, int metaShift);

module Parser_Top(
  input   wire                                i_clk,
  input   wire                                i_rst_n,
  //---conf--//
  input   wire                                i_rule_valid,
  input   wire  [7:0]                         i_layerID,
  input   wire  [RULE_NUM-1:0]                i_ruleID,
  input   type_rule_t                         i_type_rule,
  //--data--//
  input   wire  [HEAD_WIDTH+TAG_WIDTH-1:0]    i_head,
  output  wire  [HEAD_WIDTH+TAG_WIDTH-1:0]    o_head,
  input   wire  [META_WIDTH+TAG_WIDTH-1:0]    i_meta,
  output  wire  [META_WIDTH+TAG_WIDTH-1:0]    o_meta
);

  //====================================================================//
  //*   internal reg/wire/param declarations
  //====================================================================//
  layer_info_t  layer_info_0, layer_info_1, layer_info_2, layer_info_3;
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
  assign layer_info_0.head = i_head;
  assign layer_info_0.meta = i_meta;
  assign o_head = layer_info_3.head;
  assign o_meta = layer_info_3.meta;
  //* layer 1: ethernet
  Parser_Layer #(
    .LAYER_ID(1)
  )
  parser_layer1(
    .i_clk                (i_clk          ),
    .i_rst_n              (i_rst_n        ),
    //---conf--//
    .i_rule_valid         (i_rule_valid & 
                            i_layerID == LAYER_1 ),
    .i_rule_wren          (i_ruleID       ),
    .i_type_rule          (i_type_rule    ),
    
    .i_layer_info         (layer_info_0   ),
    .o_layer_info         (layer_info_1   )
  );
  //* layer 2: ip/arp
  Parser_Layer #(
    .LAYER_ID(2)
  )
  parser_layer2(
    .i_clk                (i_clk          ),
    .i_rst_n              (i_rst_n        ),
    //---conf--//
    .i_rule_valid         (i_rule_valid & 
                            i_layerID == LAYER_2 ),
    .i_rule_wren          (i_ruleID       ),
    .i_type_rule          (i_type_rule    ),

    .i_layer_info         (layer_info_1   ),
    .o_layer_info         (layer_info_2   )
  );  
  //* layer 3: tcp/udp
  Parser_Layer #(
    .LAYER_ID(3)
  )
  parser_layer3(
    .i_clk                (i_clk          ),
    .i_rst_n              (i_rst_n        ),
    //---conf--//
    .i_rule_valid         (i_rule_valid & 
                            i_layerID == LAYER_3 ),
    .i_rule_wren          (i_ruleID       ),
    .i_type_rule          (i_type_rule    ),

    .i_layer_info         (layer_info_2   ),
    .o_layer_info         (layer_info_3   )
  );

  always_ff @(posedge i_clk ) begin: layer_0
    if(i_rule_valid == 1'b1 && i_layerID == LAYER_0 ) begin
      layer_info_0.type_offset    <= i_type_rule.typeRule_typeOffset;
      layer_info_0.key_offset_v   <= i_type_rule.typeRule_keyOffset_v;
      layer_info_0.key_offset     <= i_type_rule.typeRule_keyOffset;
      layer_info_0.headShift      <= i_type_rule.typeRule_headShift;
      layer_info_0.metaShift      <= i_type_rule.typeRule_metaShift;
    end
    else begin
      layer_info_0.type_offset    <= layer_info_0.type_offset;
      layer_info_0.key_offset_v   <= layer_info_0.key_offset_v;
      layer_info_0.key_offset     <= layer_info_0.key_offset;
      layer_info_0.headShift      <= layer_info_0.headShift ;
      layer_info_0.metaShift      <= layer_info_0.metaShift ;
    end
  end


  //* for sim;
  byte unsigned data_head[63:0], data_meta[63:0];
  wire tag_start = layer_info_0.head[TAG_START_BIT + HEAD_WIDTH];
  wire tag_valid_head = layer_info_0.head[TAG_VALID_BIT + HEAD_WIDTH];
  wire tag_valid_meta = layer_info_0.meta[TAG_VALID_BIT + HEAD_WIDTH];
  reg [31:0]  slice_id;
  always_ff @(posedge i_clk) begin
    if(tag_start) begin
      slice_id <= 32'b0;
      sim_to_read_head(0,tag_start,slice_id,data_head);
      sim_to_read_meta(0,tag_start,0,slice_id,data_meta);
    end
    else if(tag_valid_head) begin
      slice_id <= slice_id + 32'd1;
      sim_to_read_head(0,tag_start,slice_id,data_head);
      if(tag_valid_meta)
        sim_to_read_meta(0,tag_start,0,slice_id,data_meta);
    end
  end
  //* read head/meta
  always_comb begin
    for(integer i=0; i<64; i=i+1) begin
      data_head[i] = layer_info_0.head[512-i*8-1-:8];
      data_meta[i] = layer_info_0.meta[512-i*8-1-:8];
    end
  end
  //* read rules
  int ruleValid, headShift, metaShift;
  int unsigned typeData[TYPE_NUM-1:0], typeMask[TYPE_NUM-1:0], typeOffset[TYPE_NUM-1:0];
  int unsigned keyOffset_v[KEY_FILED_NUM-1:0], keyOffset[KEY_FILED_NUM-1:0],
                keyReplaceOffset[KEY_FILED_NUM-1:0];
  reg [31:0]  r_cnt;
  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
      r_cnt <= 32'b0;
    end
    else begin
      r_cnt <= 32'd1 + r_cnt;
      if(r_cnt == 0)
        sim_to_read_rule(0,0,ruleValid,typeData,typeMask,typeOffset,
          keyOffset_v, keyOffset, keyReplaceOffset, headShift,metaShift);
    end
  end
  always_comb begin
    ruleValid = 1'b1;
    for(integer i=0; i<TYPE_NUM; i=i+1) begin
      typeData[i] = 'b0;
      typeMask[i] = 'b0;
      typeOffset[i] = layer_info_0.type_offset[i];
    end
    for(integer i=0; i<KEY_FILED_NUM; i=i+1) begin
      keyOffset_v[i] = layer_info_0.key_offset_v[i];
      keyOffset[i] = layer_info_0.key_offset[i];
      keyReplaceOffset[i] = 'b0;
    end
    headShift = layer_info_0.headShift;
    metaShift = layer_info_0.metaShift;
  end

endmodule
