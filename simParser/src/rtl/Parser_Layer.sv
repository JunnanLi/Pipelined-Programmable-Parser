/*************************************************************/
//  Module name: Parser_Layer
//  Authority @ lijunnan (lijunnan@nudt.edu.cn)
//  Last edited time: 2024/01/01
//  Function outline: Parse one protocol
/*************************************************************/


//========================================================================//
//*     phv --+------------------------------------------------+          //
//*   (input) ↓                                                ↓          //
//*  +---------------+        +-------------+  extract +---------------+  //
//*  | Extract_Field | types  | Lookup_Type |  offfset | Extract_Field |  //
//*  | ( type field) |------->| ( rules )   |--------->| ( key field ) |  //
//*  +---------------+        +-------------+          +---------------+  //
//*           ↑                       ↑                        |          //
//*           |            types &&   |                        |  key     //
//*    offset |        extract offset |                        ↓ fields   //
//*           |                       |                     output        //
//*  +--------------+                 |                                   //
//*  | Rule_Conf    |-----------------+                                   //
//*  +--------------+                           Connection Relationship   //
//========================================================================//


module Parser_Layer(
  input   wire                                i_clk,
  input   wire                                i_rst_n,
  //---conf--//
  input   wire                                i_rule_wren,
  input   wire                                i_rule_rden,
  input   wire  [31:0]                        i_rule_addr,
  input   wire  [31:0]                        i_rule_wdata,
  output  wire                                o_rule_rdata_valid,
  output  wire  [31:0]                        o_rule_rdata,
  //--data--//
  input   wire  [`HEAD_WIDTH+`TAG_WIDTH-1:0]  i_head,
  output  wire  [`HEAD_WIDTH+`TAG_WIDTH-1:0]  o_head,
  input   wire  [`META_WIDTH+`TAG_WIDTH-1:0]  i_meta,
  output  wire  [`META_WIDTH+`TAG_WIDTH-1:0]  o_meta
);

  //====================================================================//
  //*   internal reg/wire/param declarations
  //====================================================================//
  (* mark_debug = "true"*)wire  [`TYPE_NUM-1:0][`TYPE_WIDTH-1:0]              w_type_field;
  (* mark_debug = "true"*)wire  [`TYPE_NUM-1:0][`TYPE_OFFSET_WIDTH-1:0]       w_type_offset;
  (* mark_debug = "true"*)wire  [`KEY_FILED_NUM-1:0][`KEY_FIELD_WIDTH-1:0]    w_key_field;
  (* mark_debug = "true"*)wire  [`KEY_FILED_NUM-1:0][`KEY_OFFSET_WIDTH-1:0]   w_key_offset;
  (* mark_debug = "true"*)wire  [`RULE_NUM-1:0]                               w_typeRule_wren;
  wire                                                w_typeRule_valid;
  wire  [`TYPE_NUM-1:0][`TYPE_WIDTH-1:0]              w_typeRule_typeData;
  wire  [`TYPE_NUM-1:0][`TYPE_WIDTH-1:0]              w_typeRule_typeMask;
  wire  [`KEY_FILED_NUM-1:0][`KEY_OFFSET_WIDTH-1:0]   w_typeRule_keyOffset;
  logic [`TYPE_CANDI_NUM-1:0][`TYPE_WIDTH-1:0]        w_headType;
  logic [`KEY_CANDI_NUM-1:0][`KEY_FIELD_WIDTH-1:0]    w_headKey;
  wire  [`HEAD_SHIFT_WIDTH-1:0]                       w_headShift, w_typeRule_headShift;
  wire  [`META_SHIFT_WIDTH-1:0]                       w_metaShift, w_typeRule_metaShift;
  logic [`KEY_CANDI_NUM-1:0][`KEY_FIELD_WIDTH-1:0]    l_head;
  logic [`KEY_FILED_NUM-1:0][`KEY_OFFSET_WIDTH-1:0]   l_key_offset;
  logic [`HEAD_SHIFT_WIDTH-1:0]                       l_headShift;
  logic [`META_SHIFT_WIDTH-1:0]                       l_metaShift;
  logic [`HEAD_WIDTH+`TAG_WIDTH-1:0]                  l_head_w_tag;
  logic [`HEAD_WIDTH+`TAG_WIDTH-1:0]                  l_meta_w_tag, w_meta_w_tag, w_meta;
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//

  genvar idx;
  generate for (idx = 0; idx < `TYPE_NUM; idx=idx+1) begin : gen_extract_type
    Extract_Field 
    #(
      .CANDI_NUM        (`TYPE_CANDI_NUM    ),
      .OFFSET_WIDTH     (`TYPE_OFFSET_WIDTH ),
      .EXTRACT_WIDTH    (`TYPE_WIDTH        )
    )
    extract_type_field (
      .i_clk            (i_clk              ),
      .i_rst_n          (i_rst_n            ),
      .i_data           (w_headType         ),
      .o_extract_data   (w_type_field[idx]  ),
      .i_offset         (w_type_offset[idx] )
    );
    end
  endgenerate
  generate for (idx = 0; idx < `KEY_FILED_NUM; idx=idx+1) begin : gen_extract_field
    Extract_Field 
    #(
      .CANDI_NUM        (`KEY_CANDI_NUM     ),
      .OFFSET_WIDTH     (`KEY_OFFSET_WIDTH  ),
      .EXTRACT_WIDTH    (`KEY_FIELD_WIDTH   )
    )
    extract_key_field (
      .i_clk            (i_clk              ),
      .i_rst_n          (i_rst_n            ),
      .i_data           (l_head             ),
      .o_extract_data   (w_key_field[idx]   ),
      .i_offset         (l_key_offset[idx]  )
    );
    end
  endgenerate

  Lookup_Type lookup_type(
    .i_clk                (i_clk                  ),
    .i_rst_n              (i_rst_n                ),
    .i_type               (w_type_field           ),
    .o_result             (w_key_offset           ),
    .o_headShift          (w_headShift            ),
    .o_metaShift          (w_metaShift            ),
    .i_rule_wren          (w_typeRule_wren        ),
    .i_typeRule_valid     (w_typeRule_valid       ),
    .i_typeRule_typeData  (w_typeRule_typeData    ),
    .i_typeRule_typeMask  (w_typeRule_typeMask    ),
    .i_typeRule_keyOffset (w_typeRule_keyOffset   ),
    .i_typeRule_headShift (w_typeRule_headShift   ),
    .i_typeRule_metaShift (w_typeRule_metaShift   )
  );

  Shift_Head shift_head(
    .i_clk                (i_clk                  ),
    .i_rst_n              (i_rst_n                ),
    .i_head               (l_head_w_tag           ),
    .o_head               (o_head                 ),
    .i_headShift          (l_headShift            ),
    .i_meta               (w_meta_w_tag           ),
    .o_meta               (o_meta                 ),
    .i_metaShift          (l_metaShift            )
  );

  Rule_Conf rule_conf(
    .i_clk                (i_clk                  ),
    .i_rst_n              (i_rst_n                ),
    .i_rule_wren          (i_rule_wren            ),
    .i_rule_wdata         (i_rule_wdata           ),
    .i_rule_addr          (i_rule_addr            ),
    .o_type_offset        (w_type_offset          ),
    .o_typeRule_wren      (w_typeRule_wren        ),
    .o_typeRule_valid     (w_typeRule_valid       ),
    .o_typeRule_typeData  (w_typeRule_typeData    ),
    .o_typeRule_typeMask  (w_typeRule_typeMask    ),
    .o_typeRule_keyOffset (w_typeRule_keyOffset   ),
    .o_typeRule_headShift (w_typeRule_headShift   ),
    .o_typeRule_metaShift (w_typeRule_metaShift   )
  );

  assign o_rule_rdata_valid = i_rule_rden;
  assign o_rule_rdata       = 64'b0;

  //* assign metadata;
  // assign w_meta             = 'b0;
  generate for (idx = 0; idx < `KEY_FILED_NUM; idx=idx+1) begin : gen_meta
    assign w_meta[`META_WIDTH-idx*`KEY_FIELD_WIDTH-1-:`KEY_FIELD_WIDTH] = w_key_field[idx];
  end
  endgenerate
  generate if (`KEY_FILED_NUM < `KEY_CANDI_NUM)
    assign w_meta[0+:(`KEY_CANDI_NUM-`KEY_FILED_NUM)*`KEY_FIELD_WIDTH]  = 'b0;
  endgenerate
  assign   w_meta[`META_WIDTH+:`TAG_WIDTH] = l_meta_w_tag[`META_WIDTH+:`TAG_WIDTH];

  always_comb begin
    for(integer i=0; i<`TYPE_CANDI_NUM; i=i+1)
      w_headType[i]         <= i_head[(`TYPE_CANDI_NUM-i-1)*`TYPE_WIDTH+:`TYPE_WIDTH];
    for(integer i=0; i<`KEY_CANDI_NUM; i=i+1)
      w_headKey[i]          <= i_head[(`KEY_CANDI_NUM-i-1)*`KEY_FIELD_WIDTH+:`KEY_FIELD_WIDTH];
  end

  //* insert one cycle;
  assign w_meta_w_tag       = l_head_w_tag[`TAG_START_BIT+`HEAD_WIDTH]? w_meta: l_meta_w_tag;
  `ifdef TWO_CYCLE_PER_LAYER
    always_ff @(posedge i_clk) begin
      l_head                <= w_headKey;
      l_head_w_tag          <= i_head;
      l_meta_w_tag          <= i_meta;
      l_key_offset          <= w_key_offset;
      l_headShift           <= w_headShift;
      l_metaShift           <= w_metaShift;
    end
  `else
    always_comb begin
      l_head                = w_headKey;
      l_head_w_tag          = i_head;
      l_meta_w_tag          = i_meta;
      l_key_offset          = w_key_offset;
      l_headShift           = w_headShift;
      l_metaShift           = w_metaShift;
    end
  `endif

endmodule