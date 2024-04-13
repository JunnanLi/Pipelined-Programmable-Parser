/*************************************************************/
//  Module name: Deparser_Layer
//  Authority @ lijunnan (lijunnan@nudt.edu.cn)
<<<<<<< HEAD
//  Last edited time: 2024/01/01
=======
//  Last edited time: 2024/04/11
>>>>>>> three_stage_parser
//  Function outline: Deparse one protocol
//  Note:
//    1) TWO_CYCLE_PER_LAYER is used to insert 1 clk between 
//        type lookup and key-field extraction;
//    2) top bit of w_key_offset is valid info;
//    3) TODO, reading rules;
/*************************************************************/


<<<<<<< HEAD
//========================================================================//
//*     phv --+------------------------------------------------+          //
//*   (input) ↓                                                ↓          //
//*  +---------------+        +-------------+  extract +---------------+  //
//*  | Extract_Field | types  | Lookup_Type |  offfset | Extract_Field |  //
//*  | ( type field) |------->| ( rules )   |--------->| ( key field ) |  //
//*  +---------------+        +-------------+          +---------------+  //
//*           ↑                       ↑                        |  key     //
//*           |            types &&   |                        ↓ fields   //
//*    offset |        extract offset |                +---------------+  //
//*           |                       |                | Replace_Field |  //
//*  +--------------+                 |                +---------------+  //
//*  | Rule_Conf    |-----------------+                        ↓          //
//*  +--------------+                           Connection Relationship   //
//========================================================================//
=======
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
>>>>>>> three_stage_parser


module Deparser_Layer(
  input   wire                                i_clk,
  input   wire                                i_rst_n,
  //---conf--//
  input   wire                                i_rule_wren,
  input   wire                                i_rule_rden,
  input   wire  [31:0]                        i_rule_addr,
  input   wire  [31:0]                        i_rule_wdata,
  output  wire                                o_rule_rdata_valid,
  output  wire  [31:0]                        o_rule_rdata,
<<<<<<< HEAD
=======
  //-exInfo-//
  input   wire  [`TYPE_NUM-1:0][`TYPE_OFFSET_WIDTH-1:0]   i_type_offset,
  input   wire  [`KEY_FILED_NUM-1:0][`KEY_OFFSET_WIDTH:0] i_key_offset,
  input   wire  [`META_CANDI_NUM-1:0][`REP_OFFSET_WIDTH:0]i_key_replaceOffset,
  output  logic [`TYPE_NUM-1:0][`TYPE_OFFSET_WIDTH-1:0]   o_type_offset,
  output  logic [`KEY_FILED_NUM-1:0][`KEY_OFFSET_WIDTH:0] o_key_offset,
  output  logic [`META_CANDI_NUM-1:0][`REP_OFFSET_WIDTH:0]o_key_replaceOffset,
  input   wire  [`HEAD_SHIFT_WIDTH-1:0]                   i_headShift,
  input   wire  [`META_SHIFT_WIDTH-1:0]                   i_metaShift,
  output  logic [`HEAD_SHIFT_WIDTH-1:0]                   o_headShift,
  output  logic [`META_SHIFT_WIDTH-1:0]                   o_metaShift,
>>>>>>> three_stage_parser
  //--data--//
  input   wire  [`HEAD_WIDTH+`TAG_WIDTH-1:0]  i_head,
  output  wire  [`HEAD_WIDTH+`TAG_WIDTH-1:0]  o_head,
  input   wire  [`META_WIDTH+`TAG_WIDTH-1:0]  i_meta,
  output  wire  [`META_WIDTH+`TAG_WIDTH-1:0]  o_meta
);

  //====================================================================//
  //*   internal reg/wire/param declarations
  //====================================================================//
<<<<<<< HEAD
  //* extract type & keyField: w_type_field, w_key_field
  //* lookup result: w_key_offset & w_headShift & w_metaShift
  (* mark_debug = "true"*)wire  [`TYPE_NUM-1:0][`TYPE_WIDTH-1:0]              w_type_field;
  (* mark_debug = "true"*)wire  [`TYPE_NUM-1:0][`TYPE_OFFSET_WIDTH-1:0]       w_type_offset;
  (* mark_debug = "true"*)wire  [`KEY_FILED_NUM-1:0][`KEY_FIELD_WIDTH-1:0]    w_key_field;
  (* mark_debug = "true"*)wire  [`KEY_FILED_NUM-1:0][`KEY_OFFSET_WIDTH:0]     w_key_offset;
  wire  [`META_CANDI_NUM-1:0][`REP_OFFSET_WIDTH:0]    w_replaceOffset;
