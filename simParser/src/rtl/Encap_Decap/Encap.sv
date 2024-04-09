/*************************************************************/
//  Module name: Encap_Head
//  Authority @ lijunnan (lijunnan@nudt.edu.cn)
//  Last edited time: 2024/04/08
//  Function outline: Encapsulate head from meta
//  Note:
//    1) Discard pkt'head according to i_headShift
//    1-1) The first slice is tagged with `TAG_START_BIT=1
//    1-2) Shift each slice with `TAG_VALID_BIT=1
//    2) Shift meta accroding to i_metaShift
//    2-1) The first slice is tagged with `TAG_START_BIT=1
//    2-2) The last slice is tagged with `TAG_TAIL_BIT=1
//    2-3) Do only support shift one slice each time, i.e., 
//          set the first slice (`TAG_SHIFT_BIT=1) with `TAG_SHIFT_BIT=0
/*************************************************************/

module Encap_Head(
  input   wire                                i_clk,
  input   wire                                i_rst_n,

  //--data--//
  input   wire  [`HEAD_WIDTH+`TAG_WIDTH-1:0]  i_head,
  output  wire  [`HEAD_WIDTH+`TAG_WIDTH-1:0]  o_head,
  input   wire  [                       3:0]  i_headSliceOffset,
  input   wire  [`HEAD_SHIFT_WIDTH-1:0]       i_headDataOffset,
  input   wire  [`META_WIDTH+`TAG_WIDTH-1:0]  i_meta,
  output  wire  [`META_WIDTH+`TAG_WIDTH-1:0]  o_meta,
  input   wire  [`META_SHIFT_WIDTH-1:0]       i_metaShift
);

  //====================================================================//
  //*   internal reg/wire/param declarations
  //====================================================================//
  //* r_head/r_meta is used to output;
  //* r_preHead/r_preMeta is one clk delay of i_head/i_meta
  reg   [`HEAD_WIDTH+`TAG_WIDTH-1:0]    r_head, r_preHead, r_prePreHead;
  reg   [`META_WIDTH+`TAG_WIDTH-1:0]    r_meta, r_preMeta;
  //* r_extMeta is part of i_metaShift
  //* w_2head/w_2meta is used to shift
  reg   [`META_WIDTH-1:0]               r_extMeta;
  wire  [2*`META_WIDTH-1:0]             w_2meta;
  //* r_metaShift is record of i_metaShift
  wire                                  w_startBit_headTag, w_validBit_headTag;
  reg   [`META_SHIFT_WIDTH-1:0]         r_metaShift;
  reg   [                       3:0]    r_cnt_slice;
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//  
  assign w_startBit_headTag = i_head[`HEAD_WIDTH+`TAG_START_BIT];
  assign w_validBit_headTag = r_preHead[`HEAD_WIDTH+`TAG_VALID_BIT];
  assign w_2meta    = {r_preMeta[0+:`META_WIDTH], i_meta[0+:`META_WIDTH]};
  assign o_head     = r_head;
  assign o_meta     = r_meta;

	always_ff @(posedge i_clk) begin
    {r_prePreHead,r_preHead}                    <= {r_preHead,i_head};
    r_preMeta                                   <= i_meta;
    r_head                                      <= r_preHead;
    r_meta                                      <= r_preMeta;
    r_metaShift   <= w_startBit_headTag? i_metaShift: r_metaShift;
    r_cnt_slice   <= i_head[`HEAD_WIDTH+`TAG_START_BIT]? 4'b0: 
                      i_head[`HEAD_WIDTH+`TAG_VALID_BIT] (4'b1 + r_cnt_slice): 4'b0;
    if(w_validBit_headTag && r_cnt_slice == r_cnt_slice) begin
      r_head[`TAG_START_BIT+`HEAD_WIDTH]        <= r_extMeta;
      r_head[`HEAD_WIDTH+:`HEAD_SHIFT_WIDTH]    <= r_metaShift;
      r_head[`HEAD_WIDTH+`TAG_TAIL_BIT]         <= 1'b0;
    end
    else if(w_validBit_headTag && r_cnt_slice > r_cnt_slice) begin
      r_head                                    <= r_prePreHead;
    end

    if(r_preMeta[`META_WIDTH+`TAG_VALID_BIT]) begin
      for(integer idx=0; idx<`META_CANDI_NUM; idx=idx+1) begin
        if(r_metaShift == idx)
          r_meta[0+:`META_WIDTH]                <= w_2meta[2*`META_WIDTH-idx*`SHIFT_WIDTH-1-:`META_WIDTH];
      end
      r_meta[`TAG_START_BIT+`META_WIDTH]        <= r_preMeta[`TAG_START_BIT+`META_WIDTH];
    end
    if(w_startBit_headTag) begin
      r_extMeta                                 <= i_meta;
    end

	end

endmodule