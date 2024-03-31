/*************************************************************/
//  Module name: Shift_Head
//  Authority @ lijunnan (lijunnan@nudt.edu.cn)
//  Last edited time: 2024/03/28
//  Function outline: Shift head & meta
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
  wire  [`TAG_WIDTH-1:0]                w_head_tag, w_meta_tag;
  reg   [`HEAD_WIDTH+`TAG_WIDTH-1:0]    r_head, r_preHead;
  reg   [`META_WIDTH+`TAG_WIDTH-1:0]    r_meta, r_preMeta;
  wire  [2*`HEAD_WIDTH-1:0]             w_2head;
  wire  [2*`META_WIDTH-1:0]             w_2meta;
  reg                                   r_new_first_head, r_new_first_meta;
  reg   [`HEAD_SHIFT_WIDTH-1:0]         r_headShift;
  wire  [`HEAD_SHIFT_WIDTH-1:0]         w_headShift;
  reg   [`META_SHIFT_WIDTH-1:0]         r_metaShift;
  wire  [`META_SHIFT_WIDTH-1:0]         w_metaShift;
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
  assign w_headShift= (i_head[`TAG_START_BIT+`HEAD_WIDTH])? i_headShift: r_headShift;
  assign w_metaShift= (i_meta[`TAG_START_BIT+`META_WIDTH])? i_metaShift: r_metaShift;
  
  assign w_head_tag = i_head[`HEAD_WIDTH+:`TAG_WIDTH];
  assign w_meta_tag = i_meta[`META_WIDTH+:`TAG_WIDTH];
  assign w_2head    = {r_preHead[0+:`HEAD_WIDTH], i_head[0+:`HEAD_WIDTH]};
  assign w_2meta    = {r_preMeta[0+:`HEAD_WIDTH], i_meta[0+:`HEAD_WIDTH]};
  assign o_head     = r_head;
  assign o_meta     = r_meta;

	always_ff @(posedge i_clk) begin
    r_preHead                                   <= i_head;
    r_preMeta                                   <= i_meta;
    r_head                                      <= r_preHead;
    r_meta                                      <= r_preMeta;
    r_new_first_head                            <= 1'b0;
    r_new_first_meta                            <= 1'b0;
    r_headShift   <= i_head[`TAG_START_BIT+`HEAD_WIDTH]? i_headShift: r_headShift;
    r_metaShift   <= i_meta[`TAG_START_BIT+`META_WIDTH]? i_metaShift: r_metaShift;
    if(r_preHead[`TAG_VALID_BIT+`HEAD_WIDTH] & r_preHead[`TAG_SHIFT_BIT+`HEAD_WIDTH]) begin
      for(integer idx=0; idx<`HEAD_CANDI_NUM; idx=idx+1) begin
        if(w_headShift == (`HEAD_CANDI_NUM-idx))
          r_head[0+:`HEAD_WIDTH]                <= w_2head[0+idx*`SHIFT_WIDTH+:`HEAD_WIDTH];
      end
      r_head[`TAG_START_BIT+`HEAD_WIDTH]        <= r_new_first_head;
    end
    else if(w_head_tag[`TAG_VALID_BIT] & w_head_tag[`TAG_SHIFT_BIT] & w_head_tag[`TAG_START_BIT]) begin
      if(|w_headShift) begin
        r_head[`TAG_VALID_BIT+`HEAD_WIDTH]      <= 1'b1;
        r_head[`TAG_SHIFT_BIT+`HEAD_WIDTH]      <= 1'b0;
        r_head[`TAG_TAIL_BIT+`HEAD_WIDTH]       <= 1'b0;
        r_head[`TAG_START_BIT+`HEAD_WIDTH]      <= i_head[`TAG_START_BIT+`HEAD_WIDTH];
        r_head[`HEAD_WIDTH+:`HEAD_SHIFT_WIDTH]  <= w_headShift;
        r_head[0+:`HEAD_WIDTH]                  <= i_head[0+:`HEAD_WIDTH];
      end
      else
        r_head[`TAG_VALID_BIT+`HEAD_WIDTH]      <= 1'b0;
      r_new_first_head                          <= 1'b1;
    end

    if(r_preMeta[`TAG_VALID_BIT+`META_WIDTH] & r_preMeta[`TAG_SHIFT_BIT+`META_WIDTH]) begin
      for(integer idx=0; idx<`META_CANDI_NUM; idx=idx+1) begin
        if(w_metaShift == (`META_CANDI_NUM-idx))
          r_meta[0+:`META_WIDTH]                <= w_2meta[0+idx*`SHIFT_WIDTH+:`META_WIDTH];
      end
      r_meta[`TAG_START_BIT+`META_WIDTH]        <= r_new_first_meta;
    end
    else if(w_meta_tag[`TAG_VALID_BIT] & w_meta_tag[`TAG_SHIFT_BIT] & w_meta_tag[`TAG_START_BIT]) begin
      if(|w_metaShift) begin
        r_meta[`TAG_VALID_BIT+`META_WIDTH]      <= 1'b1;
        r_meta[`TAG_SHIFT_BIT+`META_WIDTH]      <= 1'b0;
        r_meta[`TAG_TAIL_BIT+`META_WIDTH]       <= 1'b0;
        r_meta[`TAG_START_BIT+`META_WIDTH]      <= i_meta[`TAG_START_BIT+`HEAD_WIDTH];
        r_meta[`META_WIDTH+:`META_SHIFT_WIDTH]  <= w_metaShift;
        r_meta[0+:`META_WIDTH]                  <= i_meta[0+:`HEAD_WIDTH];
      end
      else
        r_meta[`TAG_VALID_BIT+`META_WIDTH]      <= 1'b0;
      r_new_first_meta                          <= 1'b1;
    end
	end

  `ifdef DEBUG
    wire    d_o_head_startBit, d_o_head_tailBit, d_o_head_shiftBit, d_o_head_validBit;
    assign  d_o_head_startBit = o_head[`TAG_START_BIT+`HEAD_WIDTH];
    assign  d_o_head_tailBit  = o_head[`TAG_TAIL_BIT+`HEAD_WIDTH];
    assign  d_o_head_shiftBit = o_head[`TAG_SHIFT_BIT+`HEAD_WIDTH];
    assign  d_o_head_validBit = o_head[`TAG_VALID_BIT+`HEAD_WIDTH];
  `endif


endmodule