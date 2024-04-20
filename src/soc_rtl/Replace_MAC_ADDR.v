/*************************************************************/
//  Module name: Replace_MAC_ADDR
//  Authority @ lijunnan (lijunnan@nudt.edu.cn)
//  Last edited time: 2024/01/06
//  Function outline: replace src mac with dst mac;
/*************************************************************/

module Replace_MAC_ADDR (
  input   wire                  i_clk,
  input   wire                  i_rst_n,

  input   wire                  i_pkt_valid,
  input   wire  [133:0]         i_pkt,
  output  reg                   o_pkt_valid,
  output  reg   [133:0]         o_pkt,
  input   wire                  i_meta_valid,
  input   wire  [127:0]         i_meta
);

  //====================================================================//
  //*   internal reg/wire/param declarations
  //====================================================================//
  reg                           r_pkt_valid;
  reg            [133:0]        r_pkt;
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//

  always @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
      r_pkt_valid                       <= 1'b0;
      o_pkt_valid                       <= 1'b0;
    end else begin
      r_pkt_valid                       <= i_pkt_valid;
      r_pkt                             <= i_pkt;
      o_pkt_valid                       <= r_pkt_valid;
      o_pkt                             <= r_pkt;
      if(r_pkt_valid == 1'b1 && r_pkt[133:132] == 2'b01) begin
        o_pkt[127:32]                   <= i_meta[127:32];
      end
    end
  end



            
endmodule