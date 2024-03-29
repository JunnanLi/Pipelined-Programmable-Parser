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
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
  
  assign w_head_tag = i_head[`HEAD_WIDTH+:`TAG_WIDTH];
  assign w_meta_tag = i_meta[`META_WIDTH+:`TAG_WIDTH];
  assign w_2head    = {r_preHead, i_head};

	always_ff @(posedge i_clk) begin
    r_preHead                                   <= i_head;
    r_preMeta                                   <= i_meta;
    r_head                                      <= i_head;
    r_meta                                      <= i_meta;
    r_new_first_head                            <= 1'b1;
    r_new_first_meta                            <= 1'b1;
    if(w_head_tag[`TAG_VALID_BIT] & w_head_tag[`TAG_SHIFT_BIT] & ~w_head_tag[`TAG_START_BIT]) begin
      for(integer idx=0; idx<`HEAD_CANDI_NUM; idx=idx+1) begin
        if(i_headShift == idx)
          r_head[0+:`HEAD_WIDTH]                <= w_2head[0+idx*`SHIFT_WIDTH+:`HEAD_WIDTH];
      end
      r_head[`TAG_START_BIT]                    <= r_new_first_head;
    end
    else if(w_head_tag[`TAG_VALID_BIT] & w_head_tag[`TAG_SHIFT_BIT] & w_head_tag[`TAG_START_BIT]) begin
      if(|i_headShift) begin
        r_head[`HEAD_WIDTH+:`HEAD_SHIFT_WIDTH]  <= i_headShift;
        r_new_first_head                        <= 1'b1;
      end
    end
    if(w_meta_tag[`TAG_VALID_BIT] & w_meta_tag[`TAG_SHIFT_BIT] & ~w_meta_tag[`TAG_START_BIT]) begin
      for(integer idx=0; idx<`HEAD_CANDI_NUM; idx=idx+1) begin
        if(i_metaShift == idx)
          r_meta[0+:`META_WIDTH]                <= w_2meta[0+idx*`SHIFT_WIDTH+:`META_WIDTH];
      end
      r_meta[`TAG_START_BIT]                    <= r_new_first_meta;
    end
    else if(w_meta_tag[`TAG_VALID_BIT] & w_meta_tag[`TAG_SHIFT_BIT] & w_meta_tag[`TAG_START_BIT]) begin
      if(|i_metaShift) begin
        r_meta[`META_WIDTH+:`META_SHIFT_WIDTH]  <= i_metaShift;
        r_new_first_meta                        <= 1'b1;
      end
    end
	end

endmodule