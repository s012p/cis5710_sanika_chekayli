module MyClockGen (
	input_clk_25MHz,
	clk_proc,
	locked
);
	input input_clk_25MHz;
	output wire clk_proc;
	output wire locked;
	wire clkfb;
	(* FREQUENCY_PIN_CLKI = "25" *) (* FREQUENCY_PIN_CLKOP = "20" *) (* ICP_CURRENT = "12" *) (* LPF_RESISTOR = "8" *) (* MFG_ENABLE_FILTEROPAMP = "1" *) (* MFG_GMCREF_SEL = "2" *) EHXPLLL #(
		.PLLRST_ENA("DISABLED"),
		.INTFB_WAKE("DISABLED"),
		.STDBY_ENABLE("DISABLED"),
		.DPHASE_SOURCE("DISABLED"),
		.OUTDIVIDER_MUXA("DIVA"),
		.OUTDIVIDER_MUXB("DIVB"),
		.OUTDIVIDER_MUXC("DIVC"),
		.OUTDIVIDER_MUXD("DIVD"),
		.CLKI_DIV(5),
		.CLKOP_ENABLE("ENABLED"),
		.CLKOP_DIV(30),
		.CLKOP_CPHASE(15),
		.CLKOP_FPHASE(0),
		.FEEDBK_PATH("INT_OP"),
		.CLKFB_DIV(4)
	) pll_i(
		.RST(1'b0),
		.STDBY(1'b0),
		.CLKI(input_clk_25MHz),
		.CLKOP(clk_proc),
		.CLKFB(clkfb),
		.CLKINTFB(clkfb),
		.PHASESEL0(1'b0),
		.PHASESEL1(1'b0),
		.PHASEDIR(1'b1),
		.PHASESTEP(1'b1),
		.PHASELOADREG(1'b1),
		.PLLWAKESYNC(1'b0),
		.ENCLKOP(1'b0),
		.LOCK(locked)
	);
endmodule
module Disasm (
	insn,
	disasm
);
	parameter signed [7:0] PREFIX = "D";
	input wire [31:0] insn;
	output wire [255:0] disasm;
endmodule
module RegFile (
	rd,
	rd_data,
	rs1,
	rs1_data,
	rs2,
	rs2_data,
	clk,
	we,
	rst
);
	reg _sv2v_0;
	input wire [4:0] rd;
	input wire [31:0] rd_data;
	input wire [4:0] rs1;
	output reg [31:0] rs1_data;
	input wire [4:0] rs2;
	output reg [31:0] rs2_data;
	input wire clk;
	input wire we;
	input wire rst;
	localparam signed [31:0] NumRegs = 32;
	reg [31:0] regs [0:31];
	integer idx;
	always @(posedge clk)
		if (rst)
			for (idx = 0; idx < NumRegs; idx = idx + 1)
				regs[idx] <= 1'sb0;
		else begin
			if (we && (rd != 5'd0))
				regs[rd] <= rd_data;
			regs[0] <= 1'sb0;
		end
	always @(*) begin
		if (_sv2v_0)
			;
		if (rs1 == 5'd0)
			rs1_data = 32'd0;
		else if ((we && (rd != 5'd0)) && (rd == rs1))
			rs1_data = rd_data;
		else
			rs1_data = regs[rs1];
		if (rs2 == 5'd0)
			rs2_data = 32'd0;
		else if ((we && (rd != 5'd0)) && (rd == rs2))
			rs2_data = rd_data;
		else
			rs2_data = regs[rs2];
	end
	initial _sv2v_0 = 0;
endmodule
module DatapathPipelined (
	clk,
	rst,
	pc_to_imem,
	insn_from_imem,
	addr_to_dmem,
	load_data_from_dmem,
	store_data_to_dmem,
	store_we_to_dmem,
	halt,
	trace_completed_pc,
	trace_completed_insn,
	trace_completed_cycle_status
);
	reg _sv2v_0;
	input wire clk;
	input wire rst;
	output wire [31:0] pc_to_imem;
	input wire [31:0] insn_from_imem;
	output wire [31:0] addr_to_dmem;
	input wire [31:0] load_data_from_dmem;
	output wire [31:0] store_data_to_dmem;
	output wire [3:0] store_we_to_dmem;
	output reg halt;
	output wire [31:0] trace_completed_pc;
	output wire [31:0] trace_completed_insn;
	output wire [31:0] trace_completed_cycle_status;
	localparam [6:0] OpcodeBranch = 7'b1100011;
	localparam [6:0] OpcodeJalr = 7'b1100111;
	localparam [6:0] OpcodeJal = 7'b1101111;
	localparam [6:0] OpcodeRegImm = 7'b0010011;
	localparam [6:0] OpcodeRegReg = 7'b0110011;
	localparam [6:0] OpcodeEnviron = 7'b1110011;
	localparam [6:0] OpcodeAuipc = 7'b0010111;
	localparam [6:0] OpcodeLui = 7'b0110111;
	reg [31:0] cycles_current;
	always @(posedge clk)
		if (rst)
			cycles_current <= 0;
		else
			cycles_current <= cycles_current + 1;
	reg [31:0] f_pc_current;
	wire [31:0] f_insn;
	reg [31:0] f_cycle_status;
	assign pc_to_imem = f_pc_current;
	assign f_insn = insn_from_imem;
	wire [255:0] f_disasm;
	Disasm #(.PREFIX("F")) disasm_0fetch(
		.insn(f_insn),
		.disasm(f_disasm)
	);
	reg [95:0] decode_state;
	wire [255:0] d_disasm;
	Disasm #(.PREFIX("D")) disasm_1decode(
		.insn(decode_state[63-:32]),
		.disasm(d_disasm)
	);
	localparam [3:0] ALU_ADD = 4'd0;
	localparam [3:0] ALU_SUB = 4'd1;
	localparam [3:0] ALU_AND = 4'd2;
	localparam [3:0] ALU_OR = 4'd3;
	localparam [3:0] ALU_XOR = 4'd4;
	localparam [3:0] ALU_SLT = 4'd5;
	localparam [3:0] ALU_SLTU = 4'd6;
	localparam [3:0] ALU_SLL = 4'd7;
	localparam [3:0] ALU_SRL = 4'd8;
	localparam [3:0] ALU_SRA = 4'd9;
	localparam [3:0] ALU_COPY_B = 4'd10;
	localparam [3:0] ALU_ADD_PC_IMM = 4'd11;
	reg [209:0] x_state;
	reg [134:0] m_state;
	reg [134:0] w_state;
	wire [255:0] x_disasm;
	Disasm #(.PREFIX("X")) disasm_2execute(
		.insn(x_state[177-:32]),
		.disasm(x_disasm)
	);
	wire [255:0] m_disasm;
	Disasm #(.PREFIX("M")) disasm_3memory(
		.insn(m_state[102-:32]),
		.disasm(m_disasm)
	);
	wire [255:0] w_disasm;
	Disasm #(.PREFIX("W")) disasm_4writeback(
		.insn(w_state[102-:32]),
		.disasm(w_disasm)
	);
	wire [6:0] d_opcode;
	wire [4:0] d_rs1;
	wire [4:0] d_rs2;
	wire [4:0] d_rd;
	wire [2:0] d_funct3;
	wire [6:0] d_funct7;
	wire [31:0] d_imm_i;
	wire [31:0] d_imm_u;
	wire [31:0] d_imm_b;
	wire [31:0] d_imm_j;
	assign d_opcode = decode_state[38:32];
	assign d_rd = decode_state[43:39];
	assign d_funct3 = decode_state[46:44];
	assign d_rs1 = decode_state[51:47];
	assign d_rs2 = decode_state[56:52];
	assign d_funct7 = decode_state[63:57];
	assign d_imm_i = {{20 {decode_state[63]}}, decode_state[63:52]};
	assign d_imm_u = {decode_state[63:44], 12'b000000000000};
	assign d_imm_b = {{19 {decode_state[63]}}, decode_state[63], decode_state[39], decode_state[62:57], decode_state[43:40], 1'b0};
	assign d_imm_j = {{11 {decode_state[63]}}, decode_state[63], decode_state[51:44], decode_state[52], decode_state[62:53], 1'b0};
	wire d_is_lui;
	wire d_is_auipc;
	wire d_is_regimm;
	wire d_is_regreg;
	wire d_is_branch;
	wire d_is_jal;
	wire d_is_jalr;
	wire d_is_env;
	assign d_is_lui = d_opcode == OpcodeLui;
	assign d_is_auipc = d_opcode == OpcodeAuipc;
	assign d_is_regimm = d_opcode == OpcodeRegImm;
	assign d_is_regreg = d_opcode == OpcodeRegReg;
	assign d_is_branch = d_opcode == OpcodeBranch;
	assign d_is_jal = d_opcode == OpcodeJal;
	assign d_is_jalr = d_opcode == OpcodeJalr;
	assign d_is_env = d_opcode == OpcodeEnviron;
	wire [31:0] rf_rs1_data;
	wire [31:0] rf_rs2_data;
	RegFile rf(
		.rd(w_state[38-:5]),
		.rd_data(w_state[31-:32]),
		.rs1(d_rs1),
		.rs1_data(rf_rs1_data),
		.rs2(d_rs2),
		.rs2_data(rf_rs2_data),
		.clk(clk),
		.we(w_state[33]),
		.rst(rst)
	);
	reg [31:0] d_rs1_bypassed;
	reg [31:0] d_rs2_bypassed;
	reg [31:0] x_result;
	always @(*) begin
		if (_sv2v_0)
			;
		d_rs1_bypassed = rf_rs1_data;
		d_rs2_bypassed = rf_rs2_data;
		if ((x_state[108] && (x_state[113-:5] != 5'd0)) && (x_state[113-:5] == d_rs1))
			d_rs1_bypassed = x_result;
		else if ((m_state[33] && (m_state[38-:5] != 5'd0)) && (m_state[38-:5] == d_rs1))
			d_rs1_bypassed = m_state[31-:32];
		else if ((w_state[33] && (w_state[38-:5] != 5'd0)) && (w_state[38-:5] == d_rs1))
			d_rs1_bypassed = w_state[31-:32];
		if ((x_state[108] && (x_state[113-:5] != 5'd0)) && (x_state[113-:5] == d_rs2))
			d_rs2_bypassed = x_result;
		else if ((m_state[33] && (m_state[38-:5] != 5'd0)) && (m_state[38-:5] == d_rs2))
			d_rs2_bypassed = m_state[31-:32];
		else if ((w_state[33] && (w_state[38-:5] != 5'd0)) && (w_state[38-:5] == d_rs2))
			d_rs2_bypassed = w_state[31-:32];
	end
	reg [209:0] x_state_next;
	function automatic [31:0] sv2v_cast_32;
		input reg [31:0] inp;
		sv2v_cast_32 = inp;
	endfunction
	always @(*) begin
		if (_sv2v_0)
			;
		x_state_next = {64'h0000000000000000, sv2v_cast_32(decode_state[31-:32]), 13'h0000, ALU_ADD, 1'b0, d_rs1_bypassed, d_rs2_bypassed, 32'd0};
		if (decode_state[63-:32] == 32'd0)
			x_state_next = {64'h0000000000000000, sv2v_cast_32(decode_state[31-:32]), 13'h0000, ALU_ADD, 97'h0000000000000000000000000};
		else if (d_is_lui) begin
			x_state_next[209-:32] = decode_state[95-:32];
			x_state_next[177-:32] = decode_state[63-:32];
			x_state_next[113-:5] = d_rd;
			x_state_next[108] = d_rd != 5'd0;
			x_state_next[100-:4] = ALU_COPY_B;
			x_state_next[96] = 1'b1;
			x_state_next[31-:32] = d_imm_u;
		end
		else if (d_is_auipc) begin
			x_state_next[209-:32] = decode_state[95-:32];
			x_state_next[177-:32] = decode_state[63-:32];
			x_state_next[113-:5] = d_rd;
			x_state_next[108] = d_rd != 5'd0;
			x_state_next[100-:4] = ALU_ADD_PC_IMM;
			x_state_next[96] = 1'b1;
			x_state_next[31-:32] = d_imm_u;
		end
		else if (d_is_regimm) begin
			x_state_next[209-:32] = decode_state[95-:32];
			x_state_next[177-:32] = decode_state[63-:32];
			x_state_next[113-:5] = d_rd;
			x_state_next[108] = d_rd != 5'd0;
			x_state_next[96] = 1'b1;
			x_state_next[31-:32] = d_imm_i;
			(* full_case, parallel_case *)
			case (d_funct3)
				3'b000: x_state_next[100-:4] = ALU_ADD;
				3'b010: x_state_next[100-:4] = ALU_SLT;
				3'b011: x_state_next[100-:4] = ALU_SLTU;
				3'b100: x_state_next[100-:4] = ALU_XOR;
				3'b110: x_state_next[100-:4] = ALU_OR;
				3'b111: x_state_next[100-:4] = ALU_AND;
				3'b001: begin
					x_state_next[100-:4] = ALU_SLL;
					x_state_next[31-:32] = {27'd0, decode_state[56:52]};
				end
				3'b101: begin
					x_state_next[31-:32] = {27'd0, decode_state[56:52]};
					if (decode_state[62])
						x_state_next[100-:4] = ALU_SRA;
					else
						x_state_next[100-:4] = ALU_SRL;
				end
				default:
					;
			endcase
		end
		else if (d_is_regreg) begin
			x_state_next[209-:32] = decode_state[95-:32];
			x_state_next[177-:32] = decode_state[63-:32];
			x_state_next[113-:5] = d_rd;
			x_state_next[108] = d_rd != 5'd0;
			(* full_case, parallel_case *)
			case (d_funct3)
				3'b000:
					if (d_funct7[5])
						x_state_next[100-:4] = ALU_SUB;
					else
						x_state_next[100-:4] = ALU_ADD;
				3'b001: x_state_next[100-:4] = ALU_SLL;
				3'b010: x_state_next[100-:4] = ALU_SLT;
				3'b011: x_state_next[100-:4] = ALU_SLTU;
				3'b100: x_state_next[100-:4] = ALU_XOR;
				3'b101:
					if (d_funct7[5])
						x_state_next[100-:4] = ALU_SRA;
					else
						x_state_next[100-:4] = ALU_SRL;
				3'b110: x_state_next[100-:4] = ALU_OR;
				3'b111: x_state_next[100-:4] = ALU_AND;
				default:
					;
			endcase
		end
		else if (d_is_branch) begin
			x_state_next[209-:32] = decode_state[95-:32];
			x_state_next[177-:32] = decode_state[63-:32];
			x_state_next[107] = 1'b1;
			x_state_next[31-:32] = d_imm_b;
			x_state_next[103-:3] = d_funct3;
		end
		else if (d_is_jal) begin
			x_state_next[209-:32] = decode_state[95-:32];
			x_state_next[177-:32] = decode_state[63-:32];
			x_state_next[113-:5] = d_rd;
			x_state_next[108] = d_rd != 5'd0;
			x_state_next[106] = 1'b1;
			x_state_next[31-:32] = d_imm_j;
		end
		else if (d_is_jalr) begin
			x_state_next[209-:32] = decode_state[95-:32];
			x_state_next[177-:32] = decode_state[63-:32];
			x_state_next[113-:5] = d_rd;
			x_state_next[108] = d_rd != 5'd0;
			x_state_next[105] = 1'b1;
			x_state_next[96] = 1'b1;
			x_state_next[31-:32] = d_imm_i;
		end
		else if (d_is_env) begin
			if ((((decode_state[63:52] == 12'd0) && (d_rs1 == 5'd0)) && (d_funct3 == 3'd0)) && (d_rd == 5'd0)) begin
				x_state_next[209-:32] = decode_state[95-:32];
				x_state_next[177-:32] = decode_state[63-:32];
				x_state_next[104] = 1'b1;
			end
		end
	end
	wire [31:0] x_operand_b;
	reg x_branch_taken;
	wire [31:0] x_branch_target;
	wire [31:0] x_jump_target;
	wire [31:0] x_jalr_target;
	assign x_operand_b = (x_state[96] ? x_state[31-:32] : x_state[63-:32]);
	assign x_branch_target = x_state[209-:32] + x_state[31-:32];
	assign x_jump_target = x_state[209-:32] + x_state[31-:32];
	assign x_jalr_target = (x_state[95-:32] + x_state[31-:32]) & 32'hfffffffe;
	always @(*) begin
		if (_sv2v_0)
			;
		if (x_state[106] || x_state[105])
			x_result = x_state[209-:32] + 32'd4;
		else
			(* full_case, parallel_case *)
			case (x_state[100-:4])
				ALU_ADD: x_result = x_state[95-:32] + x_operand_b;
				ALU_SUB: x_result = x_state[95-:32] - x_operand_b;
				ALU_AND: x_result = x_state[95-:32] & x_operand_b;
				ALU_OR: x_result = x_state[95-:32] | x_operand_b;
				ALU_XOR: x_result = x_state[95-:32] ^ x_operand_b;
				ALU_SLT: x_result = ($signed(x_state[95-:32]) < $signed(x_operand_b) ? 32'd1 : 32'd0);
				ALU_SLTU: x_result = (x_state[95-:32] < x_operand_b ? 32'd1 : 32'd0);
				ALU_SLL: x_result = x_state[95-:32] << x_operand_b[4:0];
				ALU_SRL: x_result = x_state[95-:32] >> x_operand_b[4:0];
				ALU_SRA: x_result = $signed(x_state[95-:32]) >>> x_operand_b[4:0];
				ALU_ADD_PC_IMM: x_result = x_state[209-:32] + x_state[31-:32];
				ALU_COPY_B: x_result = x_operand_b;
				default: x_result = 32'd0;
			endcase
	end
	always @(*) begin
		if (_sv2v_0)
			;
		x_branch_taken = 1'b0;
		if (x_state[107])
			(* full_case, parallel_case *)
			case (x_state[103-:3])
				3'b000: x_branch_taken = x_state[95-:32] == x_state[63-:32];
				3'b001: x_branch_taken = x_state[95-:32] != x_state[63-:32];
				3'b100: x_branch_taken = $signed(x_state[95-:32]) < $signed(x_state[63-:32]);
				3'b101: x_branch_taken = $signed(x_state[95-:32]) >= $signed(x_state[63-:32]);
				3'b110: x_branch_taken = x_state[95-:32] < x_state[63-:32];
				3'b111: x_branch_taken = x_state[95-:32] >= x_state[63-:32];
				default: x_branch_taken = 1'b0;
			endcase
	end
	assign addr_to_dmem = 32'd0;
	assign store_data_to_dmem = 32'd0;
	assign store_we_to_dmem = 4'b0000;
	assign trace_completed_pc = (w_state[102-:32] == 32'd0 ? 32'd0 : w_state[134-:32]);
	assign trace_completed_insn = (w_state[102-:32] == 32'd0 ? 32'd0 : w_state[102-:32]);
	assign trace_completed_cycle_status = w_state[70-:32];
	always @(posedge clk)
		if (rst)
			halt <= 1'b0;
		else if (m_state[32] && (m_state[102-:32] != 32'd0))
			halt <= 1'b1;
	function automatic [4:0] sv2v_cast_5;
		input reg [4:0] inp;
		sv2v_cast_5 = inp;
	endfunction
	always @(posedge clk)
		if (rst) begin
			f_pc_current <= 32'd0;
			f_cycle_status <= 32'd1;
			decode_state <= 96'h000000000000000000000004;
			x_state <= {109'h0000000000000000000000008000, ALU_ADD, 97'h0000000000000000000000000};
			w_state <= 135'h0000000000000000000000020000000000;
			m_state <= 135'h0000000000000000000000020000000000;
		end
		else begin
			w_state <= m_state;
			m_state <= {sv2v_cast_32(x_state[209-:32]), sv2v_cast_32(x_state[177-:32]), sv2v_cast_32(x_state[145-:32]), sv2v_cast_5(x_state[113-:5]), x_state[108], x_state[104], x_result};
			if ((x_branch_taken || x_state[106]) || x_state[105]) begin
				x_state <= {109'h0000000000000000000000010000, ALU_ADD, 97'h0000000000000000000000000};
				decode_state <= 96'h000000000000000000000008;
				if (x_state[106])
					f_pc_current <= x_jump_target;
				else if (x_state[105])
					f_pc_current <= x_jalr_target;
				else
					f_pc_current <= x_branch_target;
				f_cycle_status <= 32'd1;
			end
			else begin
				x_state <= x_state_next;
				decode_state <= {f_pc_current, f_insn, f_cycle_status};
				f_pc_current <= f_pc_current + 32'd4;
				f_cycle_status <= 32'd1;
			end
		end
	initial _sv2v_0 = 0;
endmodule
module MemorySingleCycle (
	rst,
	clk,
	pc_to_imem,
	insn_from_imem,
	addr_to_dmem,
	load_data_from_dmem,
	store_data_to_dmem,
	store_we_to_dmem
);
	reg _sv2v_0;
	parameter signed [31:0] NUM_WORDS = 512;
	input wire rst;
	input wire clk;
	input wire [31:0] pc_to_imem;
	output reg [31:0] insn_from_imem;
	input wire [31:0] addr_to_dmem;
	output reg [31:0] load_data_from_dmem;
	input wire [31:0] store_data_to_dmem;
	input wire [3:0] store_we_to_dmem;
	reg [31:0] mem_array [0:NUM_WORDS - 1];
	initial $readmemh("mem_initial_contents.hex", mem_array);
	always @(*)
		if (_sv2v_0)
			;
	localparam signed [31:0] AddrMsb = $clog2(NUM_WORDS) + 1;
	localparam signed [31:0] AddrLsb = 2;
	always @(negedge clk)
		if (rst)
			;
		else
			insn_from_imem <= mem_array[{pc_to_imem[AddrMsb:AddrLsb]}];
	always @(negedge clk)
		if (rst)
			;
		else begin
			if (store_we_to_dmem[0])
				mem_array[addr_to_dmem[AddrMsb:AddrLsb]][7:0] <= store_data_to_dmem[7:0];
			if (store_we_to_dmem[1])
				mem_array[addr_to_dmem[AddrMsb:AddrLsb]][15:8] <= store_data_to_dmem[15:8];
			if (store_we_to_dmem[2])
				mem_array[addr_to_dmem[AddrMsb:AddrLsb]][23:16] <= store_data_to_dmem[23:16];
			if (store_we_to_dmem[3])
				mem_array[addr_to_dmem[AddrMsb:AddrLsb]][31:24] <= store_data_to_dmem[31:24];
			load_data_from_dmem <= mem_array[{addr_to_dmem[AddrMsb:AddrLsb]}];
		end
	initial _sv2v_0 = 0;
endmodule
`default_nettype none
`default_nettype none
module SystemResourceCheck (
	external_clk_25MHz,
	btn,
	led
);
	input wire external_clk_25MHz;
	input wire [6:0] btn;
	output wire [7:0] led;
	wire clk_proc;
	wire clk_locked;
	MyClockGen clock_gen(
		.input_clk_25MHz(external_clk_25MHz),
		.clk_proc(clk_proc),
		.locked(clk_locked)
	);
	wire [31:0] pc_to_imem;
	wire [31:0] insn_from_imem;
	wire [31:0] mem_data_addr;
	wire [31:0] mem_data_loaded_value;
	wire [31:0] mem_data_to_write;
	wire [3:0] mem_data_we;
	wire [31:0] trace_writeback_pc;
	wire [31:0] trace_writeback_insn;
	wire [31:0] trace_writeback_cycle_status;
	MemorySingleCycle #(.NUM_WORDS(128)) memory(
		.rst(!clk_locked),
		.clk(clk_proc),
		.pc_to_imem(pc_to_imem),
		.insn_from_imem(insn_from_imem),
		.addr_to_dmem(mem_data_addr),
		.load_data_from_dmem(mem_data_loaded_value),
		.store_data_to_dmem(mem_data_to_write),
		.store_we_to_dmem(mem_data_we)
	);
	DatapathPipelined datapath(
		.clk(clk_proc),
		.rst(!clk_locked),
		.pc_to_imem(pc_to_imem),
		.insn_from_imem(insn_from_imem),
		.addr_to_dmem(mem_data_addr),
		.store_data_to_dmem(mem_data_to_write),
		.store_we_to_dmem(mem_data_we),
		.load_data_from_dmem(mem_data_loaded_value),
		.halt(led[0]),
		.trace_completed_pc(trace_writeback_pc),
		.trace_completed_insn(trace_writeback_insn),
		.trace_completed_cycle_status(trace_writeback_cycle_status)
	);
endmodule