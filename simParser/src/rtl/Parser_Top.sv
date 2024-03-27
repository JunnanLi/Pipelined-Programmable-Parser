/*************************************************************/
//  Module name: Parser_Top
//  Authority @ lijunnan (lijunnan@nudt.edu.cn)
//  Last edited time: 2024/01/01
//  Function outline: Top module of Pipelined-Packet-Parser
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


module Parser_Top(
  input   wire                    i_clk,
  input   wire                    i_rst_n,

  //---conf--//
  input   wire                    i_rule_wren,
  input   wire                    i_rule_rden,
  input   wire  [31:0]            i_rule_addr,
  input   wire  [31:0]            i_rule_wdata,
  output  wire                    o_rule_rdata_valid,
  output  wire  [31:0]            o_rule_rdata,

  //--data--//
  input   wire                    i_head_in_valid,
  input   wire  [`HEAD_WIDTH-1:0] i_head_in,
  output  wire                    o_head_out_valid,
  output  wire  [`HEAD_WIDTH-1:0] o_head_out,
  output  wire                    o_meta_valid,
  output  wire  [`META_WIDTH-1:0] o_meta
);
  localparam P_TYPE_OFFSET_WIDTH  = $clog2(`HEAD_WIDTH/`TYPE_WIDTH);
  localparam P_KEY_OFFSET_WIDTH   = $clog2(`HEAD_WIDTH/`KEY_FIELD_WIDTH),

  //====================================================================//
  //*   internal reg/wire/param declarations
  //====================================================================//
  (* mark_debug = "true"*)wire  [`TYPE_NUM-1:0][`TYPE_WIDTH-1:0]              w_type_field;
  (* mark_debug = "true"*)wire  [`TYPE_NUM-1:0][P_TYPE_OFFSET_WIDTH-1:0]      w_type_offset;
  (* mark_debug = "true"*)wire  [`KEY_FILED_NUM-1:0][`KEY_FIELD_WIDTH-1:0]    w_key_field;
  (* mark_debug = "true"*)wire  [`KEY_FILED_NUM-1:0][P_KEY_OFFSET_WIDTH-1:0]  w_key_offset;
  (* mark_debug = "true"*)wire  [`RULE_NUM-1:0]                               w_typeRule_wren;
  wire                                                w_typeRule_valid;
  wire  [`TYPE_NUM-1:0][`TYPE_WIDTH-1:0]              w_typeRule_typeData;
  wire  [`TYPE_NUM-1:0][`TYPE_WIDTH-1:0]              w_typeRule_typeMask;
  wire  [`KEY_FILED_NUM-1:0][P_KEY_OFFSET_WIDTH-1:0]  w_typeRule_keyOffset;
  logic [`HEAD_WIDTH-1:0]                             l_head;
  logic [`KEY_FILED_NUM-1:0][P_KEY_OFFSET_WIDTH-1:0]  l_key_offset;
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//

  genvar idx;
  generate for (idx = 0; idx < `TYPE_NUM; idx=idx+1) begin : gen_extract_type
    Extract_Field extract_type_field (
      .i_clk            (i_clk              ),
      .i_rst_n          (i_rst_n            ),
      .i_data           (i_head_in          ),
      .o_extract_data   (w_type_field[idx]  ),
      .i_offset         (w_type_offset[idx] )
    );
    end
  endgenerate
  generate for (idx = 0; idx < `KEY_FILED_NUM; idx=idx+1) begin : gen_extract_field
    Extract_Field extract_key_field (
      .i_clk            (i_clk              ),
      .i_rst_n          (i_rst_n            ),
      .i_data           (w_head             ),
      .o_extract_data   (w_key_field[idx]   ),
      .i_offset         (l_key_offset[idx]  )
    );
    end
  endgenerate

  Lookup_Type
  #(
    .TYPE_NUM           (TYPE_NUM           ),
    .TYPE_WIDTH         (TYPE_WIDTH         ),
    .KEY_FILED_NUM      (KEY_FILED_NUM      ),
    .KEY_OFFSET_WIDTH   (KEY_OFFSET_WIDTH   ),
    .RULE_NUM           (RULE_NUM           )
  )
  lookup_type(
    .i_clk              (i_clk              ),
    .i_rst_n            (i_rst_n            ),
    .i_type             (w_type_field       ),
    .o_result           (w_key_offset       ),
    .i_rule_wren        (w_typeRule_wren    ),
    .i_typeRule_valid     (w_typeRule_valid       ),
    .i_typeRule_typeData  (w_typeRule_typeData    ),
    .i_typeRule_typeMask  (w_typeRule_typeMask    ),
    .i_typeRule_keyOffset (w_typeRule_keyOffset   )
  );

  Rule_Conf
  #(
    .TYPE_OFFSET_WIDTH  (TYPE_OFFSET_WIDTH  ),
    .TYPE_NUM           (TYPE_NUM           ),
    .TYPE_WIDTH         (TYPE_WIDTH         ),
    .KEY_FILED_NUM      (KEY_FILED_NUM      ),
    .KEY_OFFSET_WIDTH   (KEY_OFFSET_WIDTH   ),
    .RULE_NUM           (RULE_NUM           )
  )
  rule_conf(
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
    .o_typeRule_keyOffset (w_typeRule_keyOffset   )
  );

  assign o_rule_rdata_valid = i_rule_rden;
  assign o_rule_rdata       = 64'b0;

  //* assign metadata;
  assign o_meta_valid       = 1'b0;
  // assign o_meta             = {META_WIDTH{1'b0}};
  generate for (idx = 0; idx < `KEY_FILED_NUM; idx=idx+1) begin : gen_meta
    assign o_meta[`META_WIDTH-idx*`KEY_FIELD_WIDTH-1-:`KEY_FIELD_WIDTH] = w_key_field[idx];
  end
  endgenerate

  //* insert one cycle;
  `ifdef TWO_CYCLE_PER_LAYER
    always_ff @(posedge i_clk) begin
      l_head                <= i_head_in;
      l_key_offset          <= w_key_offset;
    end
  `else
    always_comb begin
      l_head                = i_head_in;
      l_key_offset          = w_key_offset;
    end
  `endif

endmodule