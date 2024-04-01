/*************************************************************/
//  Module name: Shift_Head
//  Authority @ lijunnan (lijunnan@nudt.edu.cn)
//  Last edited time: 2024/03/28
//  Function outline: Shift head & meta
//  Note:
//*   1) Discard pkt'head according to i_headShift
//*   1-1) The first slice is tagged with `TAG_START_BIT=1
//*   1-2) Shift each slice with `TAG_VALID_BIT=1
//*   2) Shift meta accroding to i_metaShift
//*   2-1) The first slice is tagged with `TAG_START_BIT=1
//*   2-2) Shift each slice with `TAG_SHIFT_BIT=1
//*   2-2) The last slice is tagged with `TAG_TAIL_BIT=1
//*   2-3) Only the slice tagged with `TAG_VALID_BIT=1 will be merged
//*   2-3) The length of each slice is tagged with $clog2(`HEAD_CANDI_NUM)=x
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
  input   wire  [`META_SHIFT_WIDTH-1:0]       i_metaShift
);

  //====================================================================//
  //*   internal reg/wire/param declarations
  //====================================================================//
  reg   [`HEAD_WIDTH+`TAG_WIDTH-1:0]    r_head, r_preHead;
  reg   [`META_WIDTH+`TAG_WIDTH-1:0]    r_meta, r_preMeta;
  wire  [2*`HEAD_WIDTH-1:0]             w_2head;
  wire  [2*`META_WIDTH-1:0]             w_2meta;
  reg   [`HEAD_SHIFT_WIDTH-1:0]         r_headShift;
  wire                                  w_startBit_headTag, w_validBit_headTag;
  reg   [`META_SHIFT_WIDTH-1:0]         r_metaShift;
  wire                                  w_startBit_metaTag, w_shiftBit_metaTag;
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//  
  assign w_startBit_headTag = i_head[`HEAD_WIDTH+`TAG_START_BIT];
  assign w_validBit_headTag = r_preHead[`HEAD_WIDTH+`TAG_VALID_BIT];
  assign w_startBit_metaTag = i_meta[`HEAD_WIDTH+`TAG_SHIFT_BIT] & ~r_preMeta[`HEAD_WIDTH+`TAG_SHIFT_BIT];
  assign w_shiftBit_metaTag = r_preMeta[`META_WIDTH+`TAG_SHIFT_BIT];
  assign w_2head    = {r_preHead[0+:`HEAD_WIDTH], i_head[0+:`HEAD_WIDTH]};
  assign w_2meta    = {r_preMeta[0+:`META_WIDTH], i_meta[0+:`META_WIDTH]};
  assign o_head     = r_head;
  assign o_meta     = r_meta;

	always_ff @(posedge i_clk) begin
    r_preHead                                   <= i_head;
    r_preMeta                                   <= i_meta;
    r_head                                      <= r_preHead;
    r_meta                                      <= r_preMeta;
    r_headShift   <= w_startBit_headTag? i_headShift: r_headShift;
    r_metaShift   <= w_startBit_metaTag? i_metaShift: r_metaShift;
    if(w_validBit_headTag) begin
      for(integer idx=0; idx<`HEAD_CANDI_NUM; idx=idx+1) begin
        if(r_headShift == (`HEAD_CANDI_NUM-idx))
          r_head[0+:`HEAD_WIDTH]                <= w_2head[0+idx*`SHIFT_WIDTH+:`HEAD_WIDTH];
      end
      r_head[`TAG_START_BIT+`HEAD_WIDTH]        <= r_preHead[`TAG_START_BIT+`HEAD_WIDTH];
    end

    if(i_meta[`META_WIDTH+`TAG_SHIFT_BIT] == 1'b0) begin
      r_meta                                    <= i_meta;
    end
    else if(w_startBit_metaTag) begin
      r_meta                                    <= i_meta;
      r_meta[`TAG_SHIFT_BIT+`META_WIDTH]        <= 1'b0;
      r_meta[`META_WIDTH+:`META_SHIFT_WIDTH]    <= i_metaShift;
    end
    else if(w_shiftBit_metaTag) begin
      for(integer idx=0; idx<`META_CANDI_NUM; idx=idx+1) begin
        if(r_metaShift == (`META_CANDI_NUM-idx))
          r_meta[0+:`META_WIDTH]                <= w_2meta[0+idx*`SHIFT_WIDTH+:`META_WIDTH];
      end
      r_meta[`META_WIDTH+:`TAG_WIDTH]           <= r_preHead[`META_WIDTH+:`TAG_WIDTH];
      r_meta[`TAG_SHIFT_BIT+`META_WIDTH]        <= 1'b1;
      r_meta[`TAG_START_BIT+`META_WIDTH]        <= 1'b0;
    end

	end

  `ifdef DEBUG
    wire    d_o_head_startBit, d_o_head_validBit;
    wire    d_o_meta_startBit, d_o_meta_tailBit, d_o_meta_shiftBit, d_o_meta_validBit;
    assign  d_o_head_startBit = o_head[`TAG_START_BIT+`HEAD_WIDTH];
    assign  d_o_head_validBit = o_head[`TAG_VALID_BIT+`HEAD_WIDTH];
  `endif


endmodule