=======
  //* lookup result: o_type_offset & o_key_offset & o_headShift & o_metaShift
  //* extract field: type & keyField: w_type_field, w_key_field
  (* mark_debug = "true"*)wire  [`TYPE_NUM-1:0][`TYPE_WIDTH-1:0]              w_type_field;
  (* mark_debug = "true"*)wire  [`KEY_FILED_NUM-1:0][`KEY_FIELD_WIDTH-1:0]    w_key_field;
>>>>>>> three_stage_parser
  //* conf rules
  (* mark_debug = "true"*)wire  [`RULE_NUM-1:0]                               w_typeRule_wren;
  wire                                                w_typeRule_valid;
  wire  [`TYPE_NUM-1:0][`TYPE_WIDTH-1:0]              w_typeRule_typeData;
  wire  [`TYPE_NUM-1:0][`TYPE_WIDTH-1:0]              w_typeRule_typeMask;
<<<<<<< HEAD
  wire  [`KEY_FILED_NUM-1:0][`KEY_OFFSET_WIDTH:0]     w_typeRule_keyOffset;
  wire  [`KEY_FILED_NUM-1:0][`KEY_OFFSET_WIDTH-1:0]   w_typeRule_keyMergeOffset;
  //* format change
  logic [`TYPE_CANDI_NUM-1:0][`TYPE_WIDTH-1:0]        w_headType;
  logic [`KEY_CANDI_NUM-1:0][`KEY_FIELD_WIDTH-1:0]    w_headKey;
  wire  [`HEAD_SHIFT_WIDTH-1:0]                       w_headShift, w_typeRule_headShift;
  wire  [`META_SHIFT_WIDTH-1:0]                       w_metaShift, w_typeRule_metaShift;
  //* insert 1 clk
  logic [`KEY_CANDI_NUM-1:0][`KEY_FIELD_WIDTH-1:0]    l_head; //* TODO, insert more clks
  logic [`HEAD_WIDTH+`TAG_WIDTH-1:0]                  l_head_w_tag;
  logic [`HEAD_WIDTH+`TAG_WIDTH-1:0]                  l_meta_w_tag;
  logic [`KEY_FILED_NUM-1:0][`KEY_OFFSET_WIDTH:0]     l_key_offset;
  logic [`META_CANDI_NUM-1:0][`REP_OFFSET_WIDTH:0]    l_replaceOffset;
  logic [`HEAD_SHIFT_WIDTH-1:0]                       l_headShift;
  logic                                               l_metaShift;
=======
  wire  [`TYPE_NUM-1:0][`TYPE_OFFSET_WIDTH-1:0]       w_typeRule_typeOffset;
  wire  [`KEY_FILED_NUM-1:0][`KEY_OFFSET_WIDTH:0]     w_typeRule_keyOffset;
  wire  [`KEY_FILED_NUM-1:0][`KEY_OFFSET_WIDTH-1:0]   w_typeRule_keyReplaceOffset;
  wire  [`HEAD_SHIFT_WIDTH-1:0]                       w_typeRule_headShift;
  wire  [`META_SHIFT_WIDTH-1:0]                       w_typeRule_metaShift;
  //* format change
  logic [`TYPE_CANDI_NUM-1:0][`TYPE_WIDTH-1:0]        w_headType;
  logic [`KEY_CANDI_NUM-1:0][`KEY_FIELD_WIDTH-1:0]    w_headKey;
  //* insert 1 clk
  logic [`HEAD_WIDTH+`TAG_WIDTH-1:0]                  l_head;
  logic [`HEAD_WIDTH+`TAG_WIDTH-1:0]                  l_meta;
  logic [`META_CANDI_NUM-1:0][`REP_OFFSET_WIDTH:0]    l_replaceOffset;
  logic [`HEAD_SHIFT_WIDTH-1:0]                       l_headShift;
  logic                                               l_metaShift;
  wire  [`TYPE_NUM-1:0][`TYPE_OFFSET_WIDTH-1:0]       w_type_offset_s0;
  wire  [`KEY_FILED_NUM-1:0][`KEY_OFFSET_WIDTH:0]     w_key_offset_s0;
  wire  [`HEAD_SHIFT_WIDTH-1:0]                       w_headShift_s0;
  wire  [`META_SHIFT_WIDTH-1:0]                       w_metaShift_s0;
  wire  [`META_CANDI_NUM-1:0][`REP_OFFSET_WIDTH:0]    w_replaceOffset_s0;
  reg   [`TYPE_NUM-1:0][`TYPE_OFFSET_WIDTH-1:0]       r_type_offset_s1,r_type_offset_s2;
  reg   [`KEY_FILED_NUM-1:0][`KEY_OFFSET_WIDTH:0]     r_key_offset_s1, r_key_offset_s2;
  reg   [`HEAD_SHIFT_WIDTH-1:0]                       r_headShift_s1,  r_headShift_s2;
  reg   [`META_SHIFT_WIDTH-1:0]                       r_metaShift_s1,  r_metaShift_s2;
  reg   [`META_CANDI_NUM-1:0][`REP_OFFSET_WIDTH:0]    r_replaceOffset_s1,r_replaceOffset_s2;
>>>>>>> three_stage_parser
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//

  genvar idx;
  generate for (idx = 0; idx < `TYPE_NUM; idx=idx+1) begin : gen_extract_type
    Extract_Field 
    #(
