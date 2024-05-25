/****************************************************/
//  Module name: Rule_Conf
//  Authority @ lijunnan (lijunnan@nudt.edu.cn)
//  Last edited time: 2024/01/03
//  Function outline: 32b data -> configure rules
//  Note:
//    1) top bit of o_typeRule_keyOffset is valid info
/****************************************************/
import parser_pkg::*;

module Rule_Conf #(
  parameter   DEPARSER = 0
)
(
  input   wire                    i_clk,
  input   wire                    i_rst_n,
  input   wire                    i_rule_wren,
  input   wire  [31:0]            i_rule_wdata,
  input   wire  [31:0]            i_rule_addr,
  output  reg   [RULE_NUM-1:0]    o_typeRule_wren,
  output  type_rule_t             o_type_rule
  // output  reg                                               o_typeRule_valid,
  // output  reg   [TYPE_NUM-1:0][TYPE_WIDTH-1:0]            o_typeRule_typeData,
  // output  reg   [TYPE_NUM-1:0][TYPE_WIDTH-1:0]            o_typeRule_typeMask,
  // output  reg   [TYPE_NUM-1:0][TYPE_OFFSET_WIDTH-1:0]     o_typeRule_typeOffset,
  // output  reg   [KEY_FILED_NUM-1:0][KEY_OFFSET_WIDTH:0]   o_typeRule_keyOffset,
  // output  reg   [HEAD_SHIFT_WIDTH-1:0]                     o_typeRule_headShift,
  // output  reg   [META_SHIFT_WIDTH-1:0]                     o_typeRule_metaShift
);

  //====================================================================//
  //*   internal reg/wire/param declarations
  //====================================================================//
  reg   [KEY_FILED_NUM-1:0][KEY_OFFSET_WIDTH-1:0] r_keyReplaceOffset;
  logic [META_CANDI_NUM-1:0][REP_OFFSET_WIDTH:0]  w_rule_replaceOffset;
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//

  /*--------------------------------------------------------------------------------------*
   *  rule_addr (offset)   |  description                                                 *
   *--------------------------------------------------------------------------------------*
   * [10:8] is 0 |         | write rules; while i_rule_wdata[0] is valid info             *
   *--------------------------------------------------------------------------------------*
   * [10:8] is 1 |  [3:0]  | conf type data & type mask; while i_rule_addr[3:0] is type id*
   *--------------------------------------------------------------------------------------*
   * [10:8] is 2 |  [3:0]  | conf type offset                                             *
   *--------------------------------------------------------------------------------------*
   * [10:8] is 3 |  [5:0]  | conf key offset; while i_rule_addr[5:0] is keyField id;      *
   *             |         |     while i_rule_wdata[16] is valid info                     *
   *--------------------------------------------------------------------------------------*
   * [10:8] is 4 |         | conf head shift                                              *
   *--------------------------------------------------------------------------------------*
   * [10:8] is 5 |         | conf meta shift                                              *
   *--------------------------------------------------------------------------------------*/
   
  //====================================================================//
  //*   configure rules & type_offset
  //====================================================================//
  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
      o_typeRule_wren                         <= 'b0;
    end else begin
      o_typeRule_wren                         <= 'b0;
      if(i_rule_wren == 1'b1) begin
        case(i_rule_addr[`B_INFO_TYPE])
          3'd0: begin
            //* rule_valid_bit
            o_type_rule.typeRule_valid        <= i_rule_wdata[0];
            for (integer i = 0; i < RULE_NUM; i++) begin: gen_rule_wren
              if(i_rule_addr[`B_EXTR_ID] == i)
                //* ruleID
                o_typeRule_wren[i]            <= 1'b1;
            end
          end
          3'd1: begin
            for(integer i=0; i<TYPE_NUM; i++)
              if(i_rule_addr[`B_EXTR_ID] == i) begin
                o_type_rule.typeRule_typeData[i]  <= i_rule_wdata[16+:TYPE_WIDTH];
                o_type_rule.typeRule_typeMask[i]  <= i_rule_wdata[0+:TYPE_WIDTH];
              end
          end
          3'd2: begin
          //* conf type_offset;
            for(integer i=0; i<TYPE_NUM; i++)
              o_type_rule.typeRule_typeOffset[i]  <= (i_rule_addr[3:0] == i)? 
                    i_rule_wdata[0+:TYPE_OFFSET_WIDTH]: o_type_rule.typeRule_typeOffset[i];
          end
          3'd3: begin
            for(integer i=0; i<KEY_FILED_NUM; i++)
              if(i_rule_addr[`B_EXTR_ID] == i) begin
                o_type_rule.typeRule_keyOffset[i] <= {i_rule_wdata[16],i_rule_wdata[0+:KEY_OFFSET_WIDTH]};
              end
          end
          3'd4: o_type_rule.typeRule_headShift    <= i_rule_wdata[0+:HEAD_SHIFT_WIDTH];
          3'd5: o_type_rule.typeRule_metaShift    <= i_rule_wdata[0+:META_SHIFT_WIDTH];
          default: begin end
        endcase
      end
    end
  end
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
if(DEPARSER) begin: gen_key_replaceOffset
  //* gen w_rule_replaceOffset
  always_comb begin
    for(integer j=0; j<META_CANDI_NUM; j++) begin
      w_rule_replaceOffset   = 'b0;
      for(integer k=0; k<KEY_FILED_NUM; k++)
        if(r_keyReplaceOffset[k] == j && o_type_rule.typeRule_keyOffset[k][KEY_OFFSET_WIDTH] == 1'b1) begin
          w_rule_replaceOffset[j][REP_OFFSET_WIDTH]    = 1'b1;
          w_rule_replaceOffset[j][REP_OFFSET_WIDTH-1:0]= w_rule_replaceOffset[j][REP_OFFSET_WIDTH-1:0] | k;
        end
    end
  end
end
else begin
  always_comb begin
    for(integer j=0; j<META_CANDI_NUM; j++)
      w_rule_replaceOffset[j]   = 'b0;
  end
end
always_ff @(posedge i_clk) begin
  o_type_rule.typeRule_keyReplaceOffset  <= w_rule_replaceOffset;
end


endmodule