/*************************************************************/
//  Module name: Deparser_Layer
//  Authority @ lijunnan (lijunnan@nudt.edu.cn)
//  Last edited time: 2024/04/11
//  Function outline: Deparse one protocol
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


module Deparser_Layer(
  input   wire                      i_clk,
  input   wire                      i_rst_n,
  //---conf--//
  input   wire                      i_rule_wren,
  input   wire                      i_rule_rden,
  input   wire  [31:0]              i_rule_addr,
  input   wire  [31:0]              i_rule_wdata,
  output  wire                      o_rule_rdata_valid,
  output  wire  [31:0]              o_rule_rdata,
  
  input   deparser_layer_info_t     i_layer_info,
  output  deparser_layer_info_t     o_layer_info
  
);

  //====================================================================//
  //*   internal reg/wire/param declarations
  //====================================================================//
  //* lookup result: o_type_offset & o_key_offset & o_headShift & o_metaShift
  //* extract field: type & keyField: w_type_field, w_key_field
  (* mark_debug = "true"*)wire  [TYPE_NUM-1:0][TYPE_WIDTH-1:0]              w_type_field;
  (* mark_debug = "true"*)wire  [KEY_FILED_NUM-1:0][KEY_FIELD_WIDTH-1:0]    w_key_field;
  //* conf rules
  (* mark_debug = "true"*)wire  [RULE_NUM-1:0]                              w_typeRule_wren;
  deparser_rule_t typeRule;
  // wire                                              w_typeRule_valid;
  // wire  [TYPE_NUM-1:0][TYPE_WIDTH-1:0]              w_typeRule_typeData;
  // wire  [TYPE_NUM-1:0][TYPE_WIDTH-1:0]              w_typeRule_typeMask;
  // wire  [TYPE_NUM-1:0][TYPE_OFFSET_WIDTH-1:0]       w_typeRule_typeOffset;
  // wire  [KEY_FILED_NUM-1:0][KEY_OFFSET_WIDTH:0]     w_typeRule_keyOffset;
  // wire  [KEY_FILED_NUM-1:0][KEY_OFFSET_WIDTH-1:0]   w_typeRule_keyReplaceOffset;
  // wire  [HEAD_SHIFT_WIDTH-1:0]                      w_typeRule_headShift;
  // wire  [META_SHIFT_WIDTH-1:0]                      w_typeRule_metaShift;
  //* format change
  logic [TYPE_CANDI_NUM-1:0][TYPE_WIDTH-1:0]        w_headType;
  logic [KEY_CANDI_NUM-1:0][KEY_FIELD_WIDTH-1:0]    w_headKey;
  //* insert 1 clk
  logic [HEAD_WIDTH+TAG_WIDTH-1:0]                  l_head;
  logic [HEAD_WIDTH+TAG_WIDTH-1:0]                  l_meta;
  logic [META_CANDI_NUM-1:0][REP_OFFSET_WIDTH:0]    l_replaceOffset;
  logic [HEAD_SHIFT_WIDTH-1:0]                      l_headShift;
  logic                                             l_metaShift;
  wire  [TYPE_NUM-1:0][TYPE_OFFSET_WIDTH-1:0]       w_type_offset_s0;
  wire  [KEY_FILED_NUM-1:0][KEY_OFFSET_WIDTH:0]     w_key_offset_s0;
  wire  [HEAD_SHIFT_WIDTH-1:0]                      w_headShift_s0;
  wire  [META_SHIFT_WIDTH-1:0]                      w_metaShift_s0;
  wire  [META_CANDI_NUM-1:0][REP_OFFSET_WIDTH:0]    w_replaceOffset_s0;
  reg   [TYPE_NUM-1:0][TYPE_OFFSET_WIDTH-1:0]       r_type_offset_s1,r_type_offset_s2;
  reg   [KEY_FILED_NUM-1:0][KEY_OFFSET_WIDTH:0]     r_key_offset_s1, r_key_offset_s2;
  reg   [HEAD_SHIFT_WIDTH-1:0]                      r_headShift_s1,  r_headShift_s2;
  reg   [META_SHIFT_WIDTH-1:0]                      r_metaShift_s1,  r_metaShift_s2;
  reg   [META_CANDI_NUM-1:0][REP_OFFSET_WIDTH:0]    r_replaceOffset_s1,r_replaceOffset_s2;
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//

  genvar idx;
  generate for (idx = 0; idx < TYPE_NUM; idx=idx+1) begin : gen_extract_type
    Extract_Field 
    #(
    `ifdef TWO_CYCLE_PER_LAYER
      .INSERT_ONE_CLK   (1'b1               ),
    `endif
      .CANDI_NUM        (TYPE_CANDI_NUM     ),
      .OFFSET_WIDTH     (TYPE_OFFSET_WIDTH  ),
      .EXTRACT_WIDTH    (TYPE_WIDTH         )
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
      .CANDI_NUM        (KEY_CANDI_NUM      ),
      .OFFSET_WIDTH     (KEY_OFFSET_WIDTH   ),
      .EXTRACT_WIDTH    (KEY_FIELD_WIDTH    )
    )
    extract_key_field (
      .i_clk            (i_clk              ),
      .i_rst_n          (i_rst_n            ),
      .i_data           (w_headKey          ),
      .o_extract_data   (w_key_field[idx]   ),
      .i_offset         (i_layer_info.key_offset[idx]  )
    );
    end
  endgenerate

  Lookup_Type_for_Dep 
  #(.INSERT_ONE_CLK       (1'b0                   ))
  lookup_type_for_dep(
    .i_clk                (i_clk                  ),
    .i_rst_n              (i_rst_n                ),
    .i_type               (w_type_field           ),
    .o_typeOffset         (w_type_offset_s0       ),
    .o_keyOffset          (w_key_offset_s0        ),
    .o_headShift          (w_headShift_s0         ),
    .o_metaShift          (w_metaShift_s0         ),
    .o_replaceOffset      (w_replaceOffset_s0     ),
    .i_rule_wren          (w_typeRule_wren        ),
    .i_type_rule          (typeRule               )
  );

  Shift_Replace_Head shift_replace_head(
    .i_clk                (i_clk                  ),
    .i_rst_n              (i_rst_n                ),
    .i_head               (l_head                 ),
    .o_head               (i_layer_info.head      ),
    .i_headShift          (l_headShift            ),
    .i_meta               (l_meta                 ),
    .o_meta               (o_layer_info.meta      ),
    .i_extField           (w_key_field            ),
    .i_replaceOffset      (l_replaceOffset        ),
    .i_metaShift          (l_metaShift            )
  );

  Rule_Conf_for_Dep rule_conf_for_dep(
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
      l_replaceOffset       <= i_layer_info.key_replaceOffset;
      l_headShift           <= i_layer_info.headShift;
      l_metaShift           <= &(i_layer_info.metaShift);
    end
  `else
    always_comb begin
      l_head                = i_layer_info.head;
      l_meta                = i_layer_info.meta;
      l_replaceOffset       = i_layer_info.key_replaceOffset;
      l_headShift           = i_layer_info.headShift;
      l_metaShift           = &(i_layer_info.metaShift);
    end
  `endif

  //* shift stage
  assign o_layer_info.key_offset        = r_key_offset_s2;
  assign o_layer_info.type_offset       = r_type_offset_s2;
  assign o_layer_info.headShift         = r_headShift_s2;
  assign o_layer_info.metaShift         = r_metaShift_s2;
  assign o_layer_info.key_replaceOffset = r_replaceOffset_s2;
  always_ff @(posedge i_clk) begin
    {r_key_offset_s2, r_key_offset_s1 } <= {r_key_offset_s1, w_key_offset_s0 };
    {r_type_offset_s2,r_type_offset_s1} <= {r_type_offset_s1,w_type_offset_s0};
    {r_headShift_s2,  r_headShift_s1  } <= {r_headShift_s1,  w_headShift_s0  };
    {r_metaShift_s2, r_metaShift_s1   } <= {r_metaShift_s1,  w_metaShift_s0  };
    {r_replaceOffset_s2,r_replaceOffset_s1} <= {r_replaceOffset_s1, w_replaceOffset_s0};
  end
endmodule