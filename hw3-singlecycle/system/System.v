module MyClockGen (
	input_clk_25MHz,
	clk_proc,
	clk_mem,
	locked
);
	input input_clk_25MHz;
	output wire clk_proc;
	output wire clk_mem;
	output wire locked;
	wire clkfb;
	(* FREQUENCY_PIN_CLKI = "25" *) (* FREQUENCY_PIN_CLKOP = "4.16667" *) (* FREQUENCY_PIN_CLKOS = "4.01003" *) (* ICP_CURRENT = "12" *) (* LPF_RESISTOR = "8" *) (* MFG_ENABLE_FILTEROPAMP = "1" *) (* MFG_GMCREF_SEL = "2" *) EHXPLLL #(
		.PLLRST_ENA("DISABLED"),
		.INTFB_WAKE("DISABLED"),
		.STDBY_ENABLE("DISABLED"),
		.DPHASE_SOURCE("DISABLED"),
		.OUTDIVIDER_MUXA("DIVA"),
		.OUTDIVIDER_MUXB("DIVB"),
		.OUTDIVIDER_MUXC("DIVC"),
		.OUTDIVIDER_MUXD("DIVD"),
		.CLKI_DIV(6),
		.CLKOP_ENABLE("ENABLED"),
		.CLKOP_DIV(128),
		.CLKOP_CPHASE(64),
		.CLKOP_FPHASE(0),
		.CLKOS_ENABLE("ENABLED"),
		.CLKOS_DIV(133),
		.CLKOS_CPHASE(97),
		.CLKOS_FPHASE(2),
		.FEEDBK_PATH("INT_OP"),
		.CLKFB_DIV(1)
	) pll_i(
		.RST(1'b0),
		.STDBY(1'b0),
		.CLKI(input_clk_25MHz),
		.CLKOP(clk_proc),
		.CLKOS(clk_mem),
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
module DividerUnsigned (
	i_dividend,
	i_divisor,
	o_remainder,
	o_quotient
);
	input wire [31:0] i_dividend;
	input wire [31:0] i_divisor;
	output wire [31:0] o_remainder;
	output wire [31:0] o_quotient;
	wire [31:0] dividend_pipe [0:32];
	wire [31:0] remainder_pipe [0:32];
	wire [31:0] quotient_pipe [0:32];
	assign dividend_pipe[0] = i_dividend;
	assign remainder_pipe[0] = 32'b00000000000000000000000000000000;
	assign quotient_pipe[0] = 32'b00000000000000000000000000000000;
	genvar _gv_iter_1;
	generate
		for (_gv_iter_1 = 0; _gv_iter_1 < 32; _gv_iter_1 = _gv_iter_1 + 1) begin : gen_div_iter
			localparam iter = _gv_iter_1;
			DividerOneIter step(
				.i_dividend(dividend_pipe[iter]),
				.i_divisor(i_divisor),
				.i_remainder(remainder_pipe[iter]),
				.i_quotient(quotient_pipe[iter]),
				.o_dividend(dividend_pipe[iter + 1]),
				.o_remainder(remainder_pipe[iter + 1]),
				.o_quotient(quotient_pipe[iter + 1])
			);
		end
	endgenerate
	assign o_remainder = remainder_pipe[32];
	assign o_quotient = quotient_pipe[32];
endmodule
module DividerOneIter (
	i_dividend,
	i_divisor,
	i_remainder,
	i_quotient,
	o_dividend,
	o_remainder,
	o_quotient
);
	input wire [31:0] i_dividend;
	input wire [31:0] i_divisor;
	input wire [31:0] i_remainder;
	input wire [31:0] i_quotient;
	output wire [31:0] o_dividend;
	output wire [31:0] o_remainder;
	output wire [31:0] o_quotient;
	wire dividend_msb_bit;
	wire [31:0] remainder_after_shift;
	wire remainder_less_than_divisor;
	assign dividend_msb_bit = i_dividend[31];
	assign remainder_after_shift = {i_remainder[30:0], dividend_msb_bit};
	assign remainder_less_than_divisor = remainder_after_shift < i_divisor;
	assign o_quotient = (remainder_less_than_divisor ? i_quotient << 1 : (i_quotient << 1) | 32'b00000000000000000000000000000001);
	assign o_remainder = (remainder_less_than_divisor ? remainder_after_shift : remainder_after_shift - i_divisor);
	assign o_dividend = i_dividend << 1;
endmodule
module gp1 (
	a,
	b,
	g,
	p
);
	input wire a;
	input wire b;
	output wire g;
	output wire p;
	assign g = a & b;
	assign p = a | b;
endmodule
module gp4 (
	gin,
	pin,
	cin,
	gout,
	pout,
	cout
);
	input wire [3:0] gin;
	input wire [3:0] pin;
	input wire cin;
	output wire gout;
	output wire pout;
	output wire [2:0] cout;
	wire c0;
	assign c0 = cin;
	assign cout[0] = gin[0] | (pin[0] & c0);
	assign cout[1] = (gin[1] | (pin[1] & gin[0])) | ((pin[1] & pin[0]) & c0);
	assign cout[2] = ((gin[2] | (pin[2] & gin[1])) | ((pin[2] & pin[1]) & gin[0])) | (((pin[2] & pin[1]) & pin[0]) & c0);
	assign pout = &pin;
	assign gout = ((gin[3] | (pin[3] & gin[2])) | ((pin[3] & pin[2]) & gin[1])) | (((pin[3] & pin[2]) & pin[1]) & gin[0]);
endmodule
module gp8 (
	gin,
	pin,
	cin,
	gout,
	pout,
	cout
);
	input wire [7:0] gin;
	input wire [7:0] pin;
	input wire cin;
	output wire gout;
	output wire pout;
	output wire [6:0] cout;
	wire c1;
	wire c2;
	wire c3;
	wire c4;
	wire c5;
	wire c6;
	wire c7;
	assign c1 = gin[0] | (pin[0] & cin);
	assign c2 = gin[1] | (pin[1] & c1);
	assign c3 = gin[2] | (pin[2] & c2);
	assign c4 = gin[3] | (pin[3] & c3);
	assign c5 = gin[4] | (pin[4] & c4);
	assign c6 = gin[5] | (pin[5] & c5);
	assign c7 = gin[6] | (pin[6] & c6);
	assign cout = {c7, c6, c5, c4, c3, c2, c1};
	assign pout = &pin;
	assign gout = ((((((gin[7] | (pin[7] & gin[6])) | ((pin[7] & pin[6]) & gin[5])) | (((pin[7] & pin[6]) & pin[5]) & gin[4])) | ((((pin[7] & pin[6]) & pin[5]) & pin[4]) & gin[3])) | (((((pin[7] & pin[6]) & pin[5]) & pin[4]) & pin[3]) & gin[2])) | ((((((pin[7] & pin[6]) & pin[5]) & pin[4]) & pin[3]) & pin[2]) & gin[1])) | (((((((pin[7] & pin[6]) & pin[5]) & pin[4]) & pin[3]) & pin[2]) & pin[1]) & gin[0]);
endmodule
module CarryLookaheadAdder (
	a,
	b,
	cin,
	sum
);
	input wire [31:0] a;
	input wire [31:0] b;
	input wire cin;
	output wire [31:0] sum;
	wire [31:0] g;
	wire [31:0] p;
	genvar _gv_i_1;
	generate
		for (_gv_i_1 = 0; _gv_i_1 < 32; _gv_i_1 = _gv_i_1 + 1) begin : gpP
			localparam i = _gv_i_1;
			gp1 u(
				.a(a[i]),
				.b(b[i]),
				.g(g[i]),
				.p(p[i])
			);
		end
	endgenerate
	wire [3:0] g8;
	wire [3:0] p8;
	wire [2:0] cblk;
	wire [6:0] c0;
	wire [6:0] c1;
	wire [6:0] c2;
	wire [6:0] c3;
	wire dg;
	wire dp;
	gp8 b0(
		.gin(g[7:0]),
		.pin(p[7:0]),
		.cin(cin),
		.gout(g8[0]),
		.pout(p8[0]),
		.cout(c0)
	);
	gp8 b1(
		.gin(g[15:8]),
		.pin(p[15:8]),
		.cin(cblk[0]),
		.gout(g8[1]),
		.pout(p8[1]),
		.cout(c1)
	);
	gp8 b2(
		.gin(g[23:16]),
		.pin(p[23:16]),
		.cin(cblk[1]),
		.gout(g8[2]),
		.pout(p8[2]),
		.cout(c2)
	);
	gp8 b3(
		.gin(g[31:24]),
		.pin(p[31:24]),
		.cin(cblk[2]),
		.gout(g8[3]),
		.pout(p8[3]),
		.cout(c3)
	);
	gp4 top(
		.gin(g8),
		.pin(p8),
		.cin(cin),
		.gout(dg),
		.pout(dp),
		.cout(cblk)
	);
	wire [31:0] c_in;
	assign {c_in[31:25], c_in[24], c_in[23:17], c_in[16], c_in[15:9], c_in[8], c_in[7:1], c_in[0]} = {c3, cblk[2], c2, cblk[1], c1, cblk[0], c0, cin};
	assign sum = (a ^ b) ^ c_in;
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
	always @(*) begin
		if (_sv2v_0)
			;
		if (rs1 != 0)
			rs1_data = regs[rs1];
		else
			rs1_data = 32'd0;
		if (rs2 != 0)
			rs2_data = regs[rs2];
		else
			rs2_data = 32'd0;
	end
	always @(posedge clk)
		if (rst) begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < NumRegs; i = i + 1)
				regs[i] <= 32'd0;
		end
		else if (we && (rd != 0))
			regs[rd] <= rd_data;
	initial _sv2v_0 = 0;
endmodule
module DatapathSingleCycle (
	clk,
	rst,
	halt,
	pc_to_imem,
	insn_from_imem,
	addr_to_dmem,
	load_data_from_dmem,
	store_data_to_dmem,
	store_we_to_dmem,
	trace_completed_pc,
	trace_completed_insn,
	trace_completed_cycle_status
);
	reg _sv2v_0;
	input wire clk;
	input wire rst;
	output reg halt;
	output wire [31:0] pc_to_imem;
	input wire [31:0] insn_from_imem;
	output reg [31:0] addr_to_dmem;
	input wire [31:0] load_data_from_dmem;
	output reg [31:0] store_data_to_dmem;
	output reg [3:0] store_we_to_dmem;
	output reg [31:0] trace_completed_pc;
	output reg [31:0] trace_completed_insn;
	output reg [31:0] trace_completed_cycle_status;
	wire [6:0] insn_funct7;
	wire [4:0] insn_rs2;
	wire [4:0] insn_rs1;
	wire [2:0] insn_funct3;
	wire [4:0] insn_rd;
	wire [6:0] insn_opcode;
	assign {insn_funct7, insn_rs2, insn_rs1, insn_funct3, insn_rd, insn_opcode} = insn_from_imem;
	wire [11:0] imm_i;
	assign imm_i = insn_from_imem[31:20];
	wire [4:0] imm_shamt = insn_from_imem[24:20];
	wire [11:0] imm_s;
	assign imm_s = {insn_from_imem[31:25], insn_from_imem[11:7]};
	wire [12:0] imm_b;
	assign imm_b = {insn_from_imem[31], insn_from_imem[7], insn_from_imem[30:25], insn_from_imem[11:8], 1'b0};
	wire [20:0] imm_j;
	assign {imm_j[20], imm_j[10:1], imm_j[11], imm_j[19:12], imm_j[0]} = {insn_from_imem[31:12], 1'b0};
	wire [31:0] imm_i_sext = {{20 {imm_i[11]}}, imm_i[11:0]};
	wire [31:0] imm_s_sext = {{20 {imm_s[11]}}, imm_s[11:0]};
	wire [31:0] imm_b_sext = {{19 {imm_b[12]}}, imm_b[12:0]};
	wire [31:0] imm_j_sext = {{11 {imm_j[20]}}, imm_j[20:0]};
	localparam [6:0] OpLoad = 7'b0000011;
	localparam [6:0] OpStore = 7'b0100011;
	localparam [6:0] OpBranch = 7'b1100011;
	localparam [6:0] OpJalr = 7'b1100111;
	localparam [6:0] OpMiscMem = 7'b0001111;
	localparam [6:0] OpJal = 7'b1101111;
	localparam [6:0] OpRegImm = 7'b0010011;
	localparam [6:0] OpRegReg = 7'b0110011;
	localparam [6:0] OpEnviron = 7'b1110011;
	localparam [6:0] OpAuipc = 7'b0010111;
	localparam [6:0] OpLui = 7'b0110111;
	wire insn_lui = insn_opcode == OpLui;
	wire insn_auipc = insn_opcode == OpAuipc;
	wire insn_jal = insn_opcode == OpJal;
	wire insn_jalr = insn_opcode == OpJalr;
	wire insn_beq = (insn_opcode == OpBranch) && (insn_from_imem[14:12] == 3'b000);
	wire insn_bne = (insn_opcode == OpBranch) && (insn_from_imem[14:12] == 3'b001);
	wire insn_blt = (insn_opcode == OpBranch) && (insn_from_imem[14:12] == 3'b100);
	wire insn_bge = (insn_opcode == OpBranch) && (insn_from_imem[14:12] == 3'b101);
	wire insn_bltu = (insn_opcode == OpBranch) && (insn_from_imem[14:12] == 3'b110);
	wire insn_bgeu = (insn_opcode == OpBranch) && (insn_from_imem[14:12] == 3'b111);
	wire insn_lb = (insn_opcode == OpLoad) && (insn_from_imem[14:12] == 3'b000);
	wire insn_lh = (insn_opcode == OpLoad) && (insn_from_imem[14:12] == 3'b001);
	wire insn_lw = (insn_opcode == OpLoad) && (insn_from_imem[14:12] == 3'b010);
	wire insn_lbu = (insn_opcode == OpLoad) && (insn_from_imem[14:12] == 3'b100);
	wire insn_lhu = (insn_opcode == OpLoad) && (insn_from_imem[14:12] == 3'b101);
	wire insn_sb = (insn_opcode == OpStore) && (insn_from_imem[14:12] == 3'b000);
	wire insn_sh = (insn_opcode == OpStore) && (insn_from_imem[14:12] == 3'b001);
	wire insn_sw = (insn_opcode == OpStore) && (insn_from_imem[14:12] == 3'b010);
	wire insn_addi = (insn_opcode == OpRegImm) && (insn_from_imem[14:12] == 3'b000);
	wire insn_slti = (insn_opcode == OpRegImm) && (insn_from_imem[14:12] == 3'b010);
	wire insn_sltiu = (insn_opcode == OpRegImm) && (insn_from_imem[14:12] == 3'b011);
	wire insn_xori = (insn_opcode == OpRegImm) && (insn_from_imem[14:12] == 3'b100);
	wire insn_ori = (insn_opcode == OpRegImm) && (insn_from_imem[14:12] == 3'b110);
	wire insn_andi = (insn_opcode == OpRegImm) && (insn_from_imem[14:12] == 3'b111);
	wire insn_slli = ((insn_opcode == OpRegImm) && (insn_from_imem[14:12] == 3'b001)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_srli = ((insn_opcode == OpRegImm) && (insn_from_imem[14:12] == 3'b101)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_srai = ((insn_opcode == OpRegImm) && (insn_from_imem[14:12] == 3'b101)) && (insn_from_imem[31:25] == 7'b0100000);
	wire insn_add = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b000)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_sub = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b000)) && (insn_from_imem[31:25] == 7'b0100000);
	wire insn_sll = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b001)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_slt = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b010)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_sltu = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b011)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_xor = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b100)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_srl = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b101)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_sra = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b101)) && (insn_from_imem[31:25] == 7'b0100000);
	wire insn_or = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b110)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_and = ((insn_opcode == OpRegReg) && (insn_from_imem[14:12] == 3'b111)) && (insn_from_imem[31:25] == 7'd0);
	wire insn_mul = ((insn_opcode == OpRegReg) && (insn_from_imem[31:25] == 7'd1)) && (insn_from_imem[14:12] == 3'b000);
	wire insn_mulh = ((insn_opcode == OpRegReg) && (insn_from_imem[31:25] == 7'd1)) && (insn_from_imem[14:12] == 3'b001);
	wire insn_mulhsu = ((insn_opcode == OpRegReg) && (insn_from_imem[31:25] == 7'd1)) && (insn_from_imem[14:12] == 3'b010);
	wire insn_mulhu = ((insn_opcode == OpRegReg) && (insn_from_imem[31:25] == 7'd1)) && (insn_from_imem[14:12] == 3'b011);
	wire insn_div = ((insn_opcode == OpRegReg) && (insn_from_imem[31:25] == 7'd1)) && (insn_from_imem[14:12] == 3'b100);
	wire insn_divu = ((insn_opcode == OpRegReg) && (insn_from_imem[31:25] == 7'd1)) && (insn_from_imem[14:12] == 3'b101);
	wire insn_rem = ((insn_opcode == OpRegReg) && (insn_from_imem[31:25] == 7'd1)) && (insn_from_imem[14:12] == 3'b110);
	wire insn_remu = ((insn_opcode == OpRegReg) && (insn_from_imem[31:25] == 7'd1)) && (insn_from_imem[14:12] == 3'b111);
	wire insn_ecall = (insn_opcode == OpEnviron) && (insn_from_imem[31:7] == 25'd0);
	wire insn_fence = insn_opcode == OpMiscMem;
	reg [31:0] pcNext;
	reg [31:0] pcCurrent;
	always @(posedge clk)
		if (rst)
			pcCurrent <= 32'd0;
		else
			pcCurrent <= pcNext;
	assign pc_to_imem = pcCurrent;
	reg [31:0] cycles_current;
	reg [31:0] num_insns_current;
	always @(posedge clk)
		if (rst) begin
			cycles_current <= 0;
			num_insns_current <= 0;
		end
		else begin
			cycles_current <= cycles_current + 1;
			if (!rst)
				num_insns_current <= num_insns_current + 1;
		end
	wire [31:0] rs1_data;
	wire [31:0] rs2_data;
	reg [31:0] rd_data;
	reg write;
	RegFile rf(
		.clk(clk),
		.rst(rst),
		.we(write),
		.rd(insn_rd),
		.rd_data(rd_data),
		.rs1(insn_rs1),
		.rs2(insn_rs2),
		.rs1_data(rs1_data),
		.rs2_data(rs2_data)
	);
	reg [31:0] a;
	reg [31:0] b;
	reg illegal_insn;
	wire [31:0] temp_sum;
	reg cin;
	reg [1:0] byte_off;
	reg [31:0] word;
	reg [1:0] byte_off_s;
	wire signed [31:0] s_rs1;
	wire signed [31:0] s_rs2;
	assign s_rs1 = $signed(rs1_data);
	assign s_rs2 = $signed(rs2_data);
	wire rs1_neg;
	wire rs2_neg;
	assign rs1_neg = s_rs1[31];
	assign rs2_neg = s_rs2[31];
	wire [31:0] rs1_abs;
	wire [31:0] rs2_abs;
	wire [31:0] neg_rs1_sum;
	wire [31:0] neg_rs2_sum;
	CarryLookaheadAdder ca(
		.a(a),
		.b(b),
		.cin(cin),
		.sum(temp_sum)
	);
	CarryLookaheadAdder neg1(
		.a(~rs1_data),
		.b(32'd0),
		.cin(1'b1),
		.sum(neg_rs1_sum)
	);
	CarryLookaheadAdder neg2(
		.a(~rs2_data),
		.b(32'd0),
		.cin(1'b1),
		.sum(neg_rs2_sum)
	);
	assign rs1_abs = (rs1_neg ? neg_rs1_sum : rs1_data);
	assign rs2_abs = (rs2_neg ? neg_rs2_sum : rs2_data);
	wire [31:0] div_quot_abs;
	wire [31:0] div_rem_abs;
	DividerUnsigned sdiv_abs(
		.i_dividend(rs1_abs),
		.i_divisor(rs2_abs),
		.o_quotient(div_quot_abs),
		.o_remainder(div_rem_abs)
	);
	wire [31:0] divu_quot;
	wire [31:0] divu_rem;
	DividerUnsigned udiv(
		.i_dividend(rs1_data),
		.i_divisor(rs2_data),
		.o_quotient(divu_quot),
		.o_remainder(divu_rem)
	);
	wire quot_neg;
	assign quot_neg = rs1_neg ^ rs2_neg;
	wire [31:0] quot_signed;
	wire [31:0] rem_signed;
	wire [31:0] neg_quot_sum;
	wire [31:0] neg_rem_sum;
	CarryLookaheadAdder negq(
		.a(~div_quot_abs),
		.b(32'd0),
		.cin(1'b1),
		.sum(neg_quot_sum)
	);
	CarryLookaheadAdder negr(
		.a(~div_rem_abs),
		.b(32'd0),
		.cin(1'b1),
		.sum(neg_rem_sum)
	);
	assign quot_signed = (quot_neg ? neg_quot_sum : div_quot_abs);
	assign rem_signed = (rs1_neg ? neg_rem_sum : div_rem_abs);
	reg signed [63:0] rs1_sext64;
	reg signed [63:0] rs2_sext64;
	reg [63:0] rs1_zext64;
	reg [63:0] rs2_zext64;
	always @(*) begin
		if (_sv2v_0)
			;
		rs1_sext64 = {{32 {rs1_data[31]}}, rs1_data};
		rs2_sext64 = {{32 {rs2_data[31]}}, rs2_data};
		rs1_zext64 = {32'd0, rs1_data};
		rs2_zext64 = {32'd0, rs2_data};
	end
	reg signed [63:0] prod_ss;
	reg signed [63:0] prod_su;
	reg [63:0] prod_uu;
	always @(*) begin
		if (_sv2v_0)
			;
		prod_ss = rs1_sext64 * rs2_sext64;
		prod_su = rs1_sext64 * $signed(rs2_zext64);
		prod_uu = rs1_zext64 * rs2_zext64;
	end
	wire rs2_is_zero;
	wire signed_overflow_div;
	assign rs2_is_zero = rs2_data == 32'd0;
	assign signed_overflow_div = ($signed(rs1_data) == 32'sh80000000) && ($signed(rs2_data) == 32'shffffffff);
	always @(*) begin
		if (_sv2v_0)
			;
		illegal_insn = 1'b0;
		write = 1'b0;
		rd_data = 1'sb0;
		a = 1'sb0;
		b = 1'sb0;
		halt = 1'b0;
		cin = 1'b0;
		pcNext = pcCurrent + 32'd4;
		addr_to_dmem = 32'd0;
		store_data_to_dmem = 32'd0;
		store_we_to_dmem = 4'b0000;
		byte_off = 2'b00;
		byte_off_s = 2'b00;
		word = 32'd0;
		trace_completed_pc = pcCurrent;
		trace_completed_insn = insn_from_imem;
		trace_completed_cycle_status = 32'd1;
		case (insn_opcode)
			OpLoad: begin
				a = rs1_data;
				b = imm_i_sext;
				addr_to_dmem = temp_sum;
				byte_off = addr_to_dmem[1:0];
				word = load_data_from_dmem;
				if (insn_lw) begin
					write = 1'b1;
					rd_data = word;
				end
				else if (insn_lb) begin
					write = 1'b1;
					(* full_case, parallel_case *)
					case (byte_off)
						2'd0: rd_data = {{24 {word[7]}}, word[7:0]};
						2'd1: rd_data = {{24 {word[15]}}, word[15:8]};
						2'd2: rd_data = {{24 {word[23]}}, word[23:16]};
						2'd3: rd_data = {{24 {word[31]}}, word[31:24]};
					endcase
				end
				else if (insn_lbu) begin
					write = 1'b1;
					(* full_case, parallel_case *)
					case (byte_off)
						2'd0: rd_data = {24'd0, word[7:0]};
						2'd1: rd_data = {24'd0, word[15:8]};
						2'd2: rd_data = {24'd0, word[23:16]};
						2'd3: rd_data = {24'd0, word[31:24]};
					endcase
				end
				else if (insn_lh) begin
					write = 1'b1;
					if (byte_off[1] == 1'b0)
						rd_data = {{16 {word[15]}}, word[15:0]};
					else
						rd_data = {{16 {word[31]}}, word[31:16]};
				end
				else if (insn_lhu) begin
					write = 1'b1;
					if (byte_off[1] == 1'b0)
						rd_data = {16'd0, word[15:0]};
					else
						rd_data = {16'd0, word[31:16]};
				end
				else
					illegal_insn = 1'b1;
			end
			OpStore: begin
				a = rs1_data;
				b = imm_s_sext;
				addr_to_dmem = temp_sum;
				byte_off_s = addr_to_dmem[1:0];
				if (insn_sw) begin
					store_data_to_dmem = rs2_data;
					store_we_to_dmem = 4'b1111;
				end
				else if (insn_sb) begin
					store_data_to_dmem = {4 {rs2_data[7:0]}};
					(* full_case, parallel_case *)
					case (byte_off_s)
						2'd0: store_we_to_dmem = 4'b0001;
						2'd1: store_we_to_dmem = 4'b0010;
						2'd2: store_we_to_dmem = 4'b0100;
						2'd3: store_we_to_dmem = 4'b1000;
					endcase
				end
				else if (insn_sh) begin
					store_data_to_dmem = {2 {rs2_data[15:0]}};
					if (byte_off_s[1] == 1'b0)
						store_we_to_dmem = 4'b0011;
					else
						store_we_to_dmem = 4'b1100;
				end
				else
					illegal_insn = 1'b1;
			end
			OpAuipc: begin
				write = 1'b1;
				a = pcCurrent;
				b = {insn_from_imem[31:12], 12'b000000000000};
				rd_data = temp_sum;
			end
			OpJal: begin
				write = 1'b1;
				rd_data = pcCurrent + 32'd4;
				pcNext = pcCurrent + imm_j_sext;
			end
			OpJalr: begin
				write = 1'b1;
				rd_data = pcCurrent + 32'd4;
				a = rs1_data;
				b = imm_i_sext;
				pcNext = temp_sum & 32'hfffffffe;
			end
			OpLui: begin
				write = 1'd1;
				rd_data = insn_from_imem[31:12] << 12;
				pcNext = pcCurrent + 4;
			end
			OpRegImm:
				if (insn_addi) begin
					write = 1'd1;
					a = rs1_data;
					b = imm_i_sext;
					rd_data = temp_sum;
					pcNext = pcCurrent + 4;
				end
				else if (insn_slti) begin
					write = 1'd1;
					if ($signed(rs1_data) < $signed(imm_i_sext))
						rd_data = 1;
					else
						rd_data = 1'sb0;
					pcNext = pcCurrent + 4;
				end
				else if (insn_sltiu) begin
					write = 1'd1;
					if (rs1_data < imm_i_sext)
						rd_data = 1;
					else
						rd_data = 1'sb0;
					pcNext = pcCurrent + 4;
				end
				else if (insn_andi) begin
					write = 1'd1;
					rd_data = rs1_data & imm_i_sext;
					pcNext = pcCurrent + 4;
				end
				else if (insn_slli) begin
					write = 1'd1;
					rd_data = rs1_data << insn_from_imem[24:20];
					pcNext = pcCurrent + 4;
				end
				else if (insn_srli) begin
					write = 1'd1;
					rd_data = rs1_data >> insn_from_imem[24:20];
					pcNext = pcCurrent + 4;
				end
				else if (insn_srai) begin
					write = 1'd1;
					rd_data = $signed(rs1_data) >>> $signed(insn_from_imem[24:20]);
					pcNext = pcCurrent + 4;
				end
				else if (insn_ori) begin
					write = 1'd1;
					rd_data = rs1_data | imm_i_sext;
					pcNext = pcCurrent + 4;
				end
				else if (insn_xori) begin
					write = 1'd1;
					rd_data = rs1_data ^ imm_i_sext;
					pcNext = pcCurrent + 4;
				end
				else
					pcNext = pcCurrent + 4;
			OpBranch:
				if (insn_bne) begin
					if (rs1_data != rs2_data)
						pcNext = pcCurrent + imm_b_sext;
					else
						pcNext = pcCurrent + 4;
				end
				else if (insn_beq) begin
					if (rs1_data == rs2_data)
						pcNext = pcCurrent + imm_b_sext;
					else
						pcNext = pcCurrent + 4;
				end
				else if (insn_blt) begin
					if ($signed(rs1_data) < $signed(rs2_data))
						pcNext = pcCurrent + imm_b_sext;
					else
						pcNext = pcCurrent + 4;
				end
				else if (insn_bltu) begin
					if (rs1_data < rs2_data)
						pcNext = pcCurrent + imm_b_sext;
					else
						pcNext = pcCurrent + 4;
				end
				else if (insn_bge) begin
					if ($signed(rs1_data) >= $signed(rs2_data))
						pcNext = pcCurrent + imm_b_sext;
					else
						pcNext = pcCurrent + 4;
				end
				else if (insn_bgeu) begin
					if (rs1_data >= rs2_data)
						pcNext = pcCurrent + imm_b_sext;
					else
						pcNext = pcCurrent + 4;
				end
				else
					pcNext = pcCurrent + 4;
			OpEnviron:
				if (insn_ecall)
					halt = 1'b1;
				else
					illegal_insn = 1'b1;
			OpRegReg:
				if (insn_add) begin
					write = 1'd1;
					a = rs1_data;
					b = rs2_data;
					rd_data = temp_sum;
					pcNext = pcCurrent + 4;
				end
				else if (insn_slt) begin
					write = 1'd1;
					if ($signed(rs1_data) < $signed(rs2_data))
						rd_data = 1;
					else
						rd_data = 1'sb0;
					pcNext = pcCurrent + 4;
				end
				else if (insn_sltu) begin
					write = 1'd1;
					if (rs1_data < rs2_data)
						rd_data = 1;
					else
						rd_data = 1'sb0;
					pcNext = pcCurrent + 4;
				end
				else if (insn_sub) begin
					write = 1'b1;
					a = rs1_data;
					b = ~rs2_data;
					cin = 1'b1;
					rd_data = temp_sum;
					pcNext = pcCurrent + 4;
				end
				else if (insn_and) begin
					write = 1'd1;
					rd_data = rs1_data & rs2_data;
					pcNext = pcCurrent + 4;
				end
				else if (insn_sll) begin
					write = 1'd1;
					rd_data = rs1_data << rs2_data[4:0];
					pcNext = pcCurrent + 4;
				end
				else if (insn_srl) begin
					write = 1'd1;
					rd_data = rs1_data >> rs2_data[4:0];
					pcNext = pcCurrent + 4;
				end
				else if (insn_sra) begin
					write = 1'd1;
					rd_data = $signed(rs1_data) >>> $signed(rs2_data[4:0]);
					pcNext = pcCurrent + 4;
				end
				else if (insn_or) begin
					write = 1'd1;
					rd_data = rs1_data | rs2_data;
					pcNext = pcCurrent + 4;
				end
				else if (insn_xor) begin
					write = 1'd1;
					rd_data = rs1_data ^ rs2_data;
					pcNext = pcCurrent + 4;
				end
				else if (insn_mul) begin
					write = 1'b1;
					rd_data = prod_ss[31:0];
					pcNext = pcCurrent + 4;
				end
				else if (insn_mulh) begin
					write = 1'b1;
					rd_data = prod_ss[63:32];
					pcNext = pcCurrent + 4;
				end
				else if (insn_mulhsu) begin
					write = 1'b1;
					rd_data = prod_su[63:32];
					pcNext = pcCurrent + 4;
				end
				else if (insn_mulhu) begin
					write = 1'b1;
					rd_data = prod_uu[63:32];
					pcNext = pcCurrent + 4;
				end
				else if (insn_divu) begin
					write = 1'b1;
					rd_data = (rs2_is_zero ? 32'hffffffff : divu_quot);
					pcNext = pcCurrent + 4;
				end
				else if (insn_remu) begin
					write = 1'b1;
					rd_data = (rs2_is_zero ? rs1_data : divu_rem);
					pcNext = pcCurrent + 4;
				end
				else if (insn_div) begin
					write = 1'b1;
					if (rs2_is_zero)
						rd_data = 32'hffffffff;
					else if (signed_overflow_div)
						rd_data = 32'h80000000;
					else
						rd_data = quot_signed;
					pcNext = pcCurrent + 4;
				end
				else if (insn_rem) begin
					write = 1'b1;
					if (rs2_is_zero)
						rd_data = rs1_data;
					else if (signed_overflow_div)
						rd_data = 32'd0;
					else
						rd_data = rem_signed;
					pcNext = pcCurrent + 4;
				end
				else
					pcNext = pcCurrent + 4;
			OpMiscMem: pcNext = pcCurrent + 4;
			default: begin
				illegal_insn = 1'b1;
				pcNext = pcCurrent + 4;
			end
		endcase
		if (illegal_insn) begin
			write = 1'b0;
			store_we_to_dmem = 4'b0000;
		end
	end
	initial _sv2v_0 = 0;
endmodule
module MemorySingleCycle (
	rst,
	clock_mem,
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
	input wire clock_mem;
	input wire [31:0] pc_to_imem;
	output reg [31:0] insn_from_imem;
	input wire [31:0] addr_to_dmem;
	output reg [31:0] load_data_from_dmem;
	input wire [31:0] store_data_to_dmem;
	input wire [3:0] store_we_to_dmem;
	reg [31:0] mem_array [0:NUM_WORDS - 1];
	initial $readmemh("mem_initial_contents.hex", mem_array);
	wire [31:0] addr_to_dmem_aligned = {addr_to_dmem[31:2], 2'b00};
	always @(*)
		if (_sv2v_0)
			;
	localparam signed [31:0] AddrMsb = $clog2(NUM_WORDS) + 1;
	localparam signed [31:0] AddrLsb = 2;
	always @(posedge clock_mem)
		if (rst)
			;
		else
			insn_from_imem <= mem_array[{pc_to_imem[AddrMsb:AddrLsb]}];
	always @(negedge clock_mem)
		if (rst)
			;
		else begin
			if (store_we_to_dmem[0])
				mem_array[addr_to_dmem_aligned[AddrMsb:AddrLsb]][7:0] <= store_data_to_dmem[7:0];
			if (store_we_to_dmem[1])
				mem_array[addr_to_dmem_aligned[AddrMsb:AddrLsb]][15:8] <= store_data_to_dmem[15:8];
			if (store_we_to_dmem[2])
				mem_array[addr_to_dmem_aligned[AddrMsb:AddrLsb]][23:16] <= store_data_to_dmem[23:16];
			if (store_we_to_dmem[3])
				mem_array[addr_to_dmem_aligned[AddrMsb:AddrLsb]][31:24] <= store_data_to_dmem[31:24];
			load_data_from_dmem <= mem_array[{addr_to_dmem_aligned[AddrMsb:AddrLsb]}];
		end
	initial _sv2v_0 = 0;
endmodule
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
	wire clk_mem;
	wire clk_locked;
	MyClockGen clock_gen(
		.input_clk_25MHz(external_clk_25MHz),
		.clk_proc(clk_proc),
		.clk_mem(clk_mem),
		.locked(clk_locked)
	);
	wire [31:0] pc_to_imem;
	wire [31:0] insn_from_imem;
	wire [31:0] mem_data_addr;
	wire [31:0] mem_data_loaded_value;
	wire [31:0] mem_data_to_write;
	wire [3:0] mem_data_we;
	MemorySingleCycle #(.NUM_WORDS(128)) memory(
		.rst(!clk_locked),
		.clock_mem(clk_mem),
		.pc_to_imem(pc_to_imem),
		.insn_from_imem(insn_from_imem),
		.addr_to_dmem(mem_data_addr),
		.load_data_from_dmem(mem_data_loaded_value),
		.store_data_to_dmem(mem_data_to_write),
		.store_we_to_dmem(mem_data_we)
	);
	DatapathSingleCycle datapath(
		.clk(clk_proc),
		.rst(!clk_locked),
		.pc_to_imem(pc_to_imem),
		.insn_from_imem(insn_from_imem),
		.addr_to_dmem(mem_data_addr),
		.store_data_to_dmem(mem_data_to_write),
		.store_we_to_dmem(mem_data_we),
		.load_data_from_dmem(mem_data_loaded_value),
		.halt(led[0])
	);
endmodule