<<<<<<< HEAD
=======
    `ifdef TWO_CYCLE_PER_LAYER
      .INSERT_ONE_CLK   (1'b1               ),
    `endif
>>>>>>> three_stage_parser
      .CANDI_NUM        (`TYPE_CANDI_NUM    ),
      .OFFSET_WIDTH     (`TYPE_OFFSET_WIDTH ),
      .EXTRACT_WIDTH    (`TYPE_WIDTH        )
    )
    extract_type_field (
      .i_clk            (i_clk              ),
      .i_rst_n          (i_rst_n            ),
      .i_data           (w_headType         ),
      .o_extract_data   (w_type_field[idx]  ),
<<<<<<< HEAD
      .i_offset         ({1'b1,w_type_offset[idx]} )
=======
      .i_offset         ({1'b1,i_type_offset[idx]} )
>>>>>>> three_stage_parser
    );
    end
  endgenerate
  generate for (idx = 0; idx < `KEY_FILED_NUM; idx=idx+1) begin : gen_extract_field
    Extract_Field 
    #(
<<<<<<< HEAD
=======
    `ifdef TWO_CYCLE_PER_LAYER
      .INSERT_ONE_CLK   (1'b1               ),
    `endif
>>>>>>> three_stage_parser
      .CANDI_NUM        (`KEY_CANDI_NUM     ),
      .OFFSET_WIDTH     (`KEY_OFFSET_WIDTH  ),
      .EXTRACT_WIDTH    (`KEY_FIELD_WIDTH   )
    )
    extract_key_field (
      .i_clk            (i_clk              ),
      .i_rst_n          (i_rst_n            ),
<<<<<<< HEAD
      .i_data           (l_head             ),
      .o_extract_data   (w_key_field[idx]   ),
      .i_offset         (l_key_offset[idx]  )
=======
      .i_data           (w_headKey          ),
      .o_extract_data   (w_key_field[idx]   ),
      .i_offset         (i_key_offset[idx]  )
>>>>>>> three_stage_parser
    );
    end
  endgenerate

<<<<<<< HEAD
  Lookup_Type_w_Merge lookup_type_w_merge(
    .i_clk                (i_clk                  ),
    .i_rst_n              (i_rst_n                ),
    .i_type               (w_type_field           ),
    .o_result             (w_key_offset           ),
    .o_headShift          (w_headShift            ),
    .o_metaShift          (w_metaShift            ),
    .o_replaceOffset      (w_replaceOffset        ),
=======
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
>>>>>>> three_stage_parser
    .i_rule_wren          (w_typeRule_wren        ),
    .i_typeRule_valid     (w_typeRule_valid       ),
    .i_typeRule_typeData  (w_typeRule_typeData    ),
    .i_typeRule_typeMask  (w_typeRule_typeMask    ),
<<<<<<< HEAD
    .i_typeRule_keyOffset (w_typeRule_keyOffset   ),
    .i_typeRule_keyMergeOffset(w_typeRule_keyMergeOffset),
=======
    .i_typeRule_typeOffset(w_typeRule_typeOffset  ),
    .i_typeRule_keyOffset (w_typeRule_keyOffset   ),
    .i_typeRule_keyReplaceOffset(w_typeRule_keyReplaceOffset),
>>>>>>> three_stage_parser
    .i_typeRule_headShift (w_typeRule_headShift   ),
    .i_typeRule_metaShift (w_typeRule_metaShift   )
  );

  Shift_Replace_Head shift_replace_head(
    .i_clk                (i_clk                  ),
    .i_rst_n              (i_rst_n                ),
<<<<<<< HEAD
    .i_head               (l_head_w_tag           ),
    .o_head               (o_head                 ),
    .i_headShift          (l_headShift            ),
    .i_meta               (l_meta_w_tag           ),
=======
    .i_head               (l_head                 ),
    .o_head               (o_head                 ),
    .i_headShift          (l_headShift            ),
    .i_meta               (l_meta                 ),
>>>>>>> three_stage_parser
    .o_meta               (o_meta                 ),
    .i_extField           (w_key_field            ),
    .i_replaceOffset      (l_replaceOffset        ),
    .i_metaShift          (l_metaShift            )
  );

<<<<<<< HEAD
  Rule_Conf_w_Merge rule_conf_w_merge(
=======
  Rule_Conf_for_Dep rule_conf_for_dep(
>>>>>>> three_stage_parser
    .i_clk                (i_clk                  ),
    .i_rst_n              (i_rst_n                ),
    .i_rule_wren          (i_rule_wren            ),
    .i_rule_wdata         (i_rule_wdata           ),
    .i_rule_addr          (i_rule_addr            ),
<<<<<<< HEAD
    .o_type_offset        (w_type_offset          ),
=======
>>>>>>> three_stage_parser
    .o_typeRule_wren      (w_typeRule_wren        ),
    .o_typeRule_valid     (w_typeRule_valid       ),
    .o_typeRule_typeData  (w_typeRule_typeData    ),
    .o_typeRule_typeMask  (w_typeRule_typeMask    ),
<<<<<<< HEAD
    .o_typeRule_keyOffset (w_typeRule_keyOffset   ),
    .o_typeRule_keyMergeOffset(w_typeRule_keyMergeOffset),
=======
    .o_typeRule_typeOffset(w_typeRule_typeOffset  ),
    .o_typeRule_keyOffset (w_typeRule_keyOffset   ),
    .o_typeRule_keyReplaceOffset(w_typeRule_keyReplaceOffset),
>>>>>>> three_stage_parser
    .o_typeRule_headShift (w_typeRule_headShift   ),
    .o_typeRule_metaShift (w_typeRule_metaShift   )
  );

  assign o_rule_rdata_valid = i_rule_rden;
  assign o_rule_rdata       = 64'b0;

  always_comb begin
    for(integer i=0; i<`TYPE_CANDI_NUM; i=i+1)
<<<<<<< HEAD
      w_headType[i]         <= i_head[(`TYPE_CANDI_NUM-i-1)*`TYPE_WIDTH+:`TYPE_WIDTH];
    for(integer i=0; i<`KEY_CANDI_NUM; i=i+1)
      w_headKey[i]          <= i_head[(`KEY_CANDI_NUM-i-1)*`KEY_FIELD_WIDTH+:`KEY_FIELD_WIDTH];
=======
      w_headType[i]         = i_head[(`TYPE_CANDI_NUM-i-1)*`TYPE_WIDTH+:`TYPE_WIDTH];
    for(integer i=0; i<`KEY_CANDI_NUM; i=i+1)
      w_headKey[i]          = i_head[(`KEY_CANDI_NUM-i-1)*`KEY_FIELD_WIDTH+:`KEY_FIELD_WIDTH];
>>>>>>> three_stage_parser
  end

  //* insert one cycle;
  `ifdef TWO_CYCLE_PER_LAYER
    always_ff @(posedge i_clk) begin
<<<<<<< HEAD
      l_head                <= w_headKey;
      l_head_w_tag          <= i_head;
      l_meta_w_tag          <= i_meta;
      l_key_offset          <= w_key_offset;
      l_replaceOffset       <= w_replaceOffset;
      l_headShift           <= w_headShift;
      l_metaShift           <= &w_metaShift;
    end
  `else
    always_comb begin
      l_head                = w_headKey;
      l_head_w_tag          = i_head;
      l_meta_w_tag          = i_meta;
      l_key_offset          = w_key_offset;
      l_replaceOffset       = w_replaceOffset;
      l_headShift           = w_headShift;
      l_metaShift           = &w_metaShift;
    end
  `endif

=======
      l_head                <= i_head;
      l_meta                <= i_meta;
      l_replaceOffset       <= i_key_replaceOffset;
      l_headShift           <= i_headShift;
      l_metaShift           <= &i_metaShift;
    end
  `else
    always_comb begin
      l_head                = i_head;
      l_meta                = i_meta;
      l_replaceOffset       = i_key_replaceOffset;
      l_headShift           = i_headShift;
      l_metaShift           = &i_metaShift;
    end
  `endif

  //* shift stage
  assign o_key_offset   = r_key_offset_s2;
  assign o_type_offset  = r_type_offset_s2;
  assign o_headShift    = r_headShift_s2;
  assign o_metaShift    = r_metaShift_s2;
  assign o_key_replaceOffset = r_replaceOffset_s2;
  always_ff @(posedge i_clk) begin
    {r_key_offset_s2, r_key_offset_s1 } <= {r_key_offset_s1, w_key_offset_s0 };
    {r_type_offset_s2,r_type_offset_s1} <= {r_type_offset_s1,w_type_offset_s0};
    {r_headShift_s2,  r_headShift_s1  } <= {r_headShift_s1,  w_headShift_s0  };
    {r_metaShift_s2, r_metaShift_s1   } <= {r_metaShift_s1,  w_metaShift_s0  };
    {r_replaceOffset_s2,r_replaceOffset_s1} <= {r_replaceOffset_s1, w_replaceOffset_s0};
  end
>>>>>>> three_stage_parser
endmodule