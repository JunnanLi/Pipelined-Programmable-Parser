/******************************************************************/
//  Module name: HyPipe_Top
//  Authority @ lijunnan (lijunnan@nudt.edu.cn)
//  Last edited time: 2024/01/01
//  Function outline: Top module of Hybrid Packet Processing Pipeline
//  Noted:
//    1) 134b pkt data defination: 
//      [133:132] head tag, 2'b01 is head, 2'b10 is tail;
//      [131:128] valid tag, 4'b1111 means sixteen 8b data is valid;
//      [127:0]   pkt data, invalid part is padded with x;
//    2) 1024 phv defination 134b pkt data definition: 
/*******************************************************************/

module HyPipe_Top(
   input  wire              i_clk
  ,input  wire              i_rst_n
  ,input  wire              i_data_valid
  ,input  wire [     133:0] i_data   
  ,output wire              o_data_valid
  ,output wire [     133:0] o_data
);

  //====================================================================//
  //*   internal reg/wire/param declarations
  //====================================================================//
  wire                      w_rule_wren;
  wire  [31:0]              w_rule_addr;
  wire  [31:0]              w_rule_wdata;
  wire                      w_phv_in_valid;
  wire  [`HEAD_WIDTH-1:0]   w_phv_in;
  wire  [133:0]             w_wdata_pktIn, w_dout_pktIn;
  wire                      w_wren_pktIn, w_rden_pktIn, w_wren_meta, w_rden_meta;
  wire  [`META_WIDTH-1:0]   w_wdata_meta, w_dout_meta;
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//

  //* recv pkt, and gen phv;
  Gen_PHV_and_Conf_Parser gen_PHV_and_conf_parer(
    .i_clk                (i_clk          ),
    .i_rst_n              (i_rst_n        ),
    .i_pkt_valid          (i_data_valid   ),
    .i_pkt                (i_data         ),
    .i_inport             (8'b0           ),
    .o_pkt_valid          (w_wren_pktIn   ),
    .o_pkt                (w_wdata_pktIn  ),
    .o_phv_valid          (w_phv_in_valid ),
    .o_phv                (w_phv_in       ),

    .o_rule_wren          (w_rule_wren    ),
    .o_rule_addr          (w_rule_addr    ),
    .o_rule_wdata         (w_rule_wdata   )
  );


  //* parser pkt;
  Parser_Layer parser_layer(
    .i_clk                (i_clk          ),
    .i_rst_n              (i_rst_n        ),

    //---conf--//
    .i_rule_wren          (w_rule_wren    ),
    .i_rule_rden          (1'b0           ),
    .i_rule_addr          (w_rule_addr    ),
    .i_rule_wdata         (w_rule_wdata   ),
    .o_rule_rdata_valid   (               ),
    .o_rule_rdata         (               ),

    //--data--//
    .i_head_in_valid      (w_phv_in_valid ),
    .i_head_in            (w_phv_in       ),
    .o_head_out_valid     (               ),
    .o_head_out           (               ),
    .o_meta_valid         (w_wren_meta    ),
    .o_meta               (w_wdata_meta   )
  );

  //* replace src mac with dst mac;


  Replace_MAC_ADDR Replace_mac_addr(
    .i_clk                (i_clk          ),
    .i_rst_n              (i_rst_n        ),

    //--data--//
    .i_pkt_valid          (w_wren_pktIn   ),
    .i_pkt                (w_wdata_pktIn  ),
    .o_pkt_valid          (o_data_valid   ),
    .o_pkt                (o_data         ),
    .i_meta_valid         (w_wren_meta    ),
    .i_meta               (w_wdata_meta   )
  );

  // `ifdef XILINX_FIFO_RAM
  //   fifo_134b_512 fifo_pktIn (
  //     .clk    (i_clk              ),  // input wire clk
  //     .srst   (!i_rst_n           ),  // input wire srst
  //     .din    (w_wdata_pktIn      ),  // input wire [133 : 0] din
  //     .wr_en  (w_wren_pktIn       ),  // input wire wr_en
  //     .rd_en  (w_rden_pktIn       ),  // input wire rd_en
  //     .dout   (w_dout_pktIn       ),  // output wire [133 : 0] dout
  //     .empty  (                   ),  // output wire empty
  //     .data_count(                )
  //   );
  //   fifo_128b_512 fifo_meta (
  //     .clk    (i_clk              ),  // input wire clk
  //     .srst   (!i_rst_n           ),  // input wire srst
  //     .din    (w_wdata_meta       ),  // input wire [127 : 0] din
  //     .wr_en  (w_wren_meta        ),  // input wire wr_en
  //     .rd_en  (w_rden_meta        ),  // input wire rd_en
  //     .dout   (w_dout_meta        ),  // output wire [133 : 0] dout
  //     .empty  (w_empty_meta       )   // output wire empty
  //   );
  // `elsif SIM_FIFO_RAM
  //   //* fifo used to buffer pkt;
  //   syncfifo fifo_pktIn (
  //     .clock                (i_clk                    ),  //* ASYNC WriteClk, SYNC use wrclk
  //     .aclr                 (!i_rst_n                 ),  //* Reset the all signal
  //     .data                 (i_data                   ),  //* The Inport of data 
  //     .wrreq                (i_data_valid             ),  //* active-high
  //     .rdreq                (w_rden_pktIn             ),  //* active-high
  //     .q                    (w_dout_pktIn             ),  //* The output of data
  //     .empty                (                         ),  //* Read domain empty
  //     .usedw                (                         ),  //* Usedword
  //     .full                 (                         )   //* Full
  //   );
  //   defparam  fifo_pktIn.width = 134,
  //             fifo_pktIn.depth = 9,
  //             fifo_pktIn.words = 512;
  //   syncfifo fifo_meta (
  //     .clock                (i_clk                    ),  //* ASYNC WriteClk, SYNC use wrclk
  //     .aclr                 (!i_rst_n                 ),  //* Reset the all signal
  //     .data                 (w_wdata_meta             ),  //* The Inport of data 
  //     .wrreq                (w_wren_meta              ),  //* active-high
  //     .rdreq                (w_rden_meta              ),  //* active-high
  //     .q                    (w_dout_meta              ),  //* The output of data
  //     .empty                (w_empty_meta             ),  //* Read domain empty
  //     .usedw                (                         ),  //* Usedword
  //     .full                 (                         )   //* Full
  //   );
  //   defparam  fifo_meta.width = 128,
  //             fifo_meta.depth = 4,
  //             fifo_meta.words = 16;
  // `endif



endmodule