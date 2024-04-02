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
  wire          [`HEAD_WIDTH+`TAG_WIDTH-1:0]  w_head_layer1, w_head_layer2, w_head_layer3;
  wire          [`META_WIDTH+`TAG_WIDTH-1:0]  w_meta_layer1, w_meta_layer2, w_meta_layer3;
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
  assign o_head = w_head_layer3;
  assign o_meta = w_meta_layer3;
  //* layer 1: ethernet
  Parser_Layer parser_layer1(
    .i_clk                (i_clk          ),
    .i_rst_n              (i_rst_n        ),
    //---conf--//
    .i_rule_wren          (i_rule_wren & 
                            i_rule_addr[24+:2] == 2'd0    ),
    .i_rule_rden          (1'b0           ),
    .i_rule_addr          (i_rule_addr    ),
    .i_rule_wdata         (i_rule_wdata   ),
    .o_rule_rdata_valid   (               ),
    .o_rule_rdata         (               ),
    //--data--//
    .i_head               (i_head         ),
    .o_head               (w_head_layer1  ),
    .i_meta               (i_meta         ),
    .o_meta               (w_meta_layer1  )
  );
  //* layer 2: ip/arp
  Parser_Layer parser_layer2(
    .i_clk                (i_clk          ),
    .i_rst_n              (i_rst_n        ),
    //---conf--//
    .i_rule_wren          (i_rule_wren & 
                            i_rule_addr[24+:2] == 2'd1    ),
    .i_rule_rden          (1'b0           ),
    .i_rule_addr          (i_rule_addr    ),
    .i_rule_wdata         (i_rule_wdata   ),
    .o_rule_rdata_valid   (               ),
    .o_rule_rdata         (               ),
    //--data--//
    .i_head               (w_head_layer1  ),
    .o_head               (w_head_layer2  ),
    .i_meta               (w_meta_layer1  ),
    .o_meta               (w_meta_layer2  )
  );  
  //* layer 3: tcp/udp
  Parser_Layer parser_layer3(
    .i_clk                (i_clk          ),
    .i_rst_n              (i_rst_n        ),
    //---conf--//
    .i_rule_wren          (i_rule_wren & 
                            i_rule_addr[24+:2] == 2'd2    ),
    .i_rule_rden          (1'b0           ),
    .i_rule_addr          (i_rule_addr    ),
    .i_rule_wdata         (i_rule_wdata   ),
    .o_rule_rdata_valid   (               ),
    .o_rule_rdata         (               ),
    //--data--//
    .i_head               (w_head_layer2  ),
    .o_head               (w_head_layer3  ),
    .i_meta               (w_meta_layer2  ),
    .o_meta               (w_meta_layer3  )
  );


endmodule