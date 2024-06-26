/*************************************************************/
//  Module name: Parser_Layer
//  Authority @ lijunnan (lijunnan@nudt.edu.cn)
//  Last edited time: 2024/01/01
//  Function outline: Parse one protocol
//  Note:
//    1) TWO_CYCLE_PER_LAYER is used to insert 1 clk between 
//        type lookup and key-field extraction;
//    2) top bit of w_key_offset is valid info;
//    3) TODO, reading rules;
/*************************************************************/


//================================================================//
//*         p1 stage              p2    Connection Relationship   //
//*  +---------------+        +-------------+                     //
//*  | Extract_Field | types  | Lookup_Type |  next extract info  //
//*  | ( type field) |------->| ( rules )   |--------->           //
//*  +---------------+        +-------------+                     //
//*           ↑                       ↑     +-------------+       //
//*    head---+            types &&   +-----| Rule_Conf   |       //
//*  (input)  ↓            extract offset   +-------------+       //
//*  +---------------+ key    +---------------+                   //
//*  | Extract_Field | fields | Merge Field & |  new head & meta  //
//*  | ( key field ) |------->| Shift Header  |--------->         //
//*  +---------------+        +---------------+                   //
//================================================================//

import parser_pkg::*;

module Parser_Layer(
  input   wire            i_clk,
  input   wire            i_rst_n,
  //---conf--//
  input   wire            i_rule_wren,
  input   wire            i_rule_rden,
  input   wire  [31:0]    i_rule_addr,
  input   wire  [31:0]    i_rule_wdata,
  output  wire            o_rule_rdata_valid,
  output  wire  [31:0]    o_rule_rdata,
  
  input   layer_info_t    i_layer_info,
  output  layer_info_t    o_layer_info
);

  //====================================================================//
  //*   internal reg/wire/param declarations
  //====================================================================//
  //* lookup result: o_type_offset & o_key_offset & o_headShift & o_metaShift
  //* extract field: type & keyField: w_type_field, w_key_field
  (* mark_debug = "true"*)wire  [TYPE_NUM-1:0][TYPE_WIDTH-1:0]              w_type_field;
  (* mark_debug = "true"*)wire  [KEY_FILED_NUM-1:0][KEY_FIELD_WIDTH-1:0]    w_key_field;
  wire  [KEY_FILED_NUM*KEY_FIELD_WIDTH-1:0]         w_extField;
  //* conf rules
  (* mark_debug = "true"*)wire  [RULE_NUM-1:0]      w_typeRule_wren;
  type_rule_t                                       typeRule;
  //* format change
  logic [TYPE_CANDI_NUM-1:0][TYPE_WIDTH-1:0]        w_headType;
  logic [KEY_CANDI_NUM-1:0][KEY_FIELD_WIDTH-1:0]    w_headKey;
  //* insert 1 clk
  logic [HEAD_WIDTH+TAG_WIDTH-1:0]                  l_head;
  logic [HEAD_WIDTH+TAG_WIDTH-1:0]                  l_meta;
  logic [HEAD_SHIFT_WIDTH-1:0]                      l_headShift;
  logic [META_SHIFT_WIDTH-1:0]                      l_metaShift;
  lookup_rst_t                                      lookup_rst_s0, lookup_rst_s1, lookup_rst_s2;
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//

  genvar idx;
  generate for (idx = 0; idx < TYPE_NUM; idx=idx+1) begin : gen_extract_type
    Extract_Field 
    #(
    `ifdef TWO_CYCLE_PER_LAYER
      .INSERT_ONE_CLK   (1'b1               ),
    `endif
      .CANDI_NUM        (TYPE_CANDI_NUM    ),
      .OFFSET_WIDTH     (TYPE_OFFSET_WIDTH ),
      .EXTRACT_WIDTH    (TYPE_WIDTH        )
    )
    extract_type_field (
      .i_clk            (i_clk              ),
      .i_rst_n          (i_rst_n            ),
      .i_data           (w_headType         ),
      .o_extract_data   (w_type_field[idx]  ),
      .i_offset         ({1'b1,i_layer_info.type_offset[idx]} )
    );
    end
  endgenerate
  generate for (idx = 0; idx < KEY_FILED_NUM; idx=idx+1) begin : gen_extract_field
    Extract_Field 
    #(
    `ifdef TWO_CYCLE_PER_LAYER
      .INSERT_ONE_CLK   (1'b1               ),
    `endif
      .CANDI_NUM        (KEY_CANDI_NUM     ),
      .OFFSET_WIDTH     (KEY_OFFSET_WIDTH  ),
      .EXTRACT_WIDTH    (KEY_FIELD_WIDTH   )
    )
    extract_key_field (
      .i_clk            (i_clk              ),
      .i_rst_n          (i_rst_n            ),
      .i_data           (w_headKey          ),
      .o_extract_data   (w_key_field[idx]   ),
      .i_offset         ({i_layer_info.key_offset_v[idx],
                          i_layer_info.key_offset[idx]} )
    );
    end
  endgenerate

  Lookup_Type 
  #(.INSERT_ONE_CLK       (1'b0                   ))
  lookup_type(
    .i_clk                (i_clk                  ),
    .i_rst_n              (i_rst_n                ),
    .i_type               (w_type_field           ),
    .o_lookup_rst         (lookup_rst_s0          ),
    .i_rule_wren          (w_typeRule_wren        ),
    .i_type_rule          (typeRule               )
  );

  Shift_Head shift_head(
    .i_clk                (i_clk                  ),
    .i_rst_n              (i_rst_n                ),
    .i_head               (l_head                 ),
    .o_head               (o_layer_info.head      ),
    .i_headShift          (l_headShift            ),
    .i_meta               (l_meta                 ),
    .o_meta               (o_layer_info.meta      ),
    .i_extField           (w_extField             ),
    .i_metaShift          (l_metaShift            )
  );

  Rule_Conf rule_conf(
    .i_clk                (i_clk                  ),
    .i_rst_n              (i_rst_n                ),
    .i_rule_wren          (i_rule_wren            ),
    .i_rule_wdata         (i_rule_wdata           ),
    .i_rule_addr          (i_rule_addr            ),
    .o_typeRule_wren      (w_typeRule_wren        ),
    .o_type_rule          (typeRule               )
  );

  assign o_rule_rdata_valid = i_rule_rden;
  assign o_rule_rdata       = 64'b0;

  //* assign w_extField;
  generate for (idx = 0; idx < KEY_FILED_NUM; idx=idx+1) begin : gen_meta
    assign w_extField[(KEY_FILED_NUM-idx)*KEY_FIELD_WIDTH-1-:KEY_FIELD_WIDTH] = w_key_field[idx];
  end
  endgenerate

  always_comb begin
    for(integer i=0; i<TYPE_CANDI_NUM; i=i+1)
      w_headType[i]         = i_layer_info.head[(TYPE_CANDI_NUM-i-1)*TYPE_WIDTH+:TYPE_WIDTH];
    for(integer i=0; i<KEY_CANDI_NUM; i=i+1)
      w_headKey[i]          = i_layer_info.head[(KEY_CANDI_NUM-i-1)*KEY_FIELD_WIDTH+:KEY_FIELD_WIDTH];
  end

  //* insert one cycle;
  `ifdef TWO_CYCLE_PER_LAYER
    always_ff @(posedge i_clk) begin
      l_head                <= i_layer_info.head;
      l_meta                <= i_layer_info.meta;
      l_headShift           <= i_layer_info.headShift;
      l_metaShift           <= i_layer_info.metaShift;
    end
  `else
    always_comb begin
      l_head                = i_layer_info.head;
      l_meta                = i_layer_info.meta;
      l_headShift           = i_layer_info.headShift;
      l_metaShift           = i_layer_info.metaShift;
    end
  `endif

  //* shift stage
  assign o_layer_info.key_offset_v = lookup_rst_s2.keyOffset_v;
  assign o_layer_info.key_offset   = lookup_rst_s2.keyOffset;
  assign o_layer_info.type_offset  = lookup_rst_s2.typeOffset;
  assign o_layer_info.headShift    = lookup_rst_s2.headShift;
  assign o_layer_info.metaShift    = lookup_rst_s2.metaShift;
  always_ff @(posedge i_clk) begin
    lookup_rst_s1                 <= lookup_rst_s0;
    lookup_rst_s2                 <= lookup_rst_s1;
  end

endmodule