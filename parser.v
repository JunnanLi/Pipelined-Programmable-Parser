/****************************************************/
//	Module name: parser_stage
//	Authority @ lijunnan (lijunnan@nudt.edu.cn)
//	Last edited time: 2019/12/04
//	Function outline: programmable parser
/****************************************************/


`timescale 1ns/1ps

module parser_stage(
input	clk,
input	reset,

//---conf--//
input				wren_rule,
input				rden_rule,
input		[2:0]	addr_rule,
input		[192:0]	data_rule,
output 	reg 		rdata_rule_valid,
output 	reg [192:0]	rdata_rule,

//--data--//
input				phv_in_valid,
input		[943:0]	phv_in,
output	reg 		phv_out_valid,
output	reg [943:0]	phv_out
);
parameter 	width_phv 	= 944,
			num_stage 	= 12,
			num_rule 	= 8;


/******************************	format of PHV ***********************************
	1)	16b*6	(extract info)
		->	1b, valid bit: means extract or not;
		->	5b, reserved
		->	10b offset for extractor: means where to extract;(range from 0 to 1KB)
	2)	8b
		->	4b, reserved;
		->	4b, bm_type: means choose which field as type field, 16b_1 to 8b_0;
	3)	32b		(length info)
		->	1b, 0 is fixed length; 1 is should be calculated;
		->	3b, reserved,
		->	4b, bm_len;
		->	16b, mask;
		->	8b, fixed length or 2b shift value? 
	4)	8b		next head type (ID); "0" is end;
	5)	16b
		->	8b, shift_value before extracting;
		->	8b,	shift_value for extracted fields;
	6)	16b
		->	6b, reserved,
		->	10b, shift_value for pkt header;(range from 0 to 1KB)
	7)	256b	extracted fields;
	8)	512b	packet header;
********************************************************************************/

reg [6:0]	pad7;
reg [5:0]	pad6;
reg [4:0]	pad5[5:0];
reg [3:0]	pad4;
reg [2:0]	pad3;

reg [5:0]	bm_ex[num_stage-1:0];			// bm of extractor, [0] is 8b_0, [5] is 32b_1;
reg [19:0]	ex_offset_8b[num_stage-1:0],	// offset of extractor, [0] is 8b_0;
			ex_offset_16b[num_stage-1:0],
			ex_offset_32b[num_stage-1:0];
	
reg [3:0]	bm_type[num_stage-1:0];			// choose which field as type field, 16b_1 to 8b_0;
			
reg 		fix_len_tag[num_stage-1:0];		// tag of lenght using fix (0) or length field (1);
reg [3:0]	bm_len[num_stage-1:0];			// choose which field as length field, 16b_1 to 8b_0;
reg [15:0]	len_mask[num_stage-1:0];		// mask of length field;
reg [7:0]	fix_len_or_shift_val[num_stage-1:0];	//	fix length or shift value to cal length;

reg [7:0]	shift_value_before_ex;			// Aligning for each protocol (keep empty fileds for empty proto)
reg	[7:0]	shift_value_ex[num_stage-1:0];	// length of extracted fields;
reg	[9:0]	shift_value[num_stage-1:0];		// offset of next header from Ethernet;
reg	[7:0]	next_hdr_type[num_stage-1:0];	// an ID of next header type;
reg	[255:0]	ex_field[num_stage-1:0];		// extracted fields;
reg	[511:0]	pkt_hdr[num_stage-1:0];			// Note: we do not change this data;

reg 		valid_temp[num_stage-1:0];		// valid signal of each stage;

integer i;
always @(posedge clk or negedge reset) begin
	if (!reset) begin
		// reset
		for(i=0; i<num_stage; i= i+1)
			valid_temp[i] <= 1'b0;
	end
	else begin
		valid_temp[1]	<= phv_in_valid;
		for(i=2; i<num_stage; i= i+1) begin
			valid_temp[i]	<= valid_temp[i-1];
		end		
	end
end	

always @(posedge clk) begin
	for(i=1; i<num_stage; i= i+1) begin
		fix_len_tag[i]	<= fix_len_tag[i-1];
		fix_len_or_shift_val[i] <= fix_len_or_shift_val[i-1];
		shift_value_ex[i] <= shift_value_ex[i-1];
		pkt_hdr[i]		<= pkt_hdr[i-1];
	end
	for(i=2; i<num_stage; i= i+1) begin
		ex_field[i]		<= ex_field[i-1];
	end
		
	{bm_ex[1],ex_offset_8b[1],ex_offset_16b[1],ex_offset_32b[1],
		bm_type[1],bm_len[1],len_mask[1],shift_value[1]} <= 
		{bm_ex[0],ex_offset_8b[0],ex_offset_16b[0],ex_offset_32b[0],
		bm_type[0],bm_len[0],len_mask[0],shift_value[0]};
	{bm_ex[2],ex_offset_8b[2],ex_offset_16b[2],ex_offset_32b[2],
		bm_type[2],bm_len[2],len_mask[2]} <= 
		{bm_ex[1],ex_offset_8b[1],ex_offset_16b[1],ex_offset_32b[1],
		bm_type[1],bm_len[1],len_mask[1]};
	{bm_ex[3],ex_offset_8b[3],ex_offset_16b[3],ex_offset_32b[3],
		bm_type[3],bm_len[3],len_mask[3]} <= 
		{bm_ex[2],ex_offset_8b[2],ex_offset_16b[2],ex_offset_32b[2],
		bm_type[2],bm_len[2],len_mask[2]};
	{bm_ex[4],len_mask[4]} <= {bm_ex[3],len_mask[3]};
	{bm_ex[5],len_mask[5]} <= {bm_ex[4],len_mask[4]};
	
	for(i=1; i<7; i=i+1) begin
		shift_value[i] 	<= shift_value[i-1];
	end
end

//	stage 0 (prepare): get data from PHV_in;
always @* begin
	{	bm_ex[0][0],pad5[0],ex_offset_8b[0][9:0], bm_ex[0][1],pad5[1],ex_offset_8b[0][19:10],
		bm_ex[0][2],pad5[2],ex_offset_16b[0][9:0],bm_ex[0][3],pad5[3],ex_offset_16b[0][19:10],
		bm_ex[0][4],pad5[4],ex_offset_32b[0][9:0],bm_ex[0][5],pad5[5],ex_offset_32b[0][19:10],
		pad4, bm_type[0],
		fix_len_tag[0],pad3,bm_len[0],len_mask[0],fix_len_or_shift_val[0],
		next_hdr_type[0], shift_value_before_ex, shift_value_ex[0],
		pad6, shift_value[0], ex_field[0], pkt_hdr[0]} = phv_in;
end

/** shift extracted field before extracting */
// stage 1
always @(posedge clk) begin
	case(shift_value_before_ex[3:1])
		2'd0: ex_field[1] <= ex_field[0];
		2'd1: ex_field[1] <= {ex_field[0][239:0],16'd0};
		2'd2: ex_field[1] <= {ex_field[0][223:0],32'b0};
		2'd3: ex_field[1] <= {ex_field[0][207:0],48'b0};
		default: begin
		end
	endcase
end


/** locate header*/
reg	[511:0]	pkt_hdr_temp[2:1];	// used to shift

// stage 1 & 2, i.e, phv_in_valid for stage 1, valid_temp[1] for stage 2;
always @(posedge clk) begin
	//	stage 1: shift_stage_1, Aligned by 64b;
	case(shift_value[0][5:3])
		3'd0: pkt_hdr_temp[1] 	<= pkt_hdr[0];
		3'd1: pkt_hdr_temp[1]	<= {pkt_hdr[0][447:0],pkt_hdr[0][511:448]};
		3'd2: pkt_hdr_temp[1]	<= {pkt_hdr[0][383:0],pkt_hdr[0][511:384]};
		3'd3: pkt_hdr_temp[1]	<= {pkt_hdr[0][319:0],pkt_hdr[0][511:320]};
		3'd4: pkt_hdr_temp[1]	<= {pkt_hdr[0][255:0],pkt_hdr[0][511:256]};
		3'd5: pkt_hdr_temp[1]	<= {pkt_hdr[0][191:0],pkt_hdr[0][511:192]};
		3'd6: pkt_hdr_temp[1]	<= {pkt_hdr[0][127:0],pkt_hdr[0][511:128]};
		3'd7: pkt_hdr_temp[1]	<= {pkt_hdr[0][63:0], pkt_hdr[0][511:64]};
		default: pkt_hdr_temp[1]<= pkt_hdr[0];
	endcase

	//	stage 2: shift_stage_2, Aligned by 8b;
	case(shift_value[1][2:0])
		3'd0: pkt_hdr_temp[2] 	<= pkt_hdr_temp[1];
		3'd1: pkt_hdr_temp[2]	<= {pkt_hdr_temp[1][503:0],pkt_hdr_temp[1][511:504]};
		3'd2: pkt_hdr_temp[2]	<= {pkt_hdr_temp[1][495:0],pkt_hdr_temp[1][511:496]};
		3'd3: pkt_hdr_temp[2]	<= {pkt_hdr_temp[1][487:0],pkt_hdr_temp[1][511:488]};
		3'd4: pkt_hdr_temp[2]	<= {pkt_hdr_temp[1][479:0],pkt_hdr_temp[1][511:480]};
		3'd5: pkt_hdr_temp[2]	<= {pkt_hdr_temp[1][471:0],pkt_hdr_temp[1][511:472]};
		3'd6: pkt_hdr_temp[2]	<= {pkt_hdr_temp[1][463:0],pkt_hdr_temp[1][511:464]};
		3'd7: pkt_hdr_temp[2]	<= {pkt_hdr_temp[1][455:0],pkt_hdr_temp[1][511:456]};
		default: pkt_hdr_temp[2]<= pkt_hdr_temp[1];
	endcase
end



/** extract fields */

reg [63:0]	ex_field_8b_1st[1:0];	// Aligned by 64b;
reg [63:0]	ex_field_16b_1st[1:0];
reg [63:0]	ex_field_32b_1st[1:0];

reg [7:0]	ex_field_8b_2nd[1:0];	// Aligned by 8b;
reg [15:0]	ex_field_16b_2nd[1:0];
reg [31:0]	ex_field_32b_2nd[1:0];

reg [95:0] ex_field_96b;			// used to combine 16b & 32b: 16*2 + 32*2;
reg [15:0]	ex_field_16b;			// used to combine 8b: 8*2;
reg [111:0]	ex_field_112b;			// used to combine all;

reg [287:0]	pkt_hdr_288b;			// used to combine with previous extracted fields;

// stage 3 & 4 & 5, i.e, valid_temp[2] & valid_temp[3] & valid_temp[4];

generate
genvar gen_i;
for(gen_i=0; gen_i<2; gen_i=gen_i+1) begin: gen_extractor
	always @(posedge clk) begin	
		//	stage 3: extract 64b from 512b;
		case(ex_offset_8b[2][(5+10*gen_i):(3+10*gen_i)])
			3'd0: ex_field_8b_1st[gen_i] 	<= pkt_hdr_temp[2][63:0];
			3'd1: ex_field_8b_1st[gen_i] 	<= pkt_hdr_temp[2][127:64];
			3'd2: ex_field_8b_1st[gen_i] 	<= pkt_hdr_temp[2][191:128];
			3'd3: ex_field_8b_1st[gen_i] 	<= pkt_hdr_temp[2][255:192];
			3'd4: ex_field_8b_1st[gen_i] 	<= pkt_hdr_temp[2][319:256];
			3'd5: ex_field_8b_1st[gen_i] 	<= pkt_hdr_temp[2][383:320];
			3'd6: ex_field_8b_1st[gen_i] 	<= pkt_hdr_temp[2][447:384];
			3'd7: ex_field_8b_1st[gen_i] 	<= pkt_hdr_temp[2][511:448];
			default: ex_field_8b_1st[gen_i] <= pkt_hdr_temp[2][63:0];
		endcase
		case(ex_offset_16b[2][(5+10*gen_i):(3+10*gen_i)])
			3'd0: ex_field_16b_1st[gen_i] 	<= pkt_hdr_temp[2][63:0];
			3'd1: ex_field_16b_1st[gen_i] 	<= pkt_hdr_temp[2][127:64];
			3'd2: ex_field_16b_1st[gen_i] 	<= pkt_hdr_temp[2][191:128];
			3'd3: ex_field_16b_1st[gen_i] 	<= pkt_hdr_temp[2][255:192];
			3'd4: ex_field_16b_1st[gen_i] 	<= pkt_hdr_temp[2][319:256];
			3'd5: ex_field_16b_1st[gen_i] 	<= pkt_hdr_temp[2][383:320];
			3'd6: ex_field_16b_1st[gen_i] 	<= pkt_hdr_temp[2][447:384];
			3'd7: ex_field_16b_1st[gen_i] 	<= pkt_hdr_temp[2][511:448];
			default: ex_field_16b_1st[gen_i]<= pkt_hdr_temp[2][63:0];
		endcase
		case(ex_offset_32b[2][(5+10*gen_i):(3+10*gen_i)])
			3'd0: ex_field_32b_1st[gen_i] 	<= pkt_hdr_temp[2][63:0];
			3'd1: ex_field_32b_1st[gen_i] 	<= pkt_hdr_temp[2][127:64];
			3'd2: ex_field_32b_1st[gen_i] 	<= pkt_hdr_temp[2][191:128];
			3'd3: ex_field_32b_1st[gen_i] 	<= pkt_hdr_temp[2][255:192];
			3'd4: ex_field_32b_1st[gen_i] 	<= pkt_hdr_temp[2][319:256];
			3'd5: ex_field_32b_1st[gen_i] 	<= pkt_hdr_temp[2][383:320];
			3'd6: ex_field_32b_1st[gen_i] 	<= pkt_hdr_temp[2][447:384];
			3'd7: ex_field_32b_1st[gen_i] 	<= pkt_hdr_temp[2][511:448];
			default: ex_field_32b_1st[gen_i]<= pkt_hdr_temp[2][63:0];
		endcase


		//	stage 4: extract 8b/16b/32b from 64b;
		case(ex_offset_8b[3][(2+10*gen_i):(0+10*gen_i)])
			3'd0: ex_field_8b_2nd[gen_i] 	<= ex_field_8b_1st[gen_i][7:0];
			3'd1: ex_field_8b_2nd[gen_i] 	<= ex_field_8b_1st[gen_i][15:8];
			3'd2: ex_field_8b_2nd[gen_i] 	<= ex_field_8b_1st[gen_i][23:16];
			3'd3: ex_field_8b_2nd[gen_i] 	<= ex_field_8b_1st[gen_i][31:24];
			3'd4: ex_field_8b_2nd[gen_i] 	<= ex_field_8b_1st[gen_i][39:32];
			3'd5: ex_field_8b_2nd[gen_i] 	<= ex_field_8b_1st[gen_i][47:40];
			3'd6: ex_field_8b_2nd[gen_i] 	<= ex_field_8b_1st[gen_i][55:48];
			3'd7: ex_field_8b_2nd[gen_i] 	<= ex_field_8b_1st[gen_i][63:56];
			default: ex_field_8b_2nd[gen_i] <= ex_field_8b_1st[gen_i][7:0];
		endcase
		case(ex_offset_16b[3][(2+10*gen_i):(1+10*gen_i)])
			2'd0: ex_field_16b_2nd[gen_i] 	<= ex_field_16b_1st[gen_i][15:0];
			2'd1: ex_field_16b_2nd[gen_i] 	<= ex_field_16b_1st[gen_i][31:16];
			2'd2: ex_field_16b_2nd[gen_i] 	<= ex_field_16b_1st[gen_i][47:32];
			2'd3: ex_field_16b_2nd[gen_i] 	<= ex_field_16b_1st[gen_i][63:48];
			default: ex_field_16b_2nd[gen_i]<= ex_field_16b_1st[gen_i][15:0];
		endcase
		case(ex_offset_32b[3][2+10*gen_i])
			1'd0: ex_field_32b_2nd[gen_i] 	<= ex_field_32b_1st[gen_i][31:0];
			1'd1: ex_field_32b_2nd[gen_i] 	<= ex_field_32b_1st[gen_i][63:32];
			default: ex_field_32b_2nd[gen_i]<= ex_field_32b_1st[gen_i][31:0];
		endcase
	end
end	
endgenerate

always @(posedge clk) begin
	// stage 5: merge 16b and 32b extracted fields;
	case(bm_ex[4][3:2])
		2'b00: ex_field_96b <= {ex_field_32b_2nd[0],ex_field_32b_2nd[1],32'b0};
		2'b01: ex_field_96b <= {ex_field_16b_2nd[0],ex_field_32b_2nd[0],ex_field_32b_2nd[1],16'b0};
		2'b11: ex_field_96b <= {ex_field_16b_2nd[0],ex_field_16b_2nd[1],ex_field_32b_2nd[0],ex_field_32b_2nd[1]};
		default: ex_field_96b <= 96'b0; 
	endcase
	ex_field_16b <= {ex_field_8b_2nd[0],ex_field_8b_2nd[1]};
	

	// stage 6: merge 8b and 96b extracted fields;
	case(bm_ex[5][1:0])
		2'b00: ex_field_112b <= {ex_field_96b,16'b0};
		2'b01: ex_field_112b <= {ex_field_16b[15:8],ex_field_96b,8'b0};
		2'b11: ex_field_112b <= {ex_field_16b,ex_field_96b};
		default: ex_field_112b <= 112'b0; 
	endcase

	// stage 7: merge 112b with previous extracted fields;
	case(shift_value_ex[6][3:2])
		2'd0: pkt_hdr_288b	<= {ex_field[6],ex_field_112b[111:80]};
		2'd1: pkt_hdr_288b	<= {ex_field[6][223:0],ex_field_112b[111:48]};
		2'd2: pkt_hdr_288b	<= {ex_field[6][191:0],ex_field_112b[111:16]};
		2'd3: pkt_hdr_288b	<= {ex_field[6][159:0],ex_field_112b[111:0],16'b0};
		default: pkt_hdr_288b<= {ex_field[6],ex_field_112b[111:80]};
	endcase

	// stage 8: merge 112b with previous extracted fields;
	case(shift_value_ex[7][1:0])
		3'd0: phv_out[767:512]		<= pkt_hdr_288b[287:32];
		3'd1: phv_out[767:512]		<= pkt_hdr_288b[279:24];
		3'd2: phv_out[767:512]		<= pkt_hdr_288b[271:16];
		3'd3: phv_out[767:512]		<= pkt_hdr_288b[263:8];
		default: phv_out[767:512]	<= pkt_hdr_288b[287:32];
	endcase
end

/** sel type & length field */
reg [15:0]	type_field, len_field;

always @(posedge clk) begin
	//	stage 4: guarantee bm_type and bm_len is not "0";
	if(bm_type[3] == 4'b0)
		bm_type[4] <= 4'd1;
	else
		bm_type[4] <= bm_type[3];
	if(bm_len[3] == 4'b0)
		bm_len[4] <= 4'd1;
	else
		bm_len[4] <= bm_len[3];
	
	//	stage 5: sel type_field;
	(* parallel_case *)
	case (1'b1)
		bm_type[4][0]: type_field <= {8'b0,ex_field_8b_2nd[0]};
		bm_type[4][1]: type_field <= {8'b0,ex_field_8b_2nd[1]};
		bm_type[4][2]: type_field <= ex_field_16b_2nd[0];
		bm_type[4][3]: type_field <= ex_field_16b_2nd[1];
	endcase
	
	//	stage 5: sel len_field;
	(* parallel_case *)
	case (1'b1)
		bm_len[4][0]: len_field <= {8'b0,ex_field_8b_2nd[0]};
		bm_len[4][1]: len_field <= {8'b0,ex_field_8b_2nd[1]};
		bm_len[4][2]: len_field <= ex_field_16b_2nd[0];
		bm_len[4][3]: len_field <= ex_field_16b_2nd[1];
	endcase
end

reg [7:0]	bm_rule;	// valid of rule;
reg [15:0]	rule_key[num_rule-1:0];
reg [15:0]	rule_mask[num_rule-1:0];
reg [159:0]	rule_action[num_rule-1:0];

/**	format of rule_action
	1)	16b*6	(extract info)
		->	1b, valid bit: means extract or not;
		->	5b, reserved
		->	10b offset for extractor: means where to extract;(range from 0 to 1KB)
	2)	8b
		->	4b, reserved;
		->	4b, bm_type: means choose which field as type field, 16b_1 to 8b_0;
	3)	32b		(length info)
		->	1b, 0 is fixed length; 1 is should be calculated;
		->	3b, reserved,
		->	4b, bm_len;
		->	16b, mask;
		->	8b, fixed length or 2b shift value? 
	4)	8b		next head type (ID); "0" is end;
	5)	16b
		->	8b, shift_value before extracting;
		->	8b,	shift_value for extracted fields;
*/

reg [7:0]	bm_hit_rule;
reg [159:0]	rule_action_hit;
reg [7:0]	len_calc;

/** lookup type, calc length, and recombine extracted fields */
always @(posedge clk) begin

	/** lookup type */
	//	stage 6: lookup rule;
	for(i=0; i<num_rule; i=i+1) begin
		if((bm_rule[i] == 1'b1) && ((type_field&rule_mask[i]) == rule_key[i]))
			bm_hit_rule[i] <= 1'b1;
		else
			bm_hit_rule[i] <= 1'b0;
	end

	//	stage 7: get action;
	(* parallel_case *)
	casez(bm_hit_rule)
		8'b1???????: rule_action_hit	<=	rule_action[7];
		8'b01??????: rule_action_hit	<=	rule_action[6];
		8'b001?????: rule_action_hit	<=	rule_action[5];
		8'b0001????: rule_action_hit	<=	rule_action[4];
		8'b00001???: rule_action_hit	<=	rule_action[3];
		8'b000001??: rule_action_hit	<=	rule_action[2];
		8'b0000001?: rule_action_hit	<=	rule_action[1];
		8'b00000001: rule_action_hit	<=	rule_action[0];
		8'b00000000: rule_action_hit	<=	160'b0;
	endcase

	//	stage 6: calc length;
	len_calc <= len_field[7:0]&len_mask[5][7:0];

	//	stage 7: get shift_value (length);
	if(fix_len_tag[6] == 1'b0)	shift_value[7] <= {2'b0,fix_len_or_shift_val[6]} + shift_value[6];
	else begin
		case(fix_len_or_shift_val[6][1:0])
			2'd0:	shift_value[7] <= {2'b0,len_calc} + shift_value[6];
			2'd1:	shift_value[7] <= {2'b0,len_calc[6:0],1'b0} + shift_value[6];
			2'd2:	shift_value[7] <= {2'b0,len_calc[5:0],2'b0} + shift_value[6];
			2'd3:	shift_value[7] <= {2'b0,len_calc[4:0],3'b0} + shift_value[6];
			default:shift_value[7] <= {2'b0,len_calc} + shift_value[6];
		endcase
	end
end


/** recomebine */
always @(posedge clk or negedge reset) begin
	if(!reset) begin
		phv_out_valid 		<= 1'b0;
		phv_out[943:768]	<= 176'b0;
		phv_out[511:0]		<= 512'b0;
	end
	else begin
		phv_out[943:768]	<= {rule_action_hit, 6'b0, shift_value[7]};
		phv_out[511:0]		<= pkt_hdr[7];
		phv_out_valid		<= valid_temp[7];
	end
end

/**	configue rule*/
always @(posedge clk or negedge reset) begin
	if (!reset) begin
		// reset
		bm_rule <= 8'b0;
		rdata_rule_valid <= 1'b0;
		rdata_rule <= 193'b0;
	end
	else begin
		if(wren_rule == 1'b1) begin
			for(i=0; i<num_rule; i=i+1) begin
				if(addr_rule == i)
					{bm_rule[i],rule_key[i],rule_mask[i],rule_action[i]} <= data_rule;
			end
		end
		
		if(rden_rule == 1'b1) begin
			case(addr_rule)
				3'd0: rdata_rule <= {bm_rule[0],rule_key[0],rule_mask[0],rule_action[0]};
				3'd1: rdata_rule <= {bm_rule[1],rule_key[1],rule_mask[1],rule_action[1]};
				3'd2: rdata_rule <= {bm_rule[2],rule_key[2],rule_mask[2],rule_action[2]};
				3'd3: rdata_rule <= {bm_rule[3],rule_key[3],rule_mask[3],rule_action[3]};
				3'd4: rdata_rule <= {bm_rule[4],rule_key[4],rule_mask[4],rule_action[4]};
				3'd5: rdata_rule <= {bm_rule[5],rule_key[5],rule_mask[5],rule_action[5]};
				3'd6: rdata_rule <= {bm_rule[6],rule_key[6],rule_mask[6],rule_action[6]};
				3'd7: rdata_rule <= {bm_rule[7],rule_key[7],rule_mask[7],rule_action[7]};
				default: rdata_rule <= 193'b0;
			endcase
		end
		rdata_rule_valid <= rden_rule;
	end
end


endmodule