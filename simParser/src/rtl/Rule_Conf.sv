/****************************************************/
//  Module name: Rule_Conf
//  Authority @ lijunnan (lijunnan@nudt.edu.cn)
//  Last edited time: 2024/01/03
//  Function outline: 3-stage programmable parser
/****************************************************/

module Rule_Conf (
  input   wire                                              i_clk,
  input   wire                                              i_rst_n,
  input   wire                                              i_rule_wren,
  input   wire  [31:0]                                      i_rule_wdata,
  input   wire  [31:0]                                      i_rule_addr,
  output  reg   [`TYPE_NUM-1:0][`TYPE_OFFSET_WIDTH-1:0]     o_type_offset,
  output  reg   [`RULE_NUM-1:0]                             o_typeRule_wren,
  output  reg                                               o_typeRule_valid,
  output  reg   [`TYPE_NUM-1:0][`TYPE_WIDTH-1:0]            o_typeRule_typeData,
  output  reg   [`TYPE_NUM-1:0][`TYPE_WIDTH-1:0]            o_typeRule_typeMask,
  output  reg   [`KEY_FILED_NUM-1:0][`KEY_OFFSET_WIDTH-1:0] o_typeRule_keyOffset
);

  //====================================================================//
  //*   internal reg/wire/param declarations
  //====================================================================//
  
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//

  /*------------------------------------------------------------------------------------
   *     name    | offset  |  description
   *------------------------------------------------------------------------------------
   * i_rule_addr |  [16]   | 1: conf type_offset, 0: conf rules
   *------------------------------------------------------------------------------------
   * [16] is 1   |  [3:0]  | type id, e.g., 2; while i_rule_wdata is offset;
   *------------------------------------------------------------------------------------
   *             |         | 0: write rules; while i_rule_wdata[0] is valid info
   * [16] is 0   |  [9:8]  | 1: conf type data & type mask; while i_rule_addr[3:0] is type id
   *             |         | 2: conf key offset; while i_rule_addr[5:0] is keyField id
   *------------------------------------------------------------------------------------*/
   
  //====================================================================//
  //*   configure rules & type_offset
  //====================================================================//
  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
      o_typeRule_wren                         <= 'b0;
    end else begin
      o_typeRule_wren                         <= 'b0;
      if(i_rule_wren == 1'b1) begin
        if(i_rule_addr[16] == 1'b0) begin //* conf type_offset;
          for(integer i=0; i<`TYPE_NUM; i++)
            o_type_offset[i]  <= (i_rule_addr[3:0] == i)? 
                      i_rule_wdata[0+:`TYPE_OFFSET_WIDTH]: o_type_offset[i];
        end
        else begin //* conf rules;
          if(i_rule_addr[9:8] == 2'b0) begin
            //* rule_valid_bit
            o_typeRule_valid                  <= i_rule_wdata[0];
            for (integer i = 0; i < `RULE_NUM; i++) begin: gen_rule_wren
              if(i_rule_addr[5:0] == i)
                //* ruleID
                o_typeRule_wren[i]            <= 1'b1;
            end
          end
          else if(i_rule_addr[9:8] == 2'b01) begin
            for(integer i=0; i<`TYPE_NUM; i++)
              if(i_rule_addr[3:0] == i) begin
                o_typeRule_typeData[i]        <= i_rule_wdata[16+:`TYPE_WIDTH];
                o_typeRule_typeMask[i]        <= i_rule_wdata[0+:`TYPE_WIDTH];
              end
          end
          else if(i_rule_addr[9:8] == 2'b10) begin
            for(integer i=0; i<`KEY_FILED_NUM; i++)
              if(i_rule_addr[5:0] == i) begin
                o_typeRule_keyOffset[i]       <= i_rule_wdata[0+:`KEY_OFFSET_WIDTH];
              end
          end
        end
      end
    end
  end
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//


endmodule