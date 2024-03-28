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
  //* width configuration;
  `define HEAD_WIDTH      512 //* extract fields from pkt/meta head
  `define META_WIDTH      128
  `define SHIFT_WIDTH     16   //* alined to 16b
  `define TYPE_WIDTH      8   
  `define TYPE_NUM        2   //* each parser layer has 2 type-extractors
  `define KEY_FIELD_WIDTH 16
  `define KEY_FILED_NUM   8
  `define RULE_NUM        8
  //* shift process
  `define TAG_FIRST_BIT   $clog2(`HEAD_WIDTH/`SHIFT_WIDTH)
  `define TAG_SHIFT_BIT   (`TAG_FIRST_BIT + 1)
  `define TAG_VALID_BIT   (`TAG_SHIFT_BIT + 1)
  //=========================//
  `define TWO_CYCLE_PER_LAYER //* one cycle for identification, one for extraction
  //=========================//
  //* peri configuration;
    `define ENABLE_UART             //* Address 1002xxxx is always for UART;
    `define ENABLE_CSR              //* Address 1004xxxx is always for UART;
    `define ENABLE_DMA              //* Address 1007xxxx is always for DMA;
    // `define ENABLE_DRA              //* Address 1008xxxx is always for DRA;
  //=========================//
  //* instr/data memory size;
  // `define MEM_64KB
  // `define MEM_128KB
  `define MEM_256KB
  //=========================//
  //* Using Xilinx's FIFO/SRAM IP cores
  // `define XILINX_FIFO_RAM
  `define SIM_FIFO_RAM
  //=========================//
  //* Debug
  // `define DEBUGNETS
  // `define DEBUGASM
  // `define DEBUG
  //* trace
  `define ENABLE_TRACE
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//

  //==============================================================//
  // conguration according user defination, DO NOT NEED TO MODIFY!!!
  //==============================================================//
  `define TYPE_OFFSET_WIDTH $clog2(`HEAD_WIDTH/`TYPE_WIDTH)
  `define KEY_OFFSET_WIDTH  $clog2(`HEAD_WIDTH/`KEY_FIELD_WIDTH)
  `define HEAD_SHIFT_WIDTH  $clog2(`HEAD_WIDTH/`SHIFT_WIDTH)
  `define META_SHIFT_WIDTH  $clog2(`META_WIDTH/`SHIFT_WIDTH)
  `define TYPE_CANDI_NUM    `HEAD_WIDTH/`TYPE_WIDTH
  `define KEY_CANDI_NUM     `HEAD_WIDTH/`KEY_FIELD_WIDTH
  `define HEAD_CANDI_NUM    `HEAD_WIDTH/`SHIFT_WIDTH
  `define META_CANDI_NUM    `META_WIDTH/`SHIFT_WIDTH
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
