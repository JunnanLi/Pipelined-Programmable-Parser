/****************************************************/
//  Module name: Extract_Field
//  Authority @ lijunnan (lijunnan@nudt.edu.cn)
//  Last edited time: 2024/01/02
//  Function outline: extract fields
//  Note:
//    1) top bit of i_offset is valid info;
/****************************************************/

module Extract_Field #(
  parameter   CANDI_NUM             = 128,
  parameter   OFFSET_WIDTH          = 7,
  parameter   EXTRACT_WIDTH         = 8,
  parameter   INSERT_ONE_CLK        = 0
)(
  input   wire                                          i_clk,
  input   wire                                          i_rst_n,
  input   wire  [CANDI_NUM-1:0][EXTRACT_WIDTH-1:0]      i_data,
  output  wire  [EXTRACT_WIDTH-1:0]                     o_extract_data,
  input   wire  [OFFSET_WIDTH:0]                        i_offset
);

  //====================================================================//
  //*   internal reg/wire/param declarations
  //====================================================================//
  wire  [EXTRACT_WIDTH-1:0]         w_extract_data;
  reg   [EXTRACT_WIDTH-1:0]         r_extract_data;
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//

  //====================================================================//
  //*   extract fields
  //====================================================================//
  assign w_extract_data = i_offset[OFFSET_WIDTH]? i_data[i_offset[OFFSET_WIDTH-1:0]]: 'b0;
  assign o_extract_data = (INSERT_ONE_CLK)? r_extract_data: w_extract_data;

  always @(posedge i_clk) begin
    r_extract_data  <= w_extract_data;
  end
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
  
endmodule    