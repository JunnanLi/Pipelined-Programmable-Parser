/*************************************************************/
//  Module name: Shift_Head
//  Authority @ lijunnan (lijunnan@nudt.edu.cn)
//  Last edited time: 2024/03/28
//  Function outline: Shift head & meta
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

module Shift_Head(
  input   wire                                i_clk,
  input   wire                                i_rst_n,

  //--data--//
  input   wire  [`HEAD_WIDTH+`TAG_WIDTH-1:0]  i_head,
  output  wire  [`HEAD_WIDTH+`TAG_WIDTH-1:0]  o_head,
  input   wire  [`HEAD_SHIFT_WIDTH-1:0]       i_headShift,
  input   wire  [`META_WIDTH+`TAG_WIDTH-1:0]  i_meta,
  output  wire  [`META_WIDTH+`TAG_WIDTH-1:0]  o_meta,
  input   wire  [`KEY_FILED_NUM*`KEY_FIELD_WIDTH-1:0] i_extField,
  input   wire  [`META_SHIFT_WIDTH-1:0]       i_metaShift
);

  //====================================================================//
  //*   internal reg/wire/param declarations
  //====================================================================//
  //* r_head/r_meta is used to output;
  //* r_preHead/r_preMeta is one clk delay of i_head/i_meta
  reg   [`HEAD_WIDTH+`TAG_WIDTH-1:0]    r_head, r_preHead;
  reg   [`META_WIDTH+`TAG_WIDTH-1:0]    r_meta, r_preMeta;
  //* r_extMeta is used to expanded by i_extField
  //* w_2head/w_meta is used to shift
  reg   [`META_WIDTH-1:0]               r_extMeta;
  wire  [2*`HEAD_WIDTH-1:0]             w_2head;
  wire  [2*`META_WIDTH-1:0]             w_2meta;
  //* r_headShift/r_metaShift is record of i_headShift/w_metaShift
  //* w_metaShift is the sum of all i_metaShift
  reg   [`HEAD_SHIFT_WIDTH-1:0]         r_headShift;
  wire                                  w_startBit_headTag, w_validBit_headTag;
  wire  [`META_SHIFT_WIDTH-1:0]         w_metaShift;
  reg   [`META_SHIFT_WIDTH-1:0]         r_metaShift;
  wire                                  w_startBit_metaTag;
  reg                                   r_startBit_metaTag, r_toShift_metaTag;
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//  
  assign w_startBit_headTag = i_head[`HEAD_WIDTH+`TAG_START_BIT];
  assign w_validBit_headTag = r_preHead[`HEAD_WIDTH+`TAG_VALID_BIT];
  assign w_startBit_metaTag = i_meta[`HEAD_WIDTH+`TAG_SHIFT_BIT] & ~r_preMeta[`HEAD_WIDTH+`TAG_SHIFT_BIT];
  assign w_2head    = {r_preHead[0+:`HEAD_WIDTH], i_head[0+:`HEAD_WIDTH]};
  assign w_2meta    = {{`META_WIDTH{1'b0}},i_extField, {(`META_WIDTH-`KEY_FILED_NUM*`KEY_FIELD_WIDTH){1'b0}}};
  assign w_metaShift= (w_startBit_headTag)? (i_metaShift + i_meta[`META_WIDTH+:`META_SHIFT_WIDTH]):
                                            r_metaShift + i_meta[`META_WIDTH+:`META_SHIFT_WIDTH];
  assign o_head     = r_head;
  assign o_meta     = r_meta;

	always_ff @(posedge i_clk) begin
    r_preHead                                   <= i_head;
    r_preMeta                                   <= i_meta;
    r_head                                      <= r_preHead;
    r_meta                                      <= r_preMeta;
    r_startBit_metaTag                          <= w_startBit_metaTag;
    r_headShift   <= w_startBit_headTag? i_headShift: r_headShift;
    r_metaShift   <= w_startBit_metaTag? w_metaShift: 
                      w_startBit_headTag? i_metaShift: r_metaShift;
    if(w_validBit_headTag) begin
      for(integer idx=0; idx<`HEAD_CANDI_NUM; idx=idx+1) begin
        if(r_headShift == idx)
          r_head[0+:`HEAD_WIDTH]                <= w_2head[2*`HEAD_WIDTH-idx*`SHIFT_WIDTH-1-:`HEAD_WIDTH];
      end
      r_head[`TAG_START_BIT+`HEAD_WIDTH]        <= r_preHead[`TAG_START_BIT+`HEAD_WIDTH];
    end

    if(r_startBit_metaTag) begin
      r_meta[0+:`META_WIDTH]                    <= r_preMeta[0+:`META_WIDTH] | r_extMeta;
      r_meta[`TAG_SHIFT_BIT+`META_WIDTH]        <= ~r_toShift_metaTag;
      r_meta[`META_WIDTH+:`META_SHIFT_WIDTH]    <= r_metaShift;
    end
    if(w_startBit_headTag) begin
      r_toShift_metaTag                         <= &i_metaShift;
      for(integer idx=0; idx<`META_CANDI_NUM; idx=idx+1) begin
        if(i_meta[`META_WIDTH+:`META_SHIFT_WIDTH] == idx)
          r_extMeta                             <= w_2meta[`META_WIDTH+idx*`SHIFT_WIDTH-1-:`META_WIDTH];
      end
    end

	end

endmodule