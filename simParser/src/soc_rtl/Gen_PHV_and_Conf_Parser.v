/*************************************************************/
//  Module name: Gen_PHV_and_Conf_Parser
//  Authority @ lijunnan (lijunnan@nudt.edu.cn)
//  Last edited time: 2024/01/06
//  Function outline: 128b pkt -> 1024b PHV
/*************************************************************/

module Gen_PHV_and_Conf_Parser
#(
  parameter   PHV_WIDTH         = `HEAD_WIDTH,
  parameter   PKT_NUM           = PHV_WIDTH/128 - 1
)
(
  input   wire                  i_clk,
  input   wire                  i_rst_n,

  input   wire                  i_pkt_valid,
  input   wire  [133:0]         i_pkt,
  output  reg                   o_pkt_valid,
  output  reg   [133:0]         o_pkt,
  input   wire  [7:0]           i_inport,
  output  reg                   o_phv_valid,
  output  reg   [PHV_WIDTH-1:0] o_phv,

  output  reg                   o_rule_wren,
  output  reg   [31:0]          o_rule_addr,
  output  reg   [31:0]          o_rule_wdata
);

  //====================================================================//
  //*   internal reg/wire/param declarations
  //====================================================================//
  reg   [3:0]                   r_cnt_pkt;
  reg                           r_tag_conf;
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//

  integer i;
  always @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
      o_phv_valid                       <= 1'b0;
      o_pkt_valid                       <= 1'b0;
      r_tag_conf                        <= 1'b0;
      r_cnt_pkt                         <= 4'b0;
    end else begin
      o_phv_valid                       <= 1'b0;
      o_pkt_valid                       <= o_pkt_valid & i_pkt_valid;
      o_pkt                             <= i_pkt;
      if(i_pkt_valid == 1'b1 && i_pkt[133:132] == 2'b01) begin
        r_cnt_pkt                       <= 4'd1;
        o_phv                           <= {PHV_WIDTH{1'b0}};
        o_phv[PHV_WIDTH-1-:128]         <= i_pkt; 
        o_phv[8+:8]                     <= i_inport; 

        o_pkt_valid                     <= (i_pkt[31:16] == 16'h9006)? 1'b0: 1'b1;
      end
      else if(i_pkt_valid == 1'b1 && o_pkt_valid == 1'b1) begin
        r_cnt_pkt                       <= (r_cnt_pkt == 4'd8)?  4'd8: 4'd1 + r_cnt_pkt;
        for(i=0; i<PKT_NUM; i=i+1)
          if(i == r_cnt_pkt && r_cnt_pkt[3] == 1'b0)
            o_phv[PHV_WIDTH-1-128*i-:128] <= i_pkt;
      end

      o_phv_valid                       <= (o_pkt_valid==1'b1 && o_pkt[133:132] == 2'b10);

      //* tag to read;
      if(i_pkt_valid == 1'b1 && i_pkt[133:132] == 2'b01)
        r_tag_conf                      <= (i_pkt[31:16] == 16'h9006);
      else if(i_pkt_valid == 1'b0 || i_pkt[133:132] == 2'b10)
        r_tag_conf                      <= 1'b0;

      o_rule_wren                       <= 1'b0;
      if(i_pkt_valid == 1'b1 && r_tag_conf == 1'b1) begin
        o_rule_wren                     <= 1'b1;
        o_rule_addr                     <= i_pkt[16+:32];
        o_rule_wdata                    <= i_pkt[48+:32];
      end
    end
  end



            
endmodule