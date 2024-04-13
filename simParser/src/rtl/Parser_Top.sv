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
  wire  [`HEAD_WIDTH+`TAG_WIDTH-1:0]              w_head_layer1, w_head_layer2, w_head_layer3;
  wire  [`META_WIDTH+`TAG_WIDTH-1:0]              w_meta_layer1, w_meta_layer2, w_meta_layer3;
  wire  [`TYPE_NUM-1:0][`TYPE_OFFSET_WIDTH-1:0]   w_type_offset_1,w_type_offset_2;
  wire  [`KEY_FILED_NUM-1:0][`KEY_OFFSET_WIDTH:0] w_key_offset_1,w_key_offset_2;
  reg   [`TYPE_NUM-1:0][`TYPE_OFFSET_WIDTH-1:0]   r_type_offset_0;
  reg   [`KEY_FILED_NUM-1:0][`KEY_OFFSET_WIDTH:0] r_key_offset_0;
  wire  [`HEAD_SHIFT_WIDTH-1:0]                   w_headShift_1,w_headShift_2;
  wire  [`META_SHIFT_WIDTH-1:0]                   w_metaShift_1,w_metaShift_2;
  reg   [`HEAD_SHIFT_WIDTH-1:0]                   r_headShift_0;
  reg   [`META_SHIFT_WIDTH-1:0]                   r_metaShift_0;
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
  assign o_head = w_head_layer3;
  assign o_meta = w_meta_layer3;
  //* layer 1: ethernet
  Parser_Layer parser_layer1(
    .i_clk                (i_clk          ),
    .i_rst_n              (i_rst_n        ),
    //---conf--//
    .i_rule_wren          (i_rule_wren & 
                            i_rule_addr[24+:2] == 2'd1 ),
    .i_rule_rden          (1'b0           ),
    .i_rule_addr          (i_rule_addr    ),
    .i_rule_wdata         (i_rule_wdata   ),
    .o_rule_rdata_valid   (               ),
    .o_rule_rdata         (               ),
    //-exInfo-//
    .i_type_offset        (r_type_offset_0),
    .i_key_offset         (r_key_offset_0 ),
    .o_type_offset        (w_type_offset_1),
    .o_key_offset         (w_key_offset_1 ),
    .i_headShift          (r_headShift_0  ),
    .o_headShift          (w_headShift_1  ),
    .i_metaShift          (r_metaShift_0  ),
    .o_metaShift          (w_metaShift_1  ),
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
                            i_rule_addr[24+:2] == 2'd2 ),
    .i_rule_rden          (1'b0           ),
    .i_rule_addr          (i_rule_addr    ),
    .i_rule_wdata         (i_rule_wdata   ),
    .o_rule_rdata_valid   (               ),
    .o_rule_rdata         (               ),
    //-exInfo-//
    .i_type_offset        (w_type_offset_1),
    .i_key_offset         (w_key_offset_1 ),
    .o_type_offset        (w_type_offset_2),
    .o_key_offset         (w_key_offset_2 ),
    .i_headShift          (w_headShift_1  ),
    .o_headShift          (w_headShift_2  ),
    .i_metaShift          (w_metaShift_1  ),
    .o_metaShift          (w_metaShift_2  ),
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
                            i_rule_addr[24+:2] == 2'd3 ),
    .i_rule_rden          (1'b0           ),
    .i_rule_addr          (i_rule_addr    ),
    .i_rule_wdata         (i_rule_wdata   ),
    .o_rule_rdata_valid   (               ),
    .o_rule_rdata         (               ),
    //-exInfo-//
    .i_type_offset        (w_type_offset_2),
    .i_key_offset         (w_key_offset_2 ),
    .o_type_offset        (               ),
    .o_key_offset         (               ),
    .i_headShift          (w_headShift_2  ),
    .o_headShift          (               ),
    .i_metaShift          (w_metaShift_2  ),
    .o_metaShift          (               ),
    //--data--//
    .i_head               (w_head_layer2  ),
    .o_head               (w_head_layer3  ),
    .i_meta               (w_meta_layer2  ),
    .o_meta               (w_meta_layer3  )
  );

  always_ff @(posedge i_clk ) begin: layer_0
    if(i_rule_wren == 1'b1 && i_rule_addr[24+:2] == 2'd0) begin
      case(i_rule_addr[10:8])
        3'd2: begin
          //* type offset;
          for(integer i=0; i<`TYPE_NUM; i++)
            r_type_offset_0[i]  <= (i_rule_addr[3:0] == i)? 
                  i_rule_wdata[0+:`TYPE_OFFSET_WIDTH]: r_type_offset_0[i];
        end
        3'd3: begin
          //* key offset;
          for(integer i=0; i<`KEY_FILED_NUM; i++)
            if(i_rule_addr[5:0] == i)
              r_key_offset_0[i] <= {i_rule_wdata[16],i_rule_wdata[0+:`KEY_OFFSET_WIDTH]};
        end
        3'd4: r_headShift_0     <= i_rule_wdata[0+:`HEAD_SHIFT_WIDTH];
        3'd5: r_metaShift_0     <= i_rule_wdata[0+:`META_SHIFT_WIDTH];
      endcase
    end
  end


endmodule