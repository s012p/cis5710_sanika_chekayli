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
	localparam [6:0] OpcodeLoad = 7'b0000011;
	localparam [6:0] OpcodeStore = 7'b0100011;
	localparam [6:0] OpcodeBranch = 7'b1100011;
	localparam [6:0] OpcodeJalr = 7'b1100111;
	localparam [6:0] OpcodeJal = 7'b1101111;
	localparam [6:0] OpcodeRegImm = 7'b0010011;
	localparam [6:0] OpcodeRegReg = 7'b0110011;
	localparam [6:0] OpcodeEnviron = 7'b1110011;
	localparam [6:0] OpcodeAuipc = 7'b0010111;
	localparam [6:0] OpcodeLui = 7'b0110111;
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
	localparam [1:0] MUL_LO = 2'd0;
	localparam [1:0] MUL_HI_SS = 2'd1;
	localparam [1:0] MUL_HI_SU = 2'd2;
	localparam [1:0] MUL_HI_UU = 2'd3;
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
	reg [225:0] x_state;
	reg [209:0] m_state;
	reg [134:0] w_state;
	reg [134:0] div_pipe [0:7];
	integer div_idx;
	wire [255:0] x_disasm;
	Disasm #(.PREFIX("X")) disasm_2execute(
		.insn(x_state[193-:32]),
		.disasm(x_disasm)
	);
	wire [255:0] m_disasm;
	Disasm #(.PREFIX("M")) disasm_3memory(
		.insn(m_state[177-:32]),
		.disasm(m_disasm)
	);
	wire [255:0] w_disasm;
	Disasm #(.PREFIX("W")) disasm_4writeback(
		.insn(w_state[102-:32]),
		.disasm(w_disasm)
	);
	reg div_any_inflight;
	function automatic [63:0] do_divu;
		input reg [31:0] dividend;
		input reg [31:0] divisor;
		begin
			do_divu[63-:32] = (divisor == 32'd0 ? 32'hffffffff : 32'd0);
			do_divu[31-:32] = (divisor == 32'd0 ? dividend : 32'd0);
		end
	endfunction
	function automatic [63:0] do_div_signed;
		input reg [31:0] a;
		input reg [31:0] b;
		if (b == 32'd0) begin
			do_div_signed[63-:32] = 32'hffffffff;
			do_div_signed[31-:32] = a;
		end
		else if ((a == 32'h80000000) && (b == 32'hffffffff)) begin
			do_div_signed[63-:32] = 32'h80000000;
			do_div_signed[31-:32] = 32'd0;
		end
		else begin
			do_div_signed[63-:32] = 32'd0;
			do_div_signed[31-:32] = 32'd0;
		end
	endfunction
	wire [6:0] d_opcode;
	wire [4:0] d_rs1;
	wire [4:0] d_rs2;
	wire [4:0] d_rd;
	wire [2:0] d_funct3;
	wire [6:0] d_funct7;
	wire [31:0] d_imm_i;
	wire [31:0] d_imm_s;
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
	assign d_imm_s = {{20 {decode_state[63]}}, decode_state[63:57], decode_state[43:39]};
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
	wire d_is_load;
	wire d_is_store;
	wire d_is_mul;
	wire d_is_div;
	wire d_is_rem;
	reg d_uses_rs1;
	reg d_uses_rs2;
	assign d_is_lui = d_opcode == OpcodeLui;
	assign d_is_auipc = d_opcode == OpcodeAuipc;
	assign d_is_regimm = d_opcode == OpcodeRegImm;
	assign d_is_regreg = d_opcode == OpcodeRegReg;
	assign d_is_branch = d_opcode == OpcodeBranch;
	assign d_is_jal = d_opcode == OpcodeJal;
	assign d_is_jalr = d_opcode == OpcodeJalr;
	assign d_is_env = d_opcode == OpcodeEnviron;
	assign d_is_load = d_opcode == OpcodeLoad;
	assign d_is_store = d_opcode == OpcodeStore;
	assign d_is_mul = (d_is_regreg && (d_funct7 == 7'b0000001)) && (d_funct3[2] == 1'b0);
	assign d_is_div = (d_is_regreg && (d_funct7 == 7'b0000001)) && (d_funct3[2:1] == 2'b10);
	assign d_is_rem = (d_is_regreg && (d_funct7 == 7'b0000001)) && (d_funct3[2:1] == 2'b11);
	always @(*) begin
		if (_sv2v_0)
			;
		d_uses_rs1 = 1'b0;
		d_uses_rs2 = 1'b0;
		if ((d_is_regimm || d_is_load) || d_is_jalr)
			d_uses_rs1 = 1'b1;
		else if ((d_is_regreg || d_is_branch) || d_is_store) begin
			d_uses_rs1 = 1'b1;
			d_uses_rs2 = 1'b1;
		end
	end
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
	wire [31:0] m_result_bypass;
	reg [31:0] d_rs1_bypassed;
	reg [31:0] d_rs2_bypassed;
	reg [31:0] x_result;
	always @(*) begin
		if (_sv2v_0)
			;
		d_rs1_bypassed = rf_rs1_data;
		d_rs2_bypassed = rf_rs2_data;
		if (((x_state[114] && !x_state[109]) && (x_state[129-:5] != 5'd0)) && (x_state[129-:5] == d_rs1))
			d_rs1_bypassed = x_result;
		else if ((m_state[103] && (m_state[113-:5] != 5'd0)) && (m_state[113-:5] == d_rs1))
			d_rs1_bypassed = m_result_bypass;
		else if ((w_state[33] && (w_state[38-:5] != 5'd0)) && (w_state[38-:5] == d_rs1))
			d_rs1_bypassed = w_state[31-:32];
		if (((x_state[114] && !x_state[109]) && (x_state[129-:5] != 5'd0)) && (x_state[129-:5] == d_rs2))
			d_rs2_bypassed = x_result;
		else if ((m_state[103] && (m_state[113-:5] != 5'd0)) && (m_state[113-:5] == d_rs2))
			d_rs2_bypassed = m_result_bypass;
		else if ((w_state[33] && (w_state[38-:5] != 5'd0)) && (w_state[38-:5] == d_rs2))
			d_rs2_bypassed = w_state[31-:32];
	end
	reg [225:0] x_state_next;
	function automatic [31:0] sv2v_cast_32;
		input reg [31:0] inp;
		sv2v_cast_32 = inp;
	endfunction
	always @(*) begin
		if (_sv2v_0)
			;
		x_state_next = {64'h0000000000000000, sv2v_cast_32(decode_state[31-:32]), 5'd0, d_rs1, d_rs2, 8'b00000000, div_any_inflight, 3'd0, ALU_ADD, MUL_LO, 1'b0, d_rs1_bypassed, d_rs2_bypassed, 32'd0};
		if (decode_state[63-:32] == 32'd0)
			x_state_next = {64'h0000000000000000, sv2v_cast_32(decode_state[31-:32]), 27'h0000000, ALU_ADD, MUL_LO, 97'h0000000000000000000000000};
		else if (d_is_lui) begin
			x_state_next[225-:32] = decode_state[95-:32];
			x_state_next[193-:32] = decode_state[63-:32];
			x_state_next[129-:5] = d_rd;
			x_state_next[124-:5] = d_rs1;
			x_state_next[114] = d_rd != 5'd0;
			x_state_next[102-:4] = ALU_COPY_B;
			x_state_next[96] = 1'b1;
			x_state_next[31-:32] = d_imm_u;
		end
		else if (d_is_auipc) begin
			x_state_next[225-:32] = decode_state[95-:32];
			x_state_next[193-:32] = decode_state[63-:32];
			x_state_next[129-:5] = d_rd;
			x_state_next[124-:5] = d_rs1;
			x_state_next[114] = d_rd != 5'd0;
			x_state_next[102-:4] = ALU_ADD_PC_IMM;
			x_state_next[96] = 1'b1;
			x_state_next[31-:32] = d_imm_u;
		end
		else if (d_is_regimm) begin
			x_state_next[225-:32] = decode_state[95-:32];
			x_state_next[193-:32] = decode_state[63-:32];
			x_state_next[129-:5] = d_rd;
			x_state_next[124-:5] = d_rs1;
			x_state_next[114] = d_rd != 5'd0;
			x_state_next[96] = 1'b1;
			x_state_next[31-:32] = d_imm_i;
			(* full_case, parallel_case *)
			case (d_funct3)
				3'b000: x_state_next[102-:4] = ALU_ADD;
				3'b010: x_state_next[102-:4] = ALU_SLT;
				3'b011: x_state_next[102-:4] = ALU_SLTU;
				3'b100: x_state_next[102-:4] = ALU_XOR;
				3'b110: x_state_next[102-:4] = ALU_OR;
				3'b111: x_state_next[102-:4] = ALU_AND;
				3'b001: begin
					x_state_next[102-:4] = ALU_SLL;
					x_state_next[31-:32] = {27'd0, decode_state[56:52]};
				end
				3'b101: begin
					x_state_next[31-:32] = {27'd0, decode_state[56:52]};
					if (decode_state[62])
						x_state_next[102-:4] = ALU_SRA;
					else
						x_state_next[102-:4] = ALU_SRL;
				end
				default:
					;
			endcase
		end
		else if (d_is_mul) begin
			x_state_next[225-:32] = decode_state[95-:32];
			x_state_next[193-:32] = decode_state[63-:32];
			x_state_next[129-:5] = d_rd;
			x_state_next[124-:5] = d_rs1;
			x_state_next[114] = d_rd != 5'd0;
			x_state_next[107] = 1'b1;
			x_state_next[105-:3] = d_funct3;
			(* full_case, parallel_case *)
			case (d_funct3)
				3'b000: x_state_next[98-:2] = MUL_LO;
				3'b001: x_state_next[98-:2] = MUL_HI_SS;
				3'b010: x_state_next[98-:2] = MUL_HI_SU;
				3'b011: x_state_next[98-:2] = MUL_HI_UU;
				default: x_state_next[98-:2] = MUL_LO;
			endcase
		end
		else if ((d_is_regreg && !d_is_div) && !d_is_rem) begin
			x_state_next[225-:32] = decode_state[95-:32];
			x_state_next[193-:32] = decode_state[63-:32];
			x_state_next[129-:5] = d_rd;
			x_state_next[124-:5] = d_rs1;
			x_state_next[114] = d_rd != 5'd0;
			(* full_case, parallel_case *)
			case (d_funct3)
				3'b000:
					if (d_funct7[5])
						x_state_next[102-:4] = ALU_SUB;
					else
						x_state_next[102-:4] = ALU_ADD;
				3'b001: x_state_next[102-:4] = ALU_SLL;
				3'b010: x_state_next[102-:4] = ALU_SLT;
				3'b011: x_state_next[102-:4] = ALU_SLTU;
				3'b100: x_state_next[102-:4] = ALU_XOR;
				3'b101:
					if (d_funct7[5])
						x_state_next[102-:4] = ALU_SRA;
					else
						x_state_next[102-:4] = ALU_SRL;
				3'b110: x_state_next[102-:4] = ALU_OR;
				3'b111: x_state_next[102-:4] = ALU_AND;
				default:
					;
			endcase
		end
		else if (d_is_load) begin
			x_state_next[225-:32] = decode_state[95-:32];
			x_state_next[193-:32] = decode_state[63-:32];
			x_state_next[129-:5] = d_rd;
			x_state_next[124-:5] = d_rs1;
			x_state_next[114] = d_rd != 5'd0;
			x_state_next[109] = 1'b1;
			x_state_next[105-:3] = d_funct3;
			x_state_next[96] = 1'b1;
			x_state_next[31-:32] = d_imm_i;
			x_state_next[102-:4] = ALU_ADD;
		end
		else if (d_is_store) begin
			x_state_next[225-:32] = decode_state[95-:32];
			x_state_next[193-:32] = decode_state[63-:32];
			x_state_next[124-:5] = d_rs1;
			x_state_next[119-:5] = d_rs2;
			x_state_next[108] = 1'b1;
			x_state_next[105-:3] = d_funct3;
			x_state_next[96] = 1'b1;
			x_state_next[31-:32] = d_imm_s;
			x_state_next[102-:4] = ALU_ADD;
		end
		else if (d_is_branch) begin
			x_state_next[225-:32] = decode_state[95-:32];
			x_state_next[193-:32] = decode_state[63-:32];
			x_state_next[124-:5] = d_rs1;
			x_state_next[119-:5] = d_rs2;
			x_state_next[113] = 1'b1;
			x_state_next[31-:32] = d_imm_b;
			x_state_next[105-:3] = d_funct3;
		end
		else if (d_is_jal) begin
			x_state_next[225-:32] = decode_state[95-:32];
			x_state_next[193-:32] = decode_state[63-:32];
			x_state_next[129-:5] = d_rd;
			x_state_next[124-:5] = d_rs1;
			x_state_next[114] = d_rd != 5'd0;
			x_state_next[112] = 1'b1;
			x_state_next[31-:32] = d_imm_j;
		end
		else if (d_is_jalr) begin
			x_state_next[225-:32] = decode_state[95-:32];
			x_state_next[193-:32] = decode_state[63-:32];
			x_state_next[129-:5] = d_rd;
			x_state_next[124-:5] = d_rs1;
			x_state_next[114] = d_rd != 5'd0;
			x_state_next[111] = 1'b1;
			x_state_next[96] = 1'b1;
			x_state_next[31-:32] = d_imm_i;
		end
		else if (d_is_env) begin
			if ((((decode_state[63:52] == 12'd0) && (d_rs1 == 5'd0)) && (d_funct3 == 3'd0)) && (d_rd == 5'd0)) begin
				x_state_next[225-:32] = decode_state[95-:32];
				x_state_next[193-:32] = decode_state[63-:32];
				x_state_next[110] = 1'b1;
			end
		end
	end
	reg [31:0] x_rs1_eff;
	reg [31:0] x_rs2_eff;
	wire [31:0] x_operand_b;
	reg x_branch_taken;
	wire [31:0] x_branch_target;
	wire [31:0] x_jump_target;
	wire [31:0] x_jalr_target;
	wire signed [63:0] x_prod_ss;
	wire signed [63:0] x_prod_su;
	wire [63:0] x_prod_uu;
	always @(*) begin
		if (_sv2v_0)
			;
		x_rs1_eff = x_state[95-:32];
		x_rs2_eff = x_state[63-:32];
		if ((m_state[103] && (m_state[113-:5] != 5'd0)) && (m_state[113-:5] == x_state[124-:5]))
			x_rs1_eff = m_result_bypass;
		else if ((w_state[33] && (w_state[38-:5] != 5'd0)) && (w_state[38-:5] == x_state[124-:5]))
			x_rs1_eff = w_state[31-:32];
		if ((m_state[103] && (m_state[113-:5] != 5'd0)) && (m_state[113-:5] == x_state[119-:5]))
			x_rs2_eff = m_result_bypass;
		else if ((w_state[33] && (w_state[38-:5] != 5'd0)) && (w_state[38-:5] == x_state[119-:5]))
			x_rs2_eff = w_state[31-:32];
	end
	assign x_operand_b = (x_state[96] ? x_state[31-:32] : x_rs2_eff);
	assign x_branch_target = x_state[225-:32] + x_state[31-:32];
	assign x_jump_target = x_state[225-:32] + x_state[31-:32];
	assign x_jalr_target = (x_rs1_eff + x_state[31-:32]) & 32'hfffffffe;
	assign x_prod_ss = $signed(x_rs1_eff) * $signed(x_rs2_eff);
	assign x_prod_su = $signed(x_rs1_eff) * $signed({1'b0, x_rs2_eff});
	assign x_prod_uu = x_rs1_eff * x_rs2_eff;
	always @(*) begin
		if (_sv2v_0)
			;
		if (x_state[112] || x_state[111])
			x_result = x_state[225-:32] + 32'd4;
		else if (x_state[107])
			(* full_case, parallel_case *)
			case (x_state[98-:2])
				MUL_LO: x_result = x_prod_uu[31:0];
				MUL_HI_SS: x_result = x_prod_ss[63:32];
				MUL_HI_SU: x_result = x_prod_su[63:32];
				MUL_HI_UU: x_result = x_prod_uu[63:32];
				default: x_result = 32'd0;
			endcase
		else
			(* full_case, parallel_case *)
			case (x_state[102-:4])
				ALU_ADD: x_result = x_rs1_eff + x_operand_b;
				ALU_SUB: x_result = x_rs1_eff - x_operand_b;
				ALU_AND: x_result = x_rs1_eff & x_operand_b;
				ALU_OR: x_result = x_rs1_eff | x_operand_b;
				ALU_XOR: x_result = x_rs1_eff ^ x_operand_b;
				ALU_SLT: x_result = ($signed(x_rs1_eff) < $signed(x_operand_b) ? 32'd1 : 32'd0);
				ALU_SLTU: x_result = (x_rs1_eff < x_operand_b ? 32'd1 : 32'd0);
				ALU_SLL: x_result = x_rs1_eff << x_operand_b[4:0];
				ALU_SRL: x_result = x_rs1_eff >> x_operand_b[4:0];
				ALU_SRA: x_result = $signed(x_rs1_eff) >>> x_operand_b[4:0];
				ALU_ADD_PC_IMM: x_result = x_state[225-:32] + x_state[31-:32];
				ALU_COPY_B: x_result = x_operand_b;
				default: x_result = 32'd0;
			endcase
	end
	always @(*) begin
		if (_sv2v_0)
			;
		x_branch_taken = 1'b0;
		if (x_state[113])
			(* full_case, parallel_case *)
			case (x_state[105-:3])
				3'b000: x_branch_taken = x_rs1_eff == x_rs2_eff;
				3'b001: x_branch_taken = x_rs1_eff != x_rs2_eff;
				3'b100: x_branch_taken = $signed(x_rs1_eff) < $signed(x_rs2_eff);
				3'b101: x_branch_taken = $signed(x_rs1_eff) >= $signed(x_rs2_eff);
				3'b110: x_branch_taken = x_rs1_eff < x_rs2_eff;
				3'b111: x_branch_taken = x_rs1_eff >= x_rs2_eff;
				default: x_branch_taken = 1'b0;
			endcase
	end
	wire [31:0] m_addr_aligned;
	wire [1:0] m_byte_off;
	wire [31:0] m_store_data_bypassed;
	reg [31:0] m_load_result;
	reg [3:0] m_store_we;
	reg [31:0] m_store_data_shifted;
	assign m_addr_aligned = {m_state[95:66], 2'b00};
	assign m_byte_off = m_state[65:64];
	assign m_store_data_bypassed = (((m_state[100] && w_state[33]) && (w_state[38-:5] != 5'd0)) && (w_state[38-:5] == m_state[108-:5]) ? w_state[31-:32] : m_state[31-:32]);
	always @(*) begin
		if (_sv2v_0)
			;
		m_store_we = 4'b0000;
		m_store_data_shifted = 32'd0;
		if (m_state[100])
			(* full_case, parallel_case *)
			case (m_state[98-:3])
				3'b000:
					(* full_case, parallel_case *)
					case (m_byte_off)
						2'd0: begin
							m_store_we = 4'b0001;
							m_store_data_shifted = {24'd0, m_store_data_bypassed[7:0]};
						end
						2'd1: begin
							m_store_we = 4'b0010;
							m_store_data_shifted = {16'd0, m_store_data_bypassed[7:0], 8'd0};
						end
						2'd2: begin
							m_store_we = 4'b0100;
							m_store_data_shifted = {8'd0, m_store_data_bypassed[7:0], 16'd0};
						end
						2'd3: begin
							m_store_we = 4'b1000;
							m_store_data_shifted = {m_store_data_bypassed[7:0], 24'd0};
						end
					endcase
				3'b001:
					if (m_byte_off[1] == 1'b0) begin
						m_store_we = (m_byte_off[0] ? 4'b0110 : 4'b0011);
						m_store_data_shifted = (m_byte_off[0] ? {8'd0, m_store_data_bypassed[15:0], 8'd0} : {16'd0, m_store_data_bypassed[15:0]});
					end
					else begin
						m_store_we = 4'b1100;
						m_store_data_shifted = {m_store_data_bypassed[15:0], 16'd0};
					end
				3'b010: begin
					m_store_we = 4'b1111;
					m_store_data_shifted = m_store_data_bypassed;
				end
				default:
					;
			endcase
	end
	always @(*) begin
		if (_sv2v_0)
			;
		m_load_result = m_state[63-:32];
		if (m_state[101])
			(* full_case, parallel_case *)
			case (m_state[98-:3])
				3'b000:
					(* full_case, parallel_case *)
					case (m_byte_off)
						2'd0: m_load_result = {{24 {load_data_from_dmem[7]}}, load_data_from_dmem[7:0]};
						2'd1: m_load_result = {{24 {load_data_from_dmem[15]}}, load_data_from_dmem[15:8]};
						2'd2: m_load_result = {{24 {load_data_from_dmem[23]}}, load_data_from_dmem[23:16]};
						2'd3: m_load_result = {{24 {load_data_from_dmem[31]}}, load_data_from_dmem[31:24]};
					endcase
				3'b001:
					(* full_case, parallel_case *)
					case (m_byte_off[1])
						1'b0: m_load_result = {{16 {load_data_from_dmem[15]}}, load_data_from_dmem[15:0]};
						1'b1: m_load_result = {{16 {load_data_from_dmem[31]}}, load_data_from_dmem[31:16]};
					endcase
				3'b010: m_load_result = load_data_from_dmem;
				3'b100:
					(* full_case, parallel_case *)
					case (m_byte_off)
						2'd0: m_load_result = {24'd0, load_data_from_dmem[7:0]};
						2'd1: m_load_result = {24'd0, load_data_from_dmem[15:8]};
						2'd2: m_load_result = {24'd0, load_data_from_dmem[23:16]};
						2'd3: m_load_result = {24'd0, load_data_from_dmem[31:24]};
					endcase
				3'b101:
					(* full_case, parallel_case *)
					case (m_byte_off[1])
						1'b0: m_load_result = {16'd0, load_data_from_dmem[15:0]};
						1'b1: m_load_result = {16'd0, load_data_from_dmem[31:16]};
					endcase
				default: m_load_result = load_data_from_dmem;
			endcase
	end
	assign m_result_bypass = (m_state[101] ? m_load_result : m_state[63-:32]);
	assign addr_to_dmem = (m_state[101] || m_state[100] ? m_addr_aligned : 32'd0);
	assign store_data_to_dmem = m_store_data_shifted;
	assign store_we_to_dmem = m_store_we;
	assign trace_completed_pc = (w_state[102-:32] == 32'd0 ? 32'd0 : w_state[134-:32]);
	assign trace_completed_insn = (w_state[102-:32] == 32'd0 ? 32'd0 : w_state[102-:32]);
	assign trace_completed_cycle_status = w_state[70-:32];
	always @(posedge clk)
		if (rst)
			halt <= 1'b0;
		else if (m_state[102] && (m_state[177-:32] != 32'd0))
			halt <= 1'b1;
	reg load_use_hazard;
	reg div_dep_hazard;
	reg div_issue;
	reg div_pipe_hold;
	reg x_hold_for_div;
	reg hold_front_for_div_insert;
	reg [63:0] d_div_calc;
	always @(*) begin
		if (_sv2v_0)
			;
		load_use_hazard = (x_state[109] && (x_state[129-:5] != 5'd0)) && ((d_uses_rs1 && (d_rs1 == x_state[129-:5])) || ((d_uses_rs2 && !d_is_store) && (d_rs2 == x_state[129-:5])));
		div_any_inflight = 1'b0;
		div_dep_hazard = 1'b0;
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < 8; i = i + 1)
				begin
					if (div_pipe[i][134])
						div_any_inflight = 1'b1;
					if ((((d_is_div || d_is_rem) && div_pipe[i][134]) && (div_pipe[i][37-:5] != 5'd0)) && ((d_uses_rs1 && (d_rs1 == div_pipe[i][37-:5])) || (d_uses_rs2 && (d_rs2 == div_pipe[i][37-:5]))))
						div_dep_hazard = 1'b1;
				end
		end
		div_issue = d_is_div || d_is_rem;
		div_pipe_hold = 1'b0;
		x_hold_for_div = ((x_state[193-:32] != 32'd0) && x_state[106]) && div_any_inflight;
		hold_front_for_div_insert = div_pipe[7][134] && (x_state[193-:32] != 32'd0);
		if (d_is_div || d_is_rem) begin
			if (d_funct3[0])
				d_div_calc = do_divu(d_rs1_bypassed, d_rs2_bypassed);
			else
				d_div_calc = do_div_signed(d_rs1_bypassed, d_rs2_bypassed);
		end
		else begin
			d_div_calc[63-:32] = 32'd0;
			d_div_calc[31-:32] = 32'd0;
		end
	end
	function automatic [4:0] sv2v_cast_5;
		input reg [4:0] inp;
		sv2v_cast_5 = inp;
	endfunction
	function automatic [2:0] sv2v_cast_3;
		input reg [2:0] inp;
		sv2v_cast_3 = inp;
	endfunction
	always @(posedge clk)
		if (rst) begin
			f_pc_current <= 32'd0;
			f_cycle_status <= 32'd1;
			decode_state <= 96'h000000000000000000000004;
			x_state <= {123'h0000000000000000000000020000000, ALU_ADD, MUL_LO, 97'h0000000000000000000000000};
			m_state <= 210'h00000000000000000000000100000000000000000000000000000;
			w_state <= 135'h0000000000000000000000020000000000;
			for (div_idx = 0; div_idx < 8; div_idx = div_idx + 1)
				div_pipe[div_idx] <= 135'h0000000000000000000000010000000000;
		end
		else begin
			if (div_pipe[7][134]) begin
				w_state <= {sv2v_cast_32(m_state[209-:32]), sv2v_cast_32(m_state[177-:32]), sv2v_cast_32(m_state[145-:32]), sv2v_cast_5(m_state[113-:5]), m_state[103], m_state[102], m_result_bypass};
				m_state <= {sv2v_cast_32(div_pipe[7][133-:32]), sv2v_cast_32(div_pipe[7][101-:32]), sv2v_cast_32(div_pipe[7][69-:32]), sv2v_cast_5(div_pipe[7][37-:5]), 5'd0, div_pipe[7][32], 7'h00, sv2v_cast_32(div_pipe[7][31-:32]), sv2v_cast_32(div_pipe[7][31-:32]), 32'd0};
			end
			else begin
				w_state <= {sv2v_cast_32(m_state[209-:32]), sv2v_cast_32(m_state[177-:32]), sv2v_cast_32(m_state[145-:32]), sv2v_cast_5(m_state[113-:5]), m_state[103], m_state[102], m_result_bypass};
				if (x_hold_for_div || div_pipe_hold)
					m_state <= m_state;
				else
					m_state <= {sv2v_cast_32(x_state[225-:32]), sv2v_cast_32(x_state[193-:32]), sv2v_cast_32(x_state[161-:32]), sv2v_cast_5(x_state[129-:5]), sv2v_cast_5(x_state[119-:5]), x_state[114], x_state[110], x_state[109], x_state[108], x_state[106], sv2v_cast_3(x_state[105-:3]), x_result, x_result, x_rs2_eff};
			end
			if (!div_pipe_hold) begin
				for (div_idx = 7; div_idx > 0; div_idx = div_idx - 1)
					div_pipe[div_idx] <= div_pipe[div_idx - 1];
				div_pipe[0] <= 135'h0000000000000000000000008000000000;
			end
			else begin
				for (div_idx = 7; div_idx > 0; div_idx = div_idx - 1)
					div_pipe[div_idx] <= div_pipe[div_idx];
				div_pipe[0] <= div_pipe[0];
			end
			if ((x_branch_taken || x_state[112]) || x_state[111]) begin
				x_state <= {123'h0000000000000000000000040000000, ALU_ADD, MUL_LO, 97'h0000000000000000000000000};
				decode_state <= 96'h000000000000000000000008;
				if (x_state[112])
					f_pc_current <= x_jump_target;
				else if (x_state[111])
					f_pc_current <= x_jalr_target;
				else
					f_pc_current <= x_branch_target;
				f_cycle_status <= 32'd1;
			end
			else if (load_use_hazard) begin
				x_state <= {123'h0000000000000000000000080000000, ALU_ADD, MUL_LO, 97'h0000000000000000000000000};
				decode_state <= decode_state;
				f_pc_current <= f_pc_current;
				f_cycle_status <= 32'd1;
			end
			else if (div_pipe_hold || hold_front_for_div_insert) begin
				x_state <= x_state;
				decode_state <= decode_state;
				f_pc_current <= f_pc_current;
				f_cycle_status <= 32'd1;
			end
			else if (div_dep_hazard) begin
				x_state <= {123'h0000000000000000000000010000000, ALU_ADD, MUL_LO, 97'h0000000000000000000000000};
				decode_state <= decode_state;
				f_pc_current <= f_pc_current;
				f_cycle_status <= 32'd1;
			end
			else if (x_hold_for_div) begin
				x_state <= x_state;
				decode_state <= decode_state;
				f_pc_current <= f_pc_current;
				f_cycle_status <= 32'd1;
			end
			else if (div_issue) begin
				x_state <= {123'h0000000000000000000000010000000, ALU_ADD, MUL_LO, 97'h0000000000000000000000000};
				div_pipe[0] <= {1'b1, sv2v_cast_32(decode_state[95-:32]), sv2v_cast_32(decode_state[63-:32]), sv2v_cast_32(decode_state[31-:32]), d_rd, d_rd != 5'd0, sv2v_cast_32((d_is_rem ? d_div_calc[31-:32] : d_div_calc[63-:32]))};
				decode_state <= {f_pc_current, f_insn, f_cycle_status};
				f_pc_current <= f_pc_current + 32'd4;
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