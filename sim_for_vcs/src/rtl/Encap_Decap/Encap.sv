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
  input   wire  [`HEAD_SHIFT_WIDTH-1:0]       i_headShift,
  input   wire  [`META_WIDTH+`TAG_WIDTH-1:0]  i_meta,
  output  wire  [`META_WIDTH+`TAG_WIDTH-1:0]  o_meta,
  input   wire  [                       3:0]  i_metaSliceOffset,
  input   wire  [`HEAD_SHIFT_WIDTH-1:0]       i_metaDataOffset,
  input   wire  [`META_SHIFT_WIDTH-1:0]       i_encapLength,
  input   wire  [`ENCAP_WIDTH-1:0]            i_encapField,
  input   wire                                i_encapEn
);

  //====================================================================//
  //*   internal reg/wire/param declarations
  //====================================================================//
  //* r_head/r_meta is used to output;
  //* r_preHead/r_preMeta is one clk delay of i_head/i_meta
  reg   [`HEAD_WIDTH+`TAG_WIDTH-1:0]    r_head, r_preHead;
  reg   [`META_WIDTH+`TAG_WIDTH-1:0]    r_meta, r_preMeta, r_prePreMeta;
  //* r_extMeta is part of i_metaShift
  //* w_2head/w_2meta is used to shift
  wire  [2*`HEAD_WIDTH-1    :0]         w_2head;
  wire  [2*`META_WIDTH-1    :0]         w_2meta;
  //* r_headShift/r_metaShift is record of i_headShift/w_metaShift
  reg   [`HEAD_SHIFT_WIDTH-1:0]         r_headShift;
  wire                                  w_startBit_headTag, w_validBit_metaTag, w_validBit_headTag;
  reg   [`META_SHIFT_WIDTH-1:0]         r_metaShift;
  reg   [                  3:0]         r_cnt_slice, r_metaSliceOffset;
  reg   [`META_SHIFT_WIDTH-1:0]         r_metaDataOffset;
  reg   [`META_SHIFT_WIDTH  :0]         r_metaOffsetAddLen;
  reg   [`ENCAP_WIDTH-1     :0]         r_encapField;
  reg   [`META_SHIFT_WIDTH-1:0]         r_rvs_encapLength;
  reg                                   r_encapEn;
  logic [`META_WIDTH-1      :0]         l_meta;
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//  
  assign w_startBit_headTag = i_head[`HEAD_WIDTH+`TAG_START_BIT];
  assign w_validBit_headTag = r_preHead[`HEAD_WIDTH+`TAG_VALID_BIT];
  assign w_validBit_metaTag = r_preMeta[`META_WIDTH+`TAG_VALID_BIT];
  assign w_2head    = {r_preHead[0+:`HEAD_WIDTH], i_head[0+:`HEAD_WIDTH]};
  assign w_2meta    = {r_prePreMeta[0+:`HEAD_WIDTH], r_preMeta[0+:`META_WIDTH]};
  assign o_head     = r_head;
  assign o_meta     = r_meta;

  //* shift meta;
  always_comb begin
    for(integer idx=0; idx<`META_CANDI_NUM; idx=idx+1)
      if(r_rvs_encapLength == idx)
        l_meta      = w_2meta[2*`META_WIDTH-idx*`SHIFT_WIDTH-1-:`META_WIDTH];
  end

	always_ff @(posedge i_clk) begin
    {r_prePreMeta,r_preMeta}                    <= {r_preMeta,i_meta};
    r_preHead                                   <= i_head;
    r_head                                      <= r_preHead;
    r_meta                                      <= r_preMeta;
    r_headShift       <= w_startBit_headTag? i_headShift:      r_headShift;
    r_metaSliceOffset <= w_startBit_headTag? i_metaSliceOffset:r_metaSliceOffset;
    r_metaDataOffset  <= w_startBit_headTag? i_metaDataOffset: r_metaDataOffset;
    r_metaOffsetAddLen<= w_startBit_headTag? (i_metaDataOffset+i_encapLength): r_metaOffsetAddLen;
    r_encapField      <= w_startBit_headTag? i_encapField:     r_encapField;
    r_rvs_encapLength <= w_startBit_headTag? ~i_encapLength:   r_rvs_encapLength;
    r_encapEn         <= w_startBit_headTag? i_encapEn:        r_encapEn;
    r_cnt_slice       <= i_meta[`META_WIDTH+`TAG_START_BIT]? 4'b0: 
                          i_meta[`META_WIDTH+`TAG_VALID_BIT]? (4'b1 + r_cnt_slice): 4'b0;
    if(w_validBit_metaTag && r_cnt_slice == r_metaSliceOffset && r_encapEn == 1'b1) begin
      for(integer idx=0; idx<`META_CANDI_NUM; idx=idx+1) begin
        if(r_metaOffsetAddLen < idx)
          r_meta[`META_WIDTH-1-idx*`SHIFT_WIDTH-:`SHIFT_WIDTH] <= l_meta[`META_WIDTH-1-idx*`SHIFT_WIDTH-:`SHIFT_WIDTH];
        else if(r_metaDataOffset <= idx)
          r_meta[`META_WIDTH-1-idx*`SHIFT_WIDTH-:`SHIFT_WIDTH] <= r_encapField[`ENCAP_WIDTH-1-idx*`SHIFT_WIDTH-:`SHIFT_WIDTH];
      end
      //* TODO, calculate valid_bit;
      // r_meta[`META_WIDTH+:META_SHIFT_WIDTH]     <= ~r_metaShift;
      // r_meta[`TAG_START_BIT+`HEAD_WIDTH]        <= 1'b0;
      // r_meta[`META_WIDTH+`TAG_VALID_BIT]        <= |r_metaShift;
    end
    else if(w_validBit_metaTag && r_cnt_slice > r_metaSliceOffset && r_encapEn == 1'b1) begin
      r_meta[`META_WIDTH-1:0]                   <= l_meta;
      r_meta[`TAG_START_BIT+`HEAD_WIDTH]        <= 1'b0;
    end

    //* shift head;
    if(w_validBit_headTag) begin
      for(integer idx=0; idx<`HEAD_CANDI_NUM; idx=idx+1) begin
        if(r_headShift == idx)
          r_head[0+:`HEAD_WIDTH]                <= w_2head[2*`HEAD_WIDTH-idx*`SHIFT_WIDTH-1-:`HEAD_WIDTH];
      end
      r_head[`TAG_START_BIT+`HEAD_WIDTH]        <= r_preHead[`TAG_START_BIT+`HEAD_WIDTH];
    end

	end

endmodule