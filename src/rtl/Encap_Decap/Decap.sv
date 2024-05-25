/*************************************************************/
//  Module name: Decap_Head
//  Authority @ lijunnan (lijunnan@nudt.edu.cn)
//  Last edited time: 2024/04/18
//  Function outline: Decapsulate head from meta
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

module Decap_Head(
  input   wire                                i_clk,
  input   wire                                i_rst_n,

  //--data--//
  input   wire  [`HEAD_WIDTH+`TAG_WIDTH-1:0]  i_head,
  output  wire  [`HEAD_WIDTH+`TAG_WIDTH-1:0]  o_head,
  input   wire  [`META_WIDTH+`TAG_WIDTH-1:0]  i_meta,
  output  wire  [`META_WIDTH+`TAG_WIDTH-1:0]  o_meta,
  input   wire  [                       3:0]  i_metaSliceOffset,
  input   wire  [`HEAD_SHIFT_WIDTH-1:0]       i_metaDataOffset,
  input   wire  [`META_SHIFT_WIDTH-1:0]       i_decapLength,
  input   wire                                i_decapEn
);

  //====================================================================//
  //*   internal reg/wire/param declarations
  //====================================================================//
  //* r_head/r_meta is used to output;
  //* r_preHead/r_preMeta is one clk delay of i_head/i_meta
  reg   [`HEAD_WIDTH+`TAG_WIDTH-1:0]    r_head, r_preHead;
  reg   [`META_WIDTH+`TAG_WIDTH-1:0]    r_meta, r_preMeta;
  logic [`META_WIDTH-1:0]               l_meta;
  //* r_extMeta is part of i_metaShift
  //* w_2meta is used to shift
  wire  [2*`META_WIDTH-1:0]             w_2meta;
  wire                                  w_startBit_headTag, w_validBit_metaTag, w_validBit_headTag;
  reg   [                       3:0]    r_cnt_slice, r_metaSliceOffset;
  reg   [`META_SHIFT_WIDTH-1:0]         r_metaDataOffset;
  reg   [`META_SHIFT_WIDTH-1:0]         r_decapLength;
  reg                                   r_decapEn;
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//  
  assign w_startBit_headTag = i_head[`HEAD_WIDTH+`TAG_START_BIT];
  assign w_validBit_headTag = r_preHead[`HEAD_WIDTH+`TAG_VALID_BIT];
  assign w_validBit_metaTag = r_preMeta[`META_WIDTH+`TAG_VALID_BIT];
  assign w_2meta    = {r_preMeta[0+:`META_WIDTH], i_meta[0+:`META_WIDTH]};
  assign o_head     = r_head;
  assign o_meta     = r_meta;

  //* shift meta;
  always_comb begin
    for(integer idx=0; idx<`META_CANDI_NUM; idx=idx+1)
      if(r_decapLength == idx)
        l_meta      = w_2meta[2*`META_WIDTH-idx*`SHIFT_WIDTH-1-:`META_WIDTH];
  end

	always_ff @(posedge i_clk) begin
    r_preMeta                                   <= i_meta;
    r_preHead                                   <= i_head;
    r_head                                      <= r_preHead;
    r_meta                                      <= r_preMeta;
    r_metaSliceOffset <= w_startBit_headTag? i_metaSliceOffset:r_metaSliceOffset;
    r_metaDataOffset  <= w_startBit_headTag? i_metaDataOffset: r_metaDataOffset;
    r_decapLength     <= w_startBit_headTag? i_decapLength:    r_decapLength;
    r_decapEn         <= w_startBit_headTag? i_decapEn:        r_decapEn;
    r_cnt_slice       <= i_meta[`META_WIDTH+`TAG_START_BIT]? 4'b0: 
                          i_meta[`META_WIDTH+`TAG_VALID_BIT]? (4'b1 + r_cnt_slice): 4'b0;
    if(w_validBit_metaTag && r_cnt_slice == r_metaSliceOffset && r_decapEn == 1'b1) begin
      r_meta                                    <= r_preMeta;
      for(integer idx=0; idx<`META_CANDI_NUM; idx=idx+1) begin
        if(r_metaDataOffset <= idx)
          r_meta[`META_WIDTH-1-idx*`SHIFT_WIDTH-:`SHIFT_WIDTH] <= l_meta[`META_WIDTH-1-idx*`SHIFT_WIDTH-:`SHIFT_WIDTH];
      end
      //* TODO, calculate valid_bit;
      // r_meta[`META_WIDTH+:META_SHIFT_WIDTH]     <= ~r_metaShift;
      // r_meta[`TAG_START_BIT+`HEAD_WIDTH]        <= 1'b0;
      // r_meta[`META_WIDTH+`TAG_VALID_BIT]        <= |r_metaShift;
    end
    else if(w_validBit_metaTag && r_cnt_slice > r_metaSliceOffset && r_decapEn == 1'b1) begin
      r_meta[`META_WIDTH-1:0]                   <= l_meta;
      r_meta[`TAG_START_BIT+`HEAD_WIDTH]        <= 1'b0;
    end
	end

endmodule