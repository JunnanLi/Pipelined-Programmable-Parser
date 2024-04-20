/****************************************************/
//	Module name: parser_deparser
//	Authority @ lijunnan (lijunnan@nudt.edu.cn)
//	Last edited time: 2020/03/21
//	Function outline: programmable parser
/****************************************************/


`timescale 1ns/1ps

module parser_deparser(
input					clk,
input					reset,

//---conf--//
input					wren_rule,
input					rden_rule,
input		[2:0]		addr_rule,
input		[176:0]		data_rule,
output 	reg 			rdata_rule_valid,
output 	reg [176:0]		rdata_rule,

//--data--//
input					phv_in_valid,
input		[2207:0]	phv_in,
output	reg 			phv_out_valid,
output	reg [2207:0]	phv_out
);
parameter 	width_parsData 	= 1024,
			width_procData 	= 1024,
			width_typeInfo	= 160,
			width_phv 		= width_parsData+width_procData+width_typeInfo,
			num_stage		= 10,
			num_rule 		= 8;


/********************** format of PHV: total 2208bb ******************************
	1)	8b		shifting value for locating parsData in 1B;(range from 0 to 2Kb)
	2)	8b		shifted value for recovering procData in 1B;(range from 0 to 2Kb)
	3)	8b		current type;
	4)	8b		type field info: to extract 2B
		->	1b	valid bit: means extract or not;
		->	7b	offset to extract type field,
	5)	32b		length info
		->	1b	0 is fixed length; 1 is should be calculated;
		->	7b	offset to extract length field,
		->	16b	mask;
		->	8b	fixed length or 2b shift value? 
	6)	8b*8	extract info, extractor are: two 1B, two 2B, two 4B, two 8B)
		->	1b	valid bit: means extract or not;
		->	7b	offset for extractor: means where to extract;(range from 0 to 1kb)
	7)	32b 	construction info
		->	8b	offset for locating procData in relative location;
		->	8b	length of extracted fields
		->	8b 	act: 0 is del, 1 is add, 2 is replace;
		->	8b 	shift value for gen a new procData (length of added/deleted header
					or length of left header after replacing);
	8)	1024b	parsData;
	9)	1024b	procData;
********************************************************************************/
//*	previous parsData
reg	[7:0]	lenPars_8b[num_stage-1:0];				// for locating parsData;
//*	previous procData
reg	[7:0]	lenProc_8b[num_stage-1:0];				// for recorving procData;
//*	current type
reg	[7:0]	curType_8b;								// not used yet;
//*	type and length
reg	[1:0]	bmExTypeLength_2b[num_stage-1:0];		// [0] is type, 1 is length
reg [13:0]	exOffsetTypeLength_16b[num_stage-1:0];
reg [15:0]	lenMask_16b[num_stage-1:0];				// mask of length field;
reg [7:0]	fixLen_or_shiftVal_8b[num_stage-1:0];	//	fix length or shift value to cal length;
//*	extract info
reg [7:0]	bmEx_8b[num_stage-1:0];					// bm of extractor, [0] is 8b_0, [7] is 64b_1;
reg [13:0]	exOffset_8b[num_stage-1:0],				// offset of extractor;
			exOffset_16b[num_stage-1:0],
			exOffset_32b[num_stage-1:0],
			exOffset_64b[num_stage-1:0];
//*	construct info		
reg [7:0]	constrOffset_8b[num_stage-1:0];
reg	[7:0]	constrLength_8b[num_stage-1:0];	
reg	[7:0]	constrAct_8b[num_stage-1:0];		
reg	[7:0]	constrShiftVal_8b[num_stage-1:0];	
//*	data
reg	[width_parsData-1:0]	parsData[num_stage-1:0];	// Note: we do not change this data;
reg	[width_procData-1:0]	procData[num_stage-1:0];	// extracted fields;
//*	valid for counting clk
reg 		valid_temp[num_stage-1:1];		// valid signal of each stage;

//*	coungint clk;
integer i;
always @(posedge clk or negedge reset) begin
	if (!reset) begin
		// reset
		for(i=1; i<num_stage; i= i+1)
			valid_temp[i] <= 1'b0;
	end
	else begin
		valid_temp[1]	<= phv_in_valid;
		for(i=2; i<num_stage; i= i+1) begin
			valid_temp[i]	<= valid_temp[i-1];
		end		
	end
end	

//	stage 0 (prepare): get data from PHV_in;
always @* begin
	{	lenPars_8b[0], lenProc_8b[0], curType_8b,
		bmExTypeLength_2b[0][0], exOffsetTypeLength_16b[0][6:0],
		bmExTypeLength_2b[0][1], exOffsetTypeLength_16b[0][13:7], lenMask_16b[0],fixLen_or_shiftVal_8b[0],
		bmEx_8b[0][0],exOffset_8b[0][6:0],  bmEx_8b[0][1],exOffset_8b[0][13:7],
		bmEx_8b[0][2],exOffset_16b[0][6:0], bmEx_8b[0][3],exOffset_16b[0][13:7],
		bmEx_8b[0][4],exOffset_32b[0][6:0], bmEx_8b[0][5],exOffset_32b[0][13:7],
		bmEx_8b[0][6],exOffset_64b[0][6:0], bmEx_8b[0][7],exOffset_64b[0][13:7],
		constrOffset_8b[0],constrLength_8b[0],constrAct_8b[0],constrShiftVal_8b[0],
		parsData[0],procData[0]} = phv_in;
end



always @(posedge clk) begin
	//* stage 1
	//* update lenProc_8b by adding constrShiftVal_8b
	lenProc_8b[1]					<= constrOffset_8b[0] + lenProc_8b[0];
	lenProc_8b[6]					<= constrShiftVal_8b[5] + lenProc_8b[5];

	for(i=1; i<num_stage; i=i+1) begin
		bmExTypeLength_2b[i]		<= bmExTypeLength_2b[i-1];
		exOffsetTypeLength_16b[i]	<= exOffsetTypeLength_16b[i-1];
		lenMask_16b[i]				<= lenMask_16b[i-1];
		fixLen_or_shiftVal_8b[i]	<= fixLen_or_shiftVal_8b[i-1];
		bmEx_8b[i]					<= bmEx_8b[i-1];
		exOffset_8b[i]				<= exOffset_8b[i-1];
		exOffset_16b[i]				<= exOffset_16b[i-1];
		exOffset_32b[i]				<= exOffset_32b[i-1];
		exOffset_64b[i]				<= exOffset_64b[i-1];
		constrOffset_8b[i]			<= constrOffset_8b[i-1];
		constrLength_8b[i]			<= constrLength_8b[i-1];
		constrAct_8b[i]				<= constrAct_8b[i-1];
		constrShiftVal_8b[i]		<= constrShiftVal_8b[i-1];
		parsData[i]					<= parsData[i-1];
	end
	{lenPars_8b[9],lenPars_8b[8],lenPars_8b[7],lenPars_8b[5],lenPars_8b[4],lenPars_8b[3],lenPars_8b[2],lenPars_8b[1]} <= {
		lenPars_8b[8],lenPars_8b[7],lenPars_8b[6],lenPars_8b[4],lenPars_8b[3],lenPars_8b[2],lenPars_8b[1],lenPars_8b[0]};
	{lenProc_8b[9],lenProc_8b[8],lenProc_8b[7],lenProc_8b[5],lenProc_8b[4],lenProc_8b[3],lenProc_8b[2]} <= {
		lenProc_8b[8],lenPars_8b[7],lenProc_8b[6],lenProc_8b[4],lenProc_8b[3],lenProc_8b[2],lenProc_8b[1]};
	{procData[2],procData[1]} 		<= {procData[1],procData[0]};
end


/** locate header*/
reg [1023:0]	parsDataTemp_1024b;
reg [511:0]		parsDataTemp_512b;

// stage 1-2: locate header
always @(posedge clk) begin
	//	stage 1: shift_stage_1, Aligned by 64b;
	(*parallel_case, full_case *)
	case(lenPars_8b[0][6:4])
		3'd0: parsDataTemp_1024b	<=  parsData[0];
		3'd1: parsDataTemp_1024b	<= {parsData[0][895:0],128'b0};
		3'd2: parsDataTemp_1024b	<= {parsData[0][767:0],256'b0};
		3'd7: parsDataTemp_1024b	<= {parsData[0][639:0],384'b0};
		3'd3: parsDataTemp_1024b	<= {parsData[0][511:0],512'b0};
		3'd4: parsDataTemp_1024b	<= {parsData[0][383:0],640'b0};
		3'd5: parsDataTemp_1024b	<= {parsData[0][255:0],768'b0};
		3'd6: parsDataTemp_1024b	<= {parsData[0][127:0],896'b0};
	endcase

	//	stage 2: shift_stage_2, Aligned by 16b;
	(*parallel_case, full_case *)
	case(lenPars_8b[1][3:1])
		3'd0: parsDataTemp_512b 	<= parsDataTemp_1024b[1023:512];
		3'd1: parsDataTemp_512b		<= parsDataTemp_1024b[1007:496];
		3'd2: parsDataTemp_512b		<= parsDataTemp_1024b[991:480];
		3'd3: parsDataTemp_512b		<= parsDataTemp_1024b[975:464];
		3'd4: parsDataTemp_512b		<= parsDataTemp_1024b[959:448];
		3'd5: parsDataTemp_512b		<= parsDataTemp_1024b[943:432];
		3'd6: parsDataTemp_512b		<= parsDataTemp_1024b[927:416];
		3'd7: parsDataTemp_512b		<= parsDataTemp_1024b[911:400];
	endcase
end


/** extract fields */
reg [63:0]		exField1_8b[1:0];	// Aligned by 64b;
reg [63+8:0]	exField1_16b[1:0];
reg [63+24:0]	exField1_32b[1:0];
reg [119:0]		exField1_64b[1:0];
reg [63+8:0]	exField1_typeLength_16b[1:0];

reg [7:0]	exField2_8b[1:0];	// Aligned by 8b;
reg [15:0]	exField2_16b[1:0];
reg [31:0]	exField2_32b[1:0];
reg [63:0]	exField2_64b[1:0];
reg [15:0]	exField2_typeLength_16b[1:0];


// stage 3 & 4: extract fields
generate
genvar gen_i;
	for(gen_i=0; gen_i<2; gen_i=gen_i+1) begin: gen_extractor
		always @(posedge clk) begin	
			//	stage 3: extract 64b from 512b: Aligned by 64b;
			(* parallel_case, full_case *)
			case(exOffset_8b[2][(5+7*gen_i):(3+7*gen_i)])
				3'd7: exField1_8b[gen_i] 	<= parsDataTemp_512b[63:0];
				3'd6: exField1_8b[gen_i] 	<= parsDataTemp_512b[127:64];
				3'd5: exField1_8b[gen_i] 	<= parsDataTemp_512b[191:128];
				3'd4: exField1_8b[gen_i] 	<= parsDataTemp_512b[255:192];
				3'd3: exField1_8b[gen_i] 	<= parsDataTemp_512b[319:256];
				3'd2: exField1_8b[gen_i] 	<= parsDataTemp_512b[383:320];
				3'd1: exField1_8b[gen_i] 	<= parsDataTemp_512b[447:384];
				3'd0: exField1_8b[gen_i] 	<= parsDataTemp_512b[511:448];
			endcase
			(* parallel_case, full_case *)
			case(exOffset_16b[2][(5+7*gen_i):(3+7*gen_i)])
				3'd7: exField1_16b[gen_i] 	<= {parsDataTemp_512b[63:0],8'b0};
				3'd6: exField1_16b[gen_i] 	<= parsDataTemp_512b[127:64-8];
				3'd5: exField1_16b[gen_i] 	<= parsDataTemp_512b[191:128-8];
				3'd4: exField1_16b[gen_i] 	<= parsDataTemp_512b[255:192-8];
				3'd3: exField1_16b[gen_i] 	<= parsDataTemp_512b[319:256-8];
				3'd2: exField1_16b[gen_i] 	<= parsDataTemp_512b[383:320-8];
				3'd1: exField1_16b[gen_i] 	<= parsDataTemp_512b[447:384-8];
				3'd0: exField1_16b[gen_i] 	<= parsDataTemp_512b[511:448-8];
			endcase
			(* parallel_case, full_case *)
			case(exOffset_32b[2][(5+7*gen_i):(3+7*gen_i)])
				3'd7: exField1_32b[gen_i] 	<= {parsDataTemp_512b[63:0],24'b0};
				3'd6: exField1_32b[gen_i] 	<= parsDataTemp_512b[127:64-24];
				3'd5: exField1_32b[gen_i] 	<= parsDataTemp_512b[191:128-24];
				3'd4: exField1_32b[gen_i] 	<= parsDataTemp_512b[255:192-24];
				3'd3: exField1_32b[gen_i] 	<= parsDataTemp_512b[319:256-24];
				3'd2: exField1_32b[gen_i] 	<= parsDataTemp_512b[383:320-24];
				3'd1: exField1_32b[gen_i] 	<= parsDataTemp_512b[447:384-24];
				3'd0: exField1_32b[gen_i] 	<= parsDataTemp_512b[511:448-24];
			endcase
			(* parallel_case, full_case *)
			case(exOffset_64b[2][(5+7*gen_i):(3+7*gen_i)])
				3'd7: exField1_64b[gen_i] 	<= {parsDataTemp_512b[63:0],56'b0};
				3'd6: exField1_64b[gen_i] 	<= parsDataTemp_512b[127:64-56];
				3'd5: exField1_64b[gen_i] 	<= parsDataTemp_512b[191:128-56];
				3'd4: exField1_64b[gen_i] 	<= parsDataTemp_512b[255:192-56];
				3'd3: exField1_64b[gen_i] 	<= parsDataTemp_512b[319:256-56];
				3'd2: exField1_64b[gen_i] 	<= parsDataTemp_512b[383:320-56];
				3'd1: exField1_64b[gen_i] 	<= parsDataTemp_512b[447:384-56];
				3'd0: exField1_64b[gen_i] 	<= parsDataTemp_512b[511:448-56];
			endcase
			(* parallel_case, full_case *)
			case(exOffsetTypeLength_16b[2][(5+7*gen_i):(3+7*gen_i)])
				3'd7: exField1_typeLength_16b[gen_i] 	<= {parsDataTemp_512b[63:0],8'b0};
				3'd6: exField1_typeLength_16b[gen_i] 	<= parsDataTemp_512b[127:64-8];
				3'd5: exField1_typeLength_16b[gen_i] 	<= parsDataTemp_512b[191:128-8];
				3'd4: exField1_typeLength_16b[gen_i] 	<= parsDataTemp_512b[255:192-8];
				3'd3: exField1_typeLength_16b[gen_i] 	<= parsDataTemp_512b[319:256-8];
				3'd2: exField1_typeLength_16b[gen_i] 	<= parsDataTemp_512b[383:320-8];
				3'd1: exField1_typeLength_16b[gen_i] 	<= parsDataTemp_512b[447:384-8];
				3'd0: exField1_typeLength_16b[gen_i] 	<= parsDataTemp_512b[511:448-8];
			endcase


			//	stage 4: extract 8b/16b/32b from 64b;
			(* parallel_case, full_case *)
			case(exOffset_8b[3][(2+7*gen_i):(7*gen_i)])
				3'd7: exField2_8b[gen_i] 	<= exField1_8b[gen_i][7:0];
				3'd6: exField2_8b[gen_i] 	<= exField1_8b[gen_i][15:8];
				3'd5: exField2_8b[gen_i] 	<= exField1_8b[gen_i][23:16];
				3'd4: exField2_8b[gen_i] 	<= exField1_8b[gen_i][31:24];
				3'd3: exField2_8b[gen_i] 	<= exField1_8b[gen_i][39:32];
				3'd2: exField2_8b[gen_i] 	<= exField1_8b[gen_i][47:40];
				3'd1: exField2_8b[gen_i] 	<= exField1_8b[gen_i][55:48];
				3'd0: exField2_8b[gen_i] 	<= exField1_8b[gen_i][63:56];
			endcase
			(* parallel_case, full_case *)
			case(exOffset_16b[3][(2+7*gen_i):(7*gen_i)])
				3'd7: exField2_16b[gen_i] 	<= exField1_16b[gen_i][7+8:0];
				3'd6: exField2_16b[gen_i] 	<= exField1_16b[gen_i][15+8:8];
				3'd5: exField2_16b[gen_i] 	<= exField1_16b[gen_i][23+8:16];
				3'd4: exField2_16b[gen_i] 	<= exField1_16b[gen_i][31+8:24];
				3'd3: exField2_16b[gen_i] 	<= exField1_16b[gen_i][39+8:32];
				3'd2: exField2_16b[gen_i] 	<= exField1_16b[gen_i][47+8:40];
				3'd1: exField2_16b[gen_i] 	<= exField1_16b[gen_i][55+8:48];
				3'd0: exField2_16b[gen_i] 	<= exField1_16b[gen_i][63+8:56];
			endcase
			(* parallel_case, full_case *)
			case(exOffset_32b[3][(2+7*gen_i):(7*gen_i)])
				3'd7: exField2_32b[gen_i] 	<= exField1_32b[gen_i][7+24:0];
				3'd6: exField2_32b[gen_i] 	<= exField1_32b[gen_i][15+24:8];
				3'd5: exField2_32b[gen_i] 	<= exField1_32b[gen_i][23+24:16];
				3'd4: exField2_32b[gen_i] 	<= exField1_32b[gen_i][31+24:24];
				3'd3: exField2_32b[gen_i] 	<= exField1_32b[gen_i][39+24:32];
				3'd2: exField2_32b[gen_i] 	<= exField1_32b[gen_i][47+24:40];
				3'd1: exField2_32b[gen_i] 	<= exField1_32b[gen_i][55+24:48];
				3'd0: exField2_32b[gen_i] 	<= exField1_32b[gen_i][63+24:56];
			endcase
			(* parallel_case, full_case *)
			case(exOffset_64b[3][(2+7*gen_i):(7*gen_i)])
				3'd7: exField2_64b[gen_i] 	<= exField1_64b[gen_i][63:0];
				3'd6: exField2_64b[gen_i] 	<= exField1_64b[gen_i][71:8];
				3'd5: exField2_64b[gen_i] 	<= exField1_64b[gen_i][79:16];
				3'd4: exField2_64b[gen_i] 	<= exField1_64b[gen_i][87:24];
				3'd3: exField2_64b[gen_i] 	<= exField1_64b[gen_i][95:32];
				3'd2: exField2_64b[gen_i] 	<= exField1_64b[gen_i][103:40];
				3'd1: exField2_64b[gen_i] 	<= exField1_64b[gen_i][111:48];
				3'd0: exField2_64b[gen_i] 	<= exField1_64b[gen_i][119:56];
			endcase


			if(bmExTypeLength_2b[gen_i]) begin
				(* parallel_case, full_case *)
				case(exOffsetTypeLength_16b[3][(2+7*gen_i):(7*gen_i)])
					3'd7: exField2_typeLength_16b[gen_i] 	<= exField1_typeLength_16b[gen_i][7+8:0];
					3'd6: exField2_typeLength_16b[gen_i] 	<= exField1_typeLength_16b[gen_i][15+8:8];
					3'd5: exField2_typeLength_16b[gen_i] 	<= exField1_typeLength_16b[gen_i][23+8:16];
					3'd4: exField2_typeLength_16b[gen_i] 	<= exField1_typeLength_16b[gen_i][31+8:24];
					3'd3: exField2_typeLength_16b[gen_i] 	<= exField1_typeLength_16b[gen_i][39+8:32];
					3'd2: exField2_typeLength_16b[gen_i] 	<= exField1_typeLength_16b[gen_i][47+8:40];
					3'd1: exField2_typeLength_16b[gen_i] 	<= exField1_typeLength_16b[gen_i][55+8:48];
					3'd0: exField2_typeLength_16b[gen_i] 	<= exField1_typeLength_16b[gen_i][63+8:56];
				endcase
			end
			else begin
				exField2_typeLength_16b[gen_i]				<= 16'b0;
			end
		end
	end	
endgenerate

//*	stage 5: combine all extracted fields
reg [47:0]  exField_48b;			// used to combine 8b & 16b;
reg [191:0]	exField_192b;			// used to combine 32b & 64b;
reg [239:0]	exField_240b;			// used to combine all;
reg	[6:0]	bmLen_7b;				// use dto combine 48b with 192b

always @(posedge clk) begin
	// // stage 5: calculate valid length in 48b;
	bmLen_7b[0]				<= (bmEx_8b[4][3:0] == 4'b0000)? 1'b1 : 1'b0;	// length is 0;
	bmLen_7b[1]				<= (bmEx_8b[4][3:0] == 4'b0001)? 1'b1 : 1'b0;	// length is 8;
	bmLen_7b[2]				<= (bmEx_8b[4][3:0] == 4'b0011 || bmEx_8b[4][3:0] == 4'b0100)? 1'b1 : 1'b0;
	bmLen_7b[3]				<= (bmEx_8b[4][3:0] == 4'b0101)? 1'b1 : 1'b0;
	bmLen_7b[4]				<= (bmEx_8b[4][3:0] == 4'b1100 || bmEx_8b[4][3:0] == 4'b0111)? 1'b1 : 1'b0;
	bmLen_7b[5]				<= (bmEx_8b[4][3:0] == 4'b1101)? 1'b1 : 1'b0;
	bmLen_7b[6]				<= (bmEx_8b[4][3:0] == 4'b1111)? 1'b1 : 1'b0;
	// stage 5: merge 8b and 16b extracted fields, and merge 32b and 64b
	(* parallel_case, full_case *)
	case(bmEx_8b[4][1:0])
		2'b00: exField_48b	<= {exField2_16b[0],exField2_16b[1],16'b0};
		2'b01: exField_48b	<= {exField2_8b[0],exField2_16b[0],exField2_16b[1],8'b0};
		2'b11: exField_48b	<= {exField2_8b[0],exField2_8b[1],exField2_16b[0],exField2_16b[1]};
		2'b10: exField_48b	<= 48'b0;// exception
	endcase
	(* parallel_case, full_case *)
	case(bmEx_8b[4][5:4])
		2'b00: exField_192b	<= {exField2_64b[0],exField2_64b[1],64'b0};
		2'b01: exField_192b	<= {exField2_32b[0],exField2_64b[0],exField2_64b[1],32'b0};
		2'b11: exField_192b	<= {exField2_32b[0],exField2_32b[1],exField2_64b[0],exField2_64b[1]};
		2'b10: exField_192b	<= 192'b0;// exception
	endcase

	// stage 6: merge 48b with 192b
	(* parallel_case *)
	case(1'b1)
		bmLen_7b[0]: exField_240b	<= {exField_192b, 48'b0};
		bmLen_7b[1]: exField_240b	<= {exField_48b[47:40], exField_192b, 40'b0};
		bmLen_7b[2]: exField_240b	<= {exField_48b[47:32], exField_192b, 32'b0};
		bmLen_7b[3]: exField_240b	<= {exField_48b[47:24], exField_192b, 24'b0};
		bmLen_7b[4]: exField_240b	<= {exField_48b[47:16], exField_192b, 16'b0};
		bmLen_7b[5]: exField_240b	<= {exField_48b[47:8],  exField_192b, 8'b0};
		bmLen_7b[6]: exField_240b	<= {exField_48b, exField_192b};
	endcase
end


/** locate procData*/
reg [239:0]		exMask1_240b, exMask0_240b, notExMask1_240b, notExMask0_240b;
reg	[1023:0]	procData1_1024b[9:6],procData2_1024b[9:6];
reg [239:0]		exFieldTemp_240b,exFieldTemp_64b;

//*	stage 3-6: locate procData;
//*	stage 7: del/add/replace header;
always @(posedge clk) begin
	//	stage 3: shift_stage_1, Aligned by 64b;
	(*parallel_case, full_case *)
	case(constrOffset_8b[2][5:3])
		3'd0: procData[3] 	<= procData[2];
		3'd1: procData[3]	<= {procData[2][64*7+511:0], procData[2][1023:64*7+512]};
		3'd2: procData[3]	<= {procData[2][64*6+511:0], procData[2][1023:64*6+512]};
		3'd3: procData[3]	<= {procData[2][64*5+511:0], procData[2][1023:64*5+512]};
		3'd4: procData[3]	<= {procData[2][64*4+511:0], procData[2][1023:64*4+512]};
		3'd5: procData[3]	<= {procData[2][64*3+511:0], procData[2][1023:64*3+512]};
		3'd6: procData[3]	<= {procData[2][64*2+511:0], procData[2][1023:64*2+512]};
		3'd7: procData[3]	<= {procData[2][64*1+511:0], procData[2][1023:64+512]};
	endcase
	//	stage 4: shift_stage_2, Aligned by 16b;
	(*parallel_case, full_case *)
	case(constrOffset_8b[3][2:0])
		3'd0: procData[4] 	<= procData[3];
		3'd1: procData[4]	<= {procData[3][8*7+959:0], procData[3][1023:8*7+960]};
		3'd2: procData[4]	<= {procData[3][8*6+959:0], procData[3][1023:8*6+960]};
		3'd3: procData[4]	<= {procData[3][8*5+959:0], procData[3][1023:8*5+960]};
		3'd4: procData[4]	<= {procData[3][8*4+959:0], procData[3][1023:8*4+960]};
		3'd5: procData[4]	<= {procData[3][8*3+959:0], procData[3][1023:8*3+960]};
		3'd6: procData[4]	<= {procData[3][8*2+959:0], procData[3][1023:8*2+960]};
		3'd7: procData[4]	<= {procData[3][8*1+959:0], procData[3][1023:8*1+960]};
	endcase

	//	stage 3: calculate mask, aligned by 32b
	(*parallel_case, full_case *)
	case(constrLength_8b[2][4:2])
		3'd0: exMask0_240b	<= {240{1'b1}};
		3'd1: exMask0_240b	<= {{32{1'b0}},  {208{1'b1}}};
		3'd2: exMask0_240b	<= {{64{1'b0}},  {176{1'b1}}};
		3'd3: exMask0_240b	<= {{96{1'b0}},  {144{1'b1}}};
		3'd4: exMask0_240b	<= {{128{1'b0}}, {112{1'b1}}};
		3'd5: exMask0_240b	<= {{160{1'b0}}, {80{1'b1}}};
		3'd6: exMask0_240b	<= {{192{1'b0}}, {48{1'b1}}};
		3'd7: exMask0_240b	<= {{224{1'b0}}, {16{1'b1}}};
	endcase
	//	stage 4: calculate mask, aligned by 8b
	(*parallel_case, full_case *)
	case(constrLength_8b[3][1:0])
		3'd0: exMask1_240b	<= exMask0_240b;
		3'd1: exMask1_240b	<= {{8{1'b0}},  exMask0_240b[239:8]};
		3'd2: exMask1_240b	<= {{16{1'b0}}, exMask0_240b[239:16]};
		3'd3: exMask1_240b	<= {{24{1'b0}}, exMask0_240b[239:24]};
	endcase

	//*	stage 5: mask procData;
	if(constrAct_8b[4] == 8'd2)
		procData[5] <= {(procData[4][1023:784]&exMask1_240b),procData[4][784:0]};
	else
		procData[5] <= procData[4];
	notExMask0_240b <= ~exMask1_240b;

	//*	stage 6: procData is devided into two part
	procData1_1024b[6]		<= 1024'b0;
	procData2_1024b[6]		<= 1024'b0;
	(*parallel_case, full_case *)
	case(lenProc_8b[5][6:4])
		3'd0: {procData1_1024b[6][1023:128],procData2_1024b[6][127:0]}	<= procData[5];
		3'd1: {procData1_1024b[6][1023:256],procData2_1024b[6][255:0]}	<= procData[5];
		3'd2: {procData1_1024b[6][1023:384],procData2_1024b[6][383:0]}	<= procData[5];
		3'd3: {procData1_1024b[6][1023:512],procData2_1024b[6][511:0]}	<= procData[5];
		3'd4: {procData1_1024b[6][1023:640],procData2_1024b[6][639:0]}	<= procData[5];
		3'd5: {procData1_1024b[6][1023:768],procData2_1024b[6][767:0]}	<= procData[5];
		3'd6: {procData1_1024b[6][1023:896],procData2_1024b[6][895:0]}	<= procData[5];
		3'd7:  procData2_1024b[6]										<= procData[5];
	endcase
	notExMask1_240b <= notExMask0_240b;

	//*	stage 7: replace header;
	if(constrAct_8b[6] == 8'd2)
		// procData1_1024b[7]	<= {(procData1_1024b[6][1023:784]|(exField_240b)),procData1_1024b[6][783:0]};
		procData1_1024b[7]	<= {(procData1_1024b[6][1023:784]|(exField_240b&notExMask1_240b)),procData1_1024b[6][783:0]};
	else
		procData1_1024b[7]	<= procData1_1024b[6];
	procData2_1024b[7]	<= procData2_1024b[6];
	exFieldTemp_240b <= exField_240b;

	//*	stage 8: left shift part one, aligned by 64b
	(* parallel_case, full_case *)
	case(constrShiftVal_8b[7][5:3])
		3'd0: procData1_1024b[8] 	<=  procData1_1024b[7];
		3'd1: procData1_1024b[8]	<= (constrAct_8b[7][1:0] == 2'd1)? procData1_1024b[7]:{procData1_1024b[7][959:0], 64'b0};
		3'd2: procData1_1024b[8]	<= (constrAct_8b[7][1:0] == 2'd1)? procData1_1024b[7]:{procData1_1024b[7][895:0], 128'b0};
		3'd3: procData1_1024b[8]	<= (constrAct_8b[7][1:0] == 2'd1)? procData1_1024b[7]:{procData1_1024b[7][831:0], 192'b0};
		3'd4: procData1_1024b[8]	<= (constrAct_8b[7][1:0] == 2'd1)? procData1_1024b[7]:{procData1_1024b[7][767:0], 256'b0};
		3'd5: procData1_1024b[8]	<= (constrAct_8b[7][1:0] == 2'd1)? procData1_1024b[7]:{procData1_1024b[7][703:0], 320'b0};
		3'd6: procData1_1024b[8]	<= (constrAct_8b[7][1:0] == 2'd1)? procData1_1024b[7]:{procData1_1024b[7][639:0], 384'b0};
		3'd7: procData1_1024b[8]	<= (constrAct_8b[7][1:0] == 2'd1)? procData1_1024b[7]:{procData1_1024b[7][575:0], 448'b0};
	endcase
	//*	left shift part two, aligned by 64b
	(* parallel_case, full_case *)
	case(constrShiftVal_8b[7][5:3])
		3'd0: procData2_1024b[8] 	<=  procData2_1024b[7];
		3'd1: procData2_1024b[8]	<= (constrAct_8b[7][1:0] == 2'd0)? procData2_1024b[7]: (constrAct_8b[7][1:0] == 2'd1)?
											{procData2_1024b[7][959:0], exFieldTemp_240b[239:176]}: 
											{procData2_1024b[7][959:0], procData1_1024b[7][1023:960]};
		3'd2: procData2_1024b[8]	<= (constrAct_8b[7][1:0] == 2'd0)? procData2_1024b[7]: (constrAct_8b[7][1:0] == 2'd1)?
											{procData2_1024b[7][895:0], exFieldTemp_240b[239:112]}: 
											{procData2_1024b[7][895:0], procData1_1024b[7][1023:896]};
		3'd3: procData2_1024b[8]	<= (constrAct_8b[7][1:0] == 2'd0)? procData2_1024b[7]: (constrAct_8b[7][1:0] == 2'd1)?
											{procData2_1024b[7][831:0], exFieldTemp_240b[239:48]}: 
											{procData2_1024b[7][831:0], procData1_1024b[7][1023:832]};
		3'd4: procData2_1024b[8]	<= (constrAct_8b[7][1:0] == 2'd0)? procData2_1024b[7]: 
											{procData2_1024b[7][767:0], procData1_1024b[7][1023:768]};
		3'd5: procData2_1024b[8]	<= (constrAct_8b[7][1:0] == 2'd0)? procData2_1024b[7]: 
											{procData2_1024b[7][703:0], procData1_1024b[7][1023:704]};
		3'd6: procData2_1024b[8]	<= (constrAct_8b[7][1:0] == 2'd0)? procData2_1024b[7]: 
											{procData2_1024b[7][639:0], procData1_1024b[7][1023:640]};
		3'd7: procData2_1024b[8]	<= (constrAct_8b[7][1:0] == 2'd0)? procData2_1024b[7]: 
											{procData2_1024b[7][575:0], procData1_1024b[7][1023:576]};
	endcase
	(* parallel_case, full_case *)
	case(constrShiftVal_8b[7][4:3])
		2'd0: exFieldTemp_64b		<= exFieldTemp_240b[239:196];
		2'd1: exFieldTemp_64b		<= exFieldTemp_240b[175:112];
		2'd2: exFieldTemp_64b		<= exFieldTemp_240b[111:48];
		2'd3: exFieldTemp_64b		<= {exFieldTemp_240b[47:0], 16'b0};
	endcase
	

	//*	stage8:	shift, aligned by 8b
	(* parallel_case, full_case *)
	case(constrShiftVal_8b[8][2:0])
		3'd0: procData1_1024b[9] 	<=  procData1_1024b[8];
		3'd1: procData1_1024b[9]	<= (constrAct_8b[8][1:0] == 2'd1)? procData1_1024b[8]:{procData1_1024b[8][1015:0],8'b0};
		3'd2: procData1_1024b[9]	<= (constrAct_8b[8][1:0] == 2'd1)? procData1_1024b[8]:{procData1_1024b[8][1007:0],16'b0};
		3'd3: procData1_1024b[9]	<= (constrAct_8b[8][1:0] == 2'd1)? procData1_1024b[8]:{procData1_1024b[8][999:0], 24'b0};
		3'd4: procData1_1024b[9]	<= (constrAct_8b[8][1:0] == 2'd1)? procData1_1024b[8]:{procData1_1024b[8][991:0], 32'b0};
		3'd5: procData1_1024b[9]	<= (constrAct_8b[8][1:0] == 2'd1)? procData1_1024b[8]:{procData1_1024b[8][983:0], 40'b0};
		3'd6: procData1_1024b[9]	<= (constrAct_8b[8][1:0] == 2'd1)? procData1_1024b[8]:{procData1_1024b[8][975:0], 48'b0};
		3'd7: procData1_1024b[9]	<= (constrAct_8b[8][1:0] == 2'd1)? procData1_1024b[8]:{procData1_1024b[8][967:0], 56'b0};
	endcase

	(* parallel_case, full_case *)
	case(constrShiftVal_8b[7][2:0])
		3'd0: procData2_1024b[9] 	<=  procData2_1024b[8];
		3'd1: procData2_1024b[9]	<= (constrAct_8b[8][1:0] == 2'd0)? procData2_1024b[8]: (constrAct_8b[8][1:0] == 2'd1)?
											{procData2_1024b[8][1015:0], exFieldTemp_64b[63:56]}: 
											{procData2_1024b[8][1015:0], procData1_1024b[8][1023:1016]};
		3'd2: procData2_1024b[9]	<= (constrAct_8b[8][1:0] == 2'd0)? procData2_1024b[8]: (constrAct_8b[8][1:0] == 2'd1)?
											{procData2_1024b[8][1007:0], exFieldTemp_64b[55:48]}: 
											{procData2_1024b[8][1007:0], procData1_1024b[8][1023:1008]};
		3'd3: procData2_1024b[9]	<= (constrAct_8b[8][1:0] == 2'd0)? procData2_1024b[8]: (constrAct_8b[8][1:0] == 2'd1)?
											{procData2_1024b[8][999:0], exFieldTemp_64b[47:40]}:
											{procData2_1024b[8][999:0], procData1_1024b[8][1023:1000]};
		3'd4: procData2_1024b[9]	<= (constrAct_8b[8][1:0] == 2'd0)? procData2_1024b[8]: (constrAct_8b[8][1:0] == 2'd1)?
											{procData2_1024b[8][991:0], exFieldTemp_64b[47:32]}: 
											{procData2_1024b[8][991:0], procData1_1024b[8][1023:992]};
		3'd5: procData2_1024b[9]	<= (constrAct_8b[8][1:0] == 2'd0)? procData2_1024b[8]: (constrAct_8b[8][1:0] == 2'd1)?
											{procData2_1024b[8][983:0], exFieldTemp_64b[47:24]}: 
											{procData2_1024b[8][983:0], procData1_1024b[8][1023:984]};
		3'd6: procData2_1024b[9]	<= (constrAct_8b[8][1:0] == 2'd0)? procData2_1024b[8]: (constrAct_8b[8][1:0] == 2'd1)?
											{procData2_1024b[8][975:0], exFieldTemp_64b[47:16]}: 
											{procData2_1024b[8][975:0], procData1_1024b[8][1023:976]};
		3'd7: procData2_1024b[9]	<= (constrAct_8b[8][1:0] == 2'd0)? procData2_1024b[8]: (constrAct_8b[8][1:0] == 2'd1)?
											{procData2_1024b[8][967:0], exFieldTemp_64b[47:8]}: 
											{procData2_1024b[8][967:0], procData1_1024b[8][1023:968]};
	endcase
end

/**format of rule
	1)	8b		current type;
	2)	8b		type info, extract 2B
		->	1b	valid bit: means extract or not;
		->	7b	offset for extractor: means where to extract;(range from 0 to 1kb)
	3)	32b		(length info)
		->	1b	0 is fixed length; 1 is should be calculated;
		->	7b	reserved,
		->	16b	mask;
		->	1b	reserved,
		->	8b	fixed length or 2b shift value? 
	4)	8b*8	(extract info, two 1B, two 2B, two 4B, two 8B)
		->	1b	valid bit: means extract or not;
		->	7b	offset for extractor: means where to extract;(range from 0 to 1kb)
	5)	32b
		->	1b	valid bit: (whether to assign extracted fields to procData)
		->	7b	offset for extracted fields
		->	8b	length for extracted fields
		->	8b 	act:
		->	8b 	shift value for recombining PHV:
**/
reg [7:0]	validRule;	// valid of rule;
reg [15:0]	ruleKey[num_rule-1:0];
reg [15:0]	ruleMask[num_rule-1:0];
reg [143:0]	ruleAction_144b[num_rule-1:0];
reg [7:0]	bmHitRule;
reg [143:0]	ruleActionHit_144b[9:6];
reg [7:0]	lenCalc_8b;

/** lookup type , calc length, and recombine extracted fields */
always @(posedge clk) begin

	/** lookup type */
	//*	stage 5: lookup rule;
	for(i=0; i<num_rule; i=i+1) begin
		if((validRule[i] == 1'b1) && ((exField2_typeLength_16b[0]&ruleMask[i]) == ruleKey[i]))
			bmHitRule[i] <= 1'b1;
		else
			bmHitRule[i] <= 1'b0;
	end

	//	stage 6: get action;
	(* parallel_case *)
	casez(bmHitRule)
		8'b1???????: ruleActionHit_144b[6]	<=	ruleAction_144b[7];
		8'b01??????: ruleActionHit_144b[6]	<=	ruleAction_144b[6];
		8'b001?????: ruleActionHit_144b[6]	<=	ruleAction_144b[5];
		8'b0001????: ruleActionHit_144b[6]	<=	ruleAction_144b[4];
		8'b00001???: ruleActionHit_144b[6]	<=	ruleAction_144b[3];
		8'b000001??: ruleActionHit_144b[6]	<=	ruleAction_144b[2];
		8'b0000001?: ruleActionHit_144b[6]	<=	ruleAction_144b[1];
		8'b00000001: ruleActionHit_144b[6]	<=	ruleAction_144b[0];
		8'b00000000: ruleActionHit_144b[6]	<=	144'b0;
	endcase

	//	stage 5: calc length;
	lenCalc_8b <= exField2_typeLength_16b[1][7:0]&lenMask_16b[4][7:0];

	//	stage 6: get previous length;
	if(bmExTypeLength_2b[5][1] == 1'b0)	begin 
		//*	fixed length
		lenPars_8b[6] <= fixLen_or_shiftVal_8b[5] + lenPars_8b[5];
	end
	else begin
		(* parallel_case, full_case *)
		case(fixLen_or_shiftVal_8b[5][1:0])
			2'd0:	lenPars_8b[6] <= lenCalc_8b + lenPars_8b[5];
			2'd1:	lenPars_8b[6] <= {lenCalc_8b[6:0],1'b0} + lenPars_8b[5];
			2'd2:	lenPars_8b[6] <= {lenCalc_8b[5:0],2'b0} + lenPars_8b[5];
			2'd3:	lenPars_8b[6] <= {lenCalc_8b[4:0],3'b0} + lenPars_8b[5];
		endcase
	end

	{ruleActionHit_144b[9],ruleActionHit_144b[8],ruleActionHit_144b[7]} <= {ruleActionHit_144b[8],ruleActionHit_144b[7],ruleActionHit_144b[6]};
end
//	

//*	stage 10: recomebine */
always @(posedge clk or negedge reset) begin
	if(!reset) begin
		phv_out_valid 		<= 1'b0;
		phv_out				<= 0;
	end
	else begin
		phv_out_valid		<= valid_temp[9];
		phv_out				<= {lenPars_8b[9], lenProc_8b[9], ruleActionHit_144b[9], parsData[9], 
									procData1_1024b[9]|procData2_1024b[9]};
	end
end

/**	configue rule*/
always @(posedge clk or negedge reset) begin
	if (!reset) begin
		// reset
		validRule <= 8'b0;
		rdata_rule_valid <= 1'b0;
		rdata_rule <= 177'b0;
	end
	else begin
		if(wren_rule == 1'b1) begin
			for(i=0; i<num_rule; i=i+1) begin
				if(addr_rule == i)
					{validRule[i],ruleKey[i],ruleMask[i],ruleAction_144b[i]} <= data_rule;
			end
		end
		
		if(rden_rule == 1'b1) begin
			(* full_case, parallel_case*)
			case(addr_rule)
				3'd0: rdata_rule <= {validRule[0],ruleKey[0],ruleMask[0],ruleAction_144b[0]};
				3'd1: rdata_rule <= {validRule[1],ruleKey[1],ruleMask[1],ruleAction_144b[1]};
				3'd2: rdata_rule <= {validRule[2],ruleKey[2],ruleMask[2],ruleAction_144b[2]};
				3'd3: rdata_rule <= {validRule[3],ruleKey[3],ruleMask[3],ruleAction_144b[3]};
				3'd4: rdata_rule <= {validRule[4],ruleKey[4],ruleMask[4],ruleAction_144b[4]};
				3'd5: rdata_rule <= {validRule[5],ruleKey[5],ruleMask[5],ruleAction_144b[5]};
				3'd6: rdata_rule <= {validRule[6],ruleKey[6],ruleMask[6],ruleAction_144b[6]};
				3'd7: rdata_rule <= {validRule[7],ruleKey[7],ruleMask[7],ruleAction_144b[7]};
			endcase
		end
		rdata_rule_valid <= rden_rule;
	end
end


endmodule