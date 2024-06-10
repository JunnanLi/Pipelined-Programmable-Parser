/*************************************************************/
//  Module name: global_head
//  Authority @ lijunnan (lijunnan@nudt.edu.cn)
//  Last edited time: 2024/03/27
//  Function outline: head file
/*************************************************************/



  //==============================================================//
  //  user defination
  //==============================================================//
  //* hardware version configuration
  `define HW_VERSION      32'h0_00_01
  //=========================//
  //* specfic configuration
  `define TWO_CYCLE_PER_LAYER //* one cycle for identification, one for extraction
  `define RULE_W_PRIORITY     //* note: no more than 8 rules!!!
  //=========================//
  //* BIT_A:BIT_B
  `define B_LAYER_ID  24+:2
  `define B_INFO_TYPE 8+:3
  `define B_EXTR_ID   0+:5
  //=========================//
  //* Using Xilinx's FIFO/SRAM IP cores
  // `define XILINX_FIFO_RAM
  `define SIM_FIFO_RAM
  //=========================//
  `define DEBUG
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//

  
