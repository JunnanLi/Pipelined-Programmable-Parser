/****************************************************/
//	Module name: test_bench
//	Authority @ lijunnan (lijunnan@nudt.edu.cn)
//	Last edited time: 2020/03/19
//	Function outline: testbench
/****************************************************/


`timescale 1ns/1ps


module parser_test_pp();


	reg clk = 1;
	reg resetn = 0;
	
	/** clk */
	always #1 clk = ~clk;
	/** reset */
	initial begin
		repeat (20) @(posedge clk);
		resetn <= 1;
	end

	reg			pktin_data_wr, pktin_data_valid, pktin_data_valid_wr;
	reg [133:0]	pktin_data;
	wire 		pktout_data_valid_wr, pktout_data_valid, pktout_data_wr;
	wire[133:0]	pktout_data;
	wire		pktin_ready;

parser_um UM(
	.clk(clk),
	.rst_n(resetn),

	//cpu or port
	.pktin_data_wr(pktin_data_wr),
	.pktin_data(pktin_data),
	.pktin_data_valid(pktin_data_valid),
	.pktin_data_valid_wr(pktin_data_valid_wr),
	.pktin_ready(pktin_ready),//pktin_ready = um2port_alf
		
	.pktout_data_wr(pktout_data_wr),
	.pktout_data(pktout_data),
	.pktout_data_valid(pktout_data_valid),
	.pktout_data_valid_wr(pktout_data_valid_wr),
	.pktout_ready(1'b1)	//pktout_ready = port2um_alf      
);

/*
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
*/

integer i;
reg [7:0]	count;
initial begin
	pktin_data_valid_wr = 1'b0;
	pktin_data_valid	= 1'b0;
	pktin_data_wr		= 1'b0;
	pktin_data			= 134'b0;
	
	/**configure rule*/
	// add other: {41'b0,ex_offset[0],ex_offset[1],ex_offset[2],ex_offset[3],
	//				ex_offset[4],ex_offset[5],ex_offset[6],ex_offset[7],
	//				pad5,wb_offset,act_mask};
	
	#101 begin	// metadata_0;
		pktin_data_wr = 1'b1;
		pktin_data = {2'b01,4'b0, 96'b0, 8'd0,8'd0,			// num_stage, num_rule;
						8'b0,								// wr;
						8'b1};								// conf;
	end
	#2 begin	// pkt_header_0;
		pktin_data = {2'b11,4'b0, 72'b0, 8'd1, 16'b0, 16'b0,// valid,
						8'd1, 1'b1, 7'd12};
	end	
	#2 begin
		pktin_data = {2'b11, 4'b0, 24'b0, 8'd14,	// type filed and length;
						8'b0, 8'b0, 8'b0, 8'b0, 
						1'b1, 7'b0,	8'b0, 1'b1, 7'd4, 8'b0,	// 32b + 64b;
						8'd4, 8'd12,8'd2, 8'd14};			// act_mask;}
		pktin_data_valid_wr = 1'b1;
	end
	#2 begin
		pktin_data_wr = 1'b0;
		pktin_data_valid_wr = 1'b0;
	end

	// add stage1: 
	#50 begin	// metadata_0;
		pktin_data_wr = 1'b1;
		pktin_data = {2'b01,4'b0, 96'b0, 8'd1,8'd1,			// num_stage, num_rule;
						8'b0,								// wr;
						8'b1};								// conf;
	end
	#2 begin	// pkt_header_0;
		pktin_data = {2'b11,4'b0, 72'b0, 8'd1, 16'h0800, 16'hffff,// valid,
						8'd2, 8'b0};
	end	
	#2 begin
		pktin_data = {2'b11, 4'b0, 128'b0};			
		pktin_data_valid_wr = 1'b1;
	end
	#2 begin
		pktin_data_wr = 1'b0;
		pktin_data_valid_wr = 1'b0;
	end
		
	/**input packet_1: hit*/
	#50 begin	// metadata_0;
		pktin_data_wr = 1'b1;
		pktin_data = {2'b01,4'b0,128'b0};
	end	
	#2	pktin_data = {2'b11,4'b0,128'h1111_1111_1111_2222_2222_2222_0800_4500};
	#2	pktin_data = {2'b11,4'b0,128'd0};
	#2	pktin_data = {2'b11,4'b0,128'd0};
	#2	pktin_data = {2'b11,4'b0,128'd0};
	#2	pktin_data = {2'b11,4'b0,128'd0};
	#2	pktin_data = {2'b11,4'b0,128'd0};
	#2	pktin_data = {2'b11,4'b0,128'd0};
	#2 begin
		pktin_data_valid_wr = 1'b1;
		pktin_data = {2'b11,4'b0,128'h2233};
	end
	#2 begin
		pktin_data_wr = 1'b0;
		pktin_data_valid_wr = 1'b0;
	end
	
	/**input packet_2: mis*/
	#50 begin	// metadata_0;
		pktin_data_wr = 1'b1;
		pktin_data = {2'b01,4'b0,128'b0};
	end	
	#2	pktin_data = {2'b11,4'b0,128'd1};
	#2	pktin_data = {2'b11,4'b0,128'd2};
	#2	pktin_data = {2'b11,4'b0,128'd3};
	#2	pktin_data = {2'b11,4'b0,128'd4};
	#2	pktin_data = {2'b11,4'b0,128'd5};
	#2	pktin_data = {2'b11,4'b0,128'd6};
	#2	pktin_data = {2'b11,4'b0,128'd7};
	#2 begin
		pktin_data_valid_wr = 1'b1;
		pktin_data = {2'b11,4'b0,128'b0};
	end
	#2 begin
		pktin_data_wr = 1'b0;
		pktin_data_valid_wr = 1'b0;
	end
	
	
end

endmodule