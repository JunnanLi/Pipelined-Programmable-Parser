/****************************************************/
//	Module name: The top module of programmable parser
//	Authority @ lijunnan (lijunnan@nudt.edu.cn)
//	Last edited time: 2023/12/22
//	Function outline: 2-stage programmable parser
/****************************************************/

module parser_um #(
	parameter    PLATFORM = "Xilinx"
)(
	input clk,
	input rst_n,

	//cpu or port
	input  pktin_data_wr,
	input  [133:0] pktin_data,
	input  pktin_data_valid,
	input  pktin_data_valid_wr,
	output reg pktin_ready,	//pktin_ready = um2port_alf
		
	output reg pktout_data_wr,
	output reg [133:0] pktout_data,
	output reg pktout_data_valid,
	output reg pktout_data_valid_wr,
	input pktout_ready	//pktout_ready = port2um_alf    
);

/*********************************************************/
reg				metadata_in_valid;
reg	[2207:0]	metadata_in;
wire			metadata_out_valid, metadata_valid_temp[1:0];
wire[2207:0]	metadata_out, metadata_temp[1:0];

reg 			wren_rule[2:0];
reg				rden_rule[2:0];
reg	[2:0]		addr_rule;
reg [176:0]		data_rule;
wire			rdata_rule_valid[2:0];
wire[176:0]		rdata_rule[2:0];

parser_deparser parserDeparser_stage1(
	.clk(clk),
	.reset(rst_n),

	.wren_rule(wren_rule[0]),
	.rden_rule(rden_rule[0]),
	.data_rule(data_rule),
	.addr_rule(addr_rule),
	.rdata_rule_valid(rdata_rule_valid[0]),
	.rdata_rule(rdata_rule[0]),

	.phv_in_valid(metadata_in_valid),
	.phv_in(metadata_in),
	.phv_out_valid(metadata_valid_temp[0]),
	.phv_out(metadata_temp[0])
);

parser_deparser parserDeparser_stage2(
	.clk(clk),
	.reset(rst_n),

	.wren_rule(wren_rule[1]),
	.rden_rule(rden_rule[1]),
	.data_rule(data_rule),
	.addr_rule(addr_rule),
	.rdata_rule_valid(rdata_rule_valid[1]),
	.rdata_rule(rdata_rule[1]),

	.phv_in_valid(metadata_valid_temp[0]),
	.phv_in(metadata_temp[0]),
	.phv_out_valid(metadata_valid_temp[1]),
	.phv_out(metadata_temp[1])
);

parser_deparser parserDeparser_stage3(
	.clk(clk),
	.reset(rst_n),

	.wren_rule(wren_rule[2]),
	.rden_rule(rden_rule[2]),
	.data_rule(data_rule),
	.addr_rule(addr_rule),
	.rdata_rule_valid(rdata_rule_valid[2]),
	.rdata_rule(rdata_rule[2]),

	.phv_in_valid(metadata_valid_temp[1]),
	.phv_in(metadata_temp[1]),
	.phv_out_valid(metadata_out_valid),
	.phv_out(metadata_out)
);

/****/
reg		[3:0]	state_ingress,state_egress;
/** for fifo */
reg 			rdreq_meta;
wire	[1023:0]q_meta;
wire			empty_meta;

parameter		IDLE_S			= 4'd0,
				READ_META_S		= 4'd1,
				READ_wconf_0_S	= 4'd6,
				READ_wconf_1_S	= 4'd7,
				READ_VALID_S	= 4'd1,
				WAIT_END_S		= 4'd2;

reg	[7:0]		meta_in_count;
reg				rd_wr_tag; 	// 1 is rd;
reg	[159:0]		initialTypeInfo;
reg [1:0]		num_stage;
integer	i;
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		metadata_in_valid	<= 1'b0;
		metadata_in			<= 2208'b0;
		for(i=0; i<3; i=i+1) begin
			rden_rule[i]		<= 1'b0;
			wren_rule[i]		<= 1'b0;
		end
		data_rule		<= 177'b0;
		addr_rule			<= 3'b0;
		meta_in_count		<= 8'b0;
		rd_wr_tag			<= 1'b0;
		initialTypeInfo		<= 160'b0;
		state_ingress		<= 4'b0;
	end
	else begin
		case(state_ingress)
			IDLE_S: begin
				metadata_in_valid				<= 1'b0;
				{rden_rule[0],rden_rule[1],rden_rule[2]}		<= 3'b0;
				{wren_rule[0],wren_rule[1],wren_rule[2]}		<= 3'b0;
				meta_in_count					<= 8'b0;
				if(pktin_data_wr == 1'b1 && pktin_data[0] == 0) begin
					state_ingress <= READ_META_S;
				end
				else if(pktin_data_wr == 1'b1 && pktin_data[0] == 1) begin
					state_ingress	<= READ_wconf_0_S;
					rd_wr_tag		<= pktin_data[8];
					addr_rule		<= pktin_data[18:16];
					num_stage		<= pktin_data[25:24];
				end
				else begin
					state_ingress <= IDLE_S;
				end
			end
			READ_META_S: begin
				(* full_case *)
				case(meta_in_count[2:0])
					3'd7:	metadata_in[127+1024:1024]		<= pktin_data[127:0];
					3'd6:	metadata_in[255+1024:128+1024]	<= pktin_data[127:0];
					3'd5:	metadata_in[383+1024:256+1024]	<= pktin_data[127:0];
					3'd4:	metadata_in[512+1024:384+1024]	<= pktin_data[127:0];
					3'd3:	metadata_in[639+1024:511+1024]	<= pktin_data[127:0];
					3'd2:	metadata_in[767+1024:640+1024]	<= pktin_data[127:0];
					3'd1:	metadata_in[895+1024:768+1024]	<= pktin_data[127:0];
					3'd0:	metadata_in[1023+1024:896+1024]	<= pktin_data[127:0];
				endcase
				meta_in_count			<= 8'd1 + meta_in_count;
				if(meta_in_count == 8'd7) begin
					metadata_in_valid	<= 1'b1;
					metadata_in[2048+159:2048] 	<= initialTypeInfo;
					state_ingress		<= IDLE_S;
				end
			end
			READ_wconf_0_S: begin
				data_rule[176:128]		<= pktin_data[48:0];
				state_ingress			<= READ_wconf_1_S;
			end
			READ_wconf_1_S: begin
				(* parallel_case, full_case *)
				case(num_stage)
					2'd0: begin
						initialTypeInfo	<= {data_rule[176:128],pktin_data[127:0]};
					end
					2'd1: begin 
						data_rule[127:0]	<= pktin_data[127:0];
						wren_rule[0]		<= 1'b1;
					end
					2'd2: begin
						data_rule[127:0]	<= pktin_data[127:0];
						wren_rule[1]		<= 1'b1;
					end
					2'd3: begin	
						data_rule[127:0]	<= pktin_data[127:0];
						wren_rule[2]		<= 1'b1;
					end
				endcase
				state_ingress		<= IDLE_S;
			end
			default: begin
				state_ingress		<= IDLE_S;
			end
		endcase
	end
end

reg [9:0]		count;
reg [1023:0]	meta_temp;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		pktout_data_valid_wr <= 1'b0;
		pktout_data_valid <= 1'b0;
		pktout_data_wr <= 1'b0;
		pktout_data <= 134'b0;
		state_egress <= IDLE_S;
		rdreq_meta <= 1'b0;
		count <= 10'd0;
		meta_temp <= 1024'b0;
	end
	else begin
		case(state_egress)
			IDLE_S: begin
				pktout_data_valid_wr <= 1'b0;
				pktout_data_wr <= 1'b0;
				if((pktout_ready == 1'b1) && (empty_meta == 1'b0)) begin
					rdreq_meta <= 1'b1;
					state_egress <= READ_VALID_S;
					count <= 10'd0;
				end
			end
			READ_VALID_S: begin
				rdreq_meta			<= 1'b0;
				meta_temp			<= q_meta;
				pktout_data_wr		<= 1'b1;
				pktout_data 		<= 134'b0;
				state_egress		<= WAIT_END_S;
			end
			WAIT_END_S: begin
				count					<= 10'd1 + count;
				pktout_data_wr			<= 1'b1;
				(* full_case *)
				case(count[2:0])
					3'd0:	pktout_data	<= meta_temp[127:0];
					3'd1:	pktout_data	<= meta_temp[255:128];
					3'd2:	pktout_data	<= meta_temp[383:256];
					3'd3:	pktout_data	<= meta_temp[512:384];
					3'd4:	pktout_data	<= meta_temp[639:511];
					3'd5:	pktout_data	<= meta_temp[767:640];
					3'd6:	pktout_data	<= meta_temp[895:768];
					3'd7:	pktout_data	<= meta_temp[1023:896];
				endcase
				if(count == 10'd7) begin
					pktout_data_valid_wr<= 1'b1;
					state_egress		<= IDLE_S;
				end
			end
			default: begin
				state_egress <= IDLE_S;
			end
		endcase
	end
end

always @(posedge clk) begin
	pktin_ready <= pktout_ready;
end


fifo_1024_256 meta_buffer(
.clk(clk),
.srst(!rst_n),
.din(metadata_out[1023:0]),
.wr_en(metadata_out_valid),
.rd_en(rdreq_meta),
.dout(q_meta),
.full(),
.empty(empty_meta)
);

	
endmodule    