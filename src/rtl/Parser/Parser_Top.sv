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
  Parser_Layer parser_layer1(
    .i_clk                (i_clk          ),
    .i_rst_n              (i_rst_n        ),
    //---conf--//
    .i_rule_wren          (i_rule_wren & 
                            i_rule_addr[`B_LAYER_ID] == LAYER_1 ),
    .i_rule_rden          (1'b0           ),
    .i_rule_addr          (i_rule_addr    ),
    .i_rule_wdata         (i_rule_wdata   ),
    .o_rule_rdata_valid   (               ),
    .o_rule_rdata         (               ),
    
    .i_layer_info         (layer_info_0   ),
    .o_layer_info         (layer_info_1   )
  );
  //* layer 2: ip/arp
  Parser_Layer parser_layer2(
    .i_clk                (i_clk          ),
    .i_rst_n              (i_rst_n        ),
    //---conf--//
    .i_rule_wren          (i_rule_wren & 
                            i_rule_addr[`B_LAYER_ID] == LAYER_2 ),
    .i_rule_rden          (1'b0           ),
    .i_rule_addr          (i_rule_addr    ),
    .i_rule_wdata         (i_rule_wdata   ),
    .o_rule_rdata_valid   (               ),
    .o_rule_rdata         (               ),

    .i_layer_info         (layer_info_1   ),
    .o_layer_info         (layer_info_2   )
  );  
  //* layer 3: tcp/udp
  Parser_Layer parser_layer3(
    .i_clk                (i_clk          ),
    .i_rst_n              (i_rst_n        ),
    //---conf--//
    .i_rule_wren          (i_rule_wren & 
                            i_rule_addr[`B_LAYER_ID] == LAYER_3 ),
    .i_rule_rden          (1'b0           ),
    .i_rule_addr          (i_rule_addr    ),
    .i_rule_wdata         (i_rule_wdata   ),
    .o_rule_rdata_valid   (               ),
    .o_rule_rdata         (               ),

    .i_layer_info         (layer_info_2   ),
    .o_layer_info         (layer_info_3   )
  );

  always_ff @(posedge i_clk ) begin: layer_0
    if(i_rule_wren == 1'b1 && i_rule_addr[`B_LAYER_ID] == LAYER_0 ) begin
      case(i_rule_addr[`B_INFO_TYPE])
        3'd2: begin
          //* type offset;
          for(integer i=0; i<TYPE_NUM; i++)
            layer_info_0.type_offset[i]  <= (i_rule_addr[`B_EXTR_ID] == i)? 
                  i_rule_wdata[0+:TYPE_OFFSET_WIDTH]: layer_info_0.type_offset[i];
        end
        3'd3: begin
          //* key offset;
          for(integer i=0; i<KEY_FILED_NUM; i++) begin
            if(i_rule_addr[`B_EXTR_ID] == i) begin
              layer_info_0.key_offset_v[i]  <= i_rule_wdata[16];
              layer_info_0.key_offset[i]    <= i_rule_wdata[0+:KEY_OFFSET_WIDTH];
            end
            else begin
              layer_info_0.key_offset_v[i]  <= layer_info_0.key_offset_v[i];
              layer_info_0.key_offset[i]    <= layer_info_0.key_offset[i];
            end
          end
        end
        3'd4: layer_info_0.headShift     <= i_rule_wdata[0+:HEAD_SHIFT_WIDTH];
        3'd5: layer_info_0.metaShift     <= i_rule_wdata[0+:META_SHIFT_WIDTH];
      endcase
    end
  end


endmodule