/*************************************************************/
//  Module name: Shift_Head
//  Authority @ lijunnan (lijunnan@nudt.edu.cn)
//  Last edited time: 2024/03/28
//  Function outline: Shift head & meta
//  Note:
//    1) Discard pkt'head according to i_headShift
//    1-1) The first slice is tagged with TAG_START_BIT=1
//    1-2) Shift each slice with TAG_VALID_BIT=1
//    2) Shift meta accroding to i_metaShift
//    2-1) The first slice is tagged with TAG_START_BIT=1
//    2-2) The last slice is tagged with TAG_TAIL_BIT=1
//    2-3) Do only support shift one slice each time, i.e., 
//          set the first slice (TAG_SHIFT_BIT=1) with TAG_SHIFT_BIT=0
/*************************************************************/

import parser_pkg::*;
module Shift_Replace_Head(
  input   wire                              i_clk,
  input   wire                              i_rst_n,

  //--data--//
  input   wire  [HEAD_WIDTH+TAG_WIDTH-1:0]  i_head,
  output  wire  [HEAD_WIDTH+TAG_WIDTH-1:0]  o_head,
  input   wire  [HEAD_SHIFT_WIDTH-1:0]      i_headShift,
  input   wire  [META_WIDTH+TAG_WIDTH-1:0]  i_meta,
  output  wire  [META_WIDTH+TAG_WIDTH-1:0]  o_meta,
  input   wire  [KEY_FILED_NUM-1:0][KEY_FIELD_WIDTH-1:0]    i_extField,
  input   wire  [META_CANDI_NUM-1:0][REP_OFFSET_WIDTH-1:0]  i_replaceOffset,
  input   wire  [META_CANDI_NUM-1:0]        i_replaceOffset_v,
  input   wire  [META_CANDI_NUM-1:0]        i_replaceOffset_carry,
  input   wire                              i_metaShift
);

  //====================================================================//
  //*   internal reg/wire/param declarations
  //====================================================================//
  //* r_head/r_meta is used to output;
  //* r_preHead/r_preMeta is one clk delay of i_head/i_meta
  reg   [HEAD_WIDTH+TAG_WIDTH-1:0]      r_head, r_preHead;
  reg   [META_WIDTH+TAG_WIDTH-1:0]      r_meta, r_preMeta;
  //* r_extField is one clk delay of i_extField
  //* w_2head/w_meta is used to shift
  reg   [KEY_FILED_NUM-1:0][KEY_FIELD_WIDTH-1:0]  r_extField;
  reg   [META_CANDI_NUM-1:0][REP_OFFSET_WIDTH-1:0]r_replaceOffset;
  reg   [META_CANDI_NUM-1:0]                      r_replaceOffset_v;
  reg   [META_CANDI_NUM-1:0]                      r_replaceOffset_carry;
  wire  [2*HEAD_WIDTH-1:0]              w_2head;
  //* r_headShift is record of i_headShift
  reg   [HEAD_SHIFT_WIDTH-1:0]          r_headShift;
  wire                                  w_startBit_headTag, w_validBit_headTag;
  wire                                  w_startBit_metaTag;
  reg                                   r_startBit_metaTag, r_toShift_metaTag;
  reg                                   r_startBit_metaTag_carry;
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//  
  assign w_startBit_headTag = i_head[HEAD_WIDTH+TAG_START_BIT];
  assign w_validBit_headTag = r_preHead[HEAD_WIDTH+TAG_VALID_BIT];
  assign w_startBit_metaTag = i_meta[HEAD_WIDTH+TAG_SHIFT_BIT] & ~r_preMeta[HEAD_WIDTH+TAG_SHIFT_BIT] |
                              i_meta[HEAD_WIDTH+TAG_TAIL_BIT];
  assign w_2head    = {r_preHead[0+:HEAD_WIDTH], i_head[0+:HEAD_WIDTH]};
  assign o_head     = r_head;
  assign o_meta     = r_meta;

	always_ff @(posedge i_clk) begin
    r_preHead                                   <= i_head;
    r_preMeta                                   <= i_meta;
    r_head                                      <= r_preHead;
    r_meta                                      <= r_preMeta;
    r_startBit_metaTag                          <= w_startBit_metaTag;
    r_startBit_metaTag_carry                    <= r_startBit_metaTag;
    r_headShift   <= w_startBit_headTag? i_headShift: r_headShift;
    if(w_validBit_headTag) begin
      for(integer idx=0; idx<HEAD_CANDI_NUM; idx=idx+1) begin
        if(r_headShift == idx)
          r_head[0+:HEAD_WIDTH]                <= w_2head[2*HEAD_WIDTH-idx*SHIFT_WIDTH-1-:HEAD_WIDTH];
      end
      r_head[TAG_START_BIT+HEAD_WIDTH]        <= r_preHead[TAG_START_BIT+HEAD_WIDTH];
    end

    if(r_startBit_metaTag) begin
      for(integer i=0; i<META_CANDI_NUM; i++) begin
        //* TODO,
        if(r_replaceOffset_v[i] & (~r_replaceOffset_carry[i]))
          case(r_replaceOffset[i])
            3'd0: r_meta[META_WIDTH-i*KEY_FIELD_WIDTH-1-:KEY_FIELD_WIDTH] <= r_extField[0];
            3'd1: r_meta[META_WIDTH-i*KEY_FIELD_WIDTH-1-:KEY_FIELD_WIDTH] <= r_extField[1]; 
            3'd2: r_meta[META_WIDTH-i*KEY_FIELD_WIDTH-1-:KEY_FIELD_WIDTH] <= r_extField[2]; 
            3'd3: r_meta[META_WIDTH-i*KEY_FIELD_WIDTH-1-:KEY_FIELD_WIDTH] <= r_extField[3]; 
            3'd4: r_meta[META_WIDTH-i*KEY_FIELD_WIDTH-1-:KEY_FIELD_WIDTH] <= r_extField[4]; 
            3'd5: r_meta[META_WIDTH-i*KEY_FIELD_WIDTH-1-:KEY_FIELD_WIDTH] <= r_extField[5]; 
            3'd6: r_meta[META_WIDTH-i*KEY_FIELD_WIDTH-1-:KEY_FIELD_WIDTH] <= r_extField[6]; 
            3'd7: r_meta[META_WIDTH-i*KEY_FIELD_WIDTH-1-:KEY_FIELD_WIDTH] <= r_extField[7]; 
          endcase

        // for(integer j=0; j<KEY_FILED_NUM; j++)
        //   if(r_replaceOffset[i][REP_OFFSET_WIDTH-1:0] == j && r_replaceOffset[i][REP_OFFSET_WIDTH] == 1'b1)
        //     r_meta[META_WIDTH-i*KEY_FIELD_WIDTH-1:KEY_FIELD_WIDTH] <= r_extField[j];
      end
      r_meta[TAG_SHIFT_BIT+META_WIDTH]          <= ~r_toShift_metaTag;
    end
    else if(r_startBit_metaTag_carry) begin
      for(integer i=0; i<META_CANDI_NUM; i++) begin
        //* TODO,
        if(r_replaceOffset_v[i] & r_replaceOffset_carry[i])
          case(r_replaceOffset[i])
            3'd0: r_meta[META_WIDTH-i*KEY_FIELD_WIDTH-1-:KEY_FIELD_WIDTH] <= r_extField[0];
            3'd1: r_meta[META_WIDTH-i*KEY_FIELD_WIDTH-1-:KEY_FIELD_WIDTH] <= r_extField[1]; 
            3'd2: r_meta[META_WIDTH-i*KEY_FIELD_WIDTH-1-:KEY_FIELD_WIDTH] <= r_extField[2]; 
            3'd3: r_meta[META_WIDTH-i*KEY_FIELD_WIDTH-1-:KEY_FIELD_WIDTH] <= r_extField[3]; 
            3'd4: r_meta[META_WIDTH-i*KEY_FIELD_WIDTH-1-:KEY_FIELD_WIDTH] <= r_extField[4]; 
            3'd5: r_meta[META_WIDTH-i*KEY_FIELD_WIDTH-1-:KEY_FIELD_WIDTH] <= r_extField[5]; 
            3'd6: r_meta[META_WIDTH-i*KEY_FIELD_WIDTH-1-:KEY_FIELD_WIDTH] <= r_extField[6]; 
            3'd7: r_meta[META_WIDTH-i*KEY_FIELD_WIDTH-1-:KEY_FIELD_WIDTH] <= r_extField[7]; 
          endcase
      end
    end
    if(w_startBit_headTag) begin
      r_toShift_metaTag                         <= i_metaShift;
      r_extField                                <= i_extField;
      r_replaceOffset                           <= i_replaceOffset;
      r_replaceOffset_carry                     <= i_replaceOffset_carry;
      r_replaceOffset_v                         <= i_replaceOffset_v;
    end

	end

endmodule