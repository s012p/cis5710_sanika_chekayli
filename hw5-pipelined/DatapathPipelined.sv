`timescale 1ns / 1ns

`define REG_SIZE 31:0

`define INSN_SIZE 31:0

`define OPCODE_SIZE 6:0

`ifndef DIVIDER_STAGES
`define DIVIDER_STAGES 8
`endif

`ifndef SYNTHESIS
`include "../hw3-singlecycle/RvDisassembler.sv"
`endif
`include "../hw2b-cla/CarryLookaheadAdder.sv"
`include "../hw4-multicycle/DividerUnsignedPipelined.sv"
`include "../hw3-singlecycle/cycle_status.sv"

module Disasm #(
    byte PREFIX = "D"
) (
    input wire [31:0] insn,
    output wire [(8*32)-1:0] disasm
);
`ifndef SYNTHESIS
  string disasm_string;
  always_comb begin
    disasm_string = rv_disasm(insn);
  end
  genvar i;
  for (i = 3; i < 32; i = i + 1) begin : gen_disasm
    assign disasm[((i+1-3)*8)-1-:8] = disasm_string[31-i];
  end
  assign disasm[255-:8] = PREFIX;
  assign disasm[247-:8] = ":";
  assign disasm[239-:8] = " ";
`endif
endmodule

module RegFile (
    input logic [4:0] rd,
    input logic [`REG_SIZE] rd_data,
    input logic [4:0] rs1,
    output logic [`REG_SIZE] rs1_data,
    input logic [4:0] rs2,
    output logic [`REG_SIZE] rs2_data,

    input logic clk,
    input logic we,
    input logic rst
);
  localparam int NumRegs = 32;
  logic [`REG_SIZE] regs[NumRegs];

  integer idx;
  always_ff @(posedge clk) begin
    if (rst) begin
      for (idx = 0; idx < NumRegs; idx = idx + 1) begin
        regs[idx] <= '0;
      end
    end else begin
      if (we && (rd != 5'd0)) begin
        regs[rd] <= rd_data;
      end
      regs[0] <= '0;
    end
  end

  always_comb begin
    if (rs1 == 5'd0) begin
      rs1_data = 32'd0;
    end else if (we && (rd != 5'd0) && (rd == rs1)) begin
      rs1_data = rd_data;
    end else begin
      rs1_data = regs[rs1];
    end

    if (rs2 == 5'd0) begin
      rs2_data = 32'd0;
    end else if (we && (rd != 5'd0) && (rd == rs2)) begin
      rs2_data = rd_data;
    end else begin
      rs2_data = regs[rs2];
    end
  end

endmodule

typedef struct packed {
  logic [`REG_SIZE] pc;
  logic [`INSN_SIZE] insn;
  cycle_status_e cycle_status;
} stage_decode_t;

typedef struct packed {
  logic [31:0] q;
  logic [31:0] r;
} div_result_t;

typedef struct packed {
  logic valid;
  logic [`REG_SIZE] pc;
  logic [`INSN_SIZE] insn;
  cycle_status_e cycle_status;
  logic [4:0] rd;
  logic reg_write;
  logic [`REG_SIZE] result;
} div_pipe_t;

module DatapathPipelined (
    input wire clk,
    input wire rst,
    output logic [`REG_SIZE] pc_to_imem,
    input wire [`INSN_SIZE] insn_from_imem,
    output logic [`REG_SIZE] addr_to_dmem,
    input wire [`REG_SIZE] load_data_from_dmem,
    output logic [`REG_SIZE] store_data_to_dmem,
    output logic [3:0] store_we_to_dmem,

    output logic halt,
    output logic [`REG_SIZE] trace_completed_pc,
    output logic [`INSN_SIZE] trace_completed_insn,
    output cycle_status_e trace_completed_cycle_status
);
  localparam bit [`OPCODE_SIZE] OpcodeLoad    = 7'b00_000_11;
  localparam bit [`OPCODE_SIZE] OpcodeStore   = 7'b01_000_11;
  localparam bit [`OPCODE_SIZE] OpcodeBranch  = 7'b11_000_11;
  localparam bit [`OPCODE_SIZE] OpcodeJalr    = 7'b11_001_11;
  localparam bit [`OPCODE_SIZE] OpcodeJal     = 7'b11_011_11;
  localparam bit [`OPCODE_SIZE] OpcodeRegImm  = 7'b00_100_11;
  localparam bit [`OPCODE_SIZE] OpcodeRegReg  = 7'b01_100_11;
  localparam bit [`OPCODE_SIZE] OpcodeEnviron = 7'b11_100_11;
  localparam bit [`OPCODE_SIZE] OpcodeAuipc   = 7'b00_101_11;
  localparam bit [`OPCODE_SIZE] OpcodeLui     = 7'b01_101_11;

  localparam logic [3:0] ALU_ADD        = 4'd0;
  localparam logic [3:0] ALU_SUB        = 4'd1;
  localparam logic [3:0] ALU_AND        = 4'd2;
  localparam logic [3:0] ALU_OR         = 4'd3;
  localparam logic [3:0] ALU_XOR        = 4'd4;
  localparam logic [3:0] ALU_SLT        = 4'd5;
  localparam logic [3:0] ALU_SLTU       = 4'd6;
  localparam logic [3:0] ALU_SLL        = 4'd7;
  localparam logic [3:0] ALU_SRL        = 4'd8;
  localparam logic [3:0] ALU_SRA        = 4'd9;
  localparam logic [3:0] ALU_COPY_B     = 4'd10;
  localparam logic [3:0] ALU_ADD_PC_IMM = 4'd11;

  localparam logic [1:0] MUL_LO    = 2'd0;
  localparam logic [1:0] MUL_HI_SS = 2'd1;
  localparam logic [1:0] MUL_HI_SU = 2'd2;
  localparam logic [1:0] MUL_HI_UU = 2'd3;

  typedef struct packed {
    logic [`REG_SIZE] pc;
    logic [`INSN_SIZE] insn;
    cycle_status_e cycle_status;

    logic [4:0] rd;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic reg_write;
    logic is_branch;
    logic is_jump;
    logic is_jalr;
    logic is_halt;
    logic is_load;
    logic is_store;
    logic is_mul;
    logic waits_for_div;

    logic [2:0] funct3;
    logic [3:0] alu_op;
    logic [1:0] mul_op;
    logic use_imm;

    logic [`REG_SIZE] rs1_val;
    logic [`REG_SIZE] rs2_val;
    logic [`REG_SIZE] imm;
  } stage_execute_t;

  typedef struct packed {
    logic [`REG_SIZE] pc;
    logic [`INSN_SIZE] insn;
    cycle_status_e cycle_status;

    logic [4:0] rd;
    logic [4:0] rs2;
    logic reg_write;
    logic is_halt;
    logic is_load;
    logic is_store;
    logic waits_for_div;
    logic [2:0] funct3;

    logic [`REG_SIZE] addr;
    logic [`REG_SIZE] result;
    logic [`REG_SIZE] store_data;
  } stage_memory_t;

  typedef struct packed {
    logic [`REG_SIZE] pc;
    logic [`INSN_SIZE] insn;
    cycle_status_e cycle_status;

    logic [4:0] rd;
    logic reg_write;
    logic is_halt;

    logic [`REG_SIZE] result;
  } stage_writeback_t;

  logic [`REG_SIZE] cycles_current;
  always_ff @(posedge clk) begin
    if (rst) begin
      cycles_current <= 0;
    end else begin
      cycles_current <= cycles_current + 1;
    end
  end

  logic [`REG_SIZE] f_pc_current;
  wire [`REG_SIZE] f_insn;
  cycle_status_e f_cycle_status;
  assign pc_to_imem = f_pc_current;
  assign f_insn = insn_from_imem;

  wire [255:0] f_disasm;
  Disasm #(.PREFIX("F")) disasm_0fetch (.insn(f_insn), .disasm(f_disasm));

  stage_decode_t decode_state;
  wire [255:0] d_disasm;
  Disasm #(.PREFIX("D")) disasm_1decode (.insn(decode_state.insn), .disasm(d_disasm));

  stage_execute_t x_state;
  stage_memory_t  m_state;
  stage_writeback_t w_state;
  div_pipe_t div_pipe[`DIVIDER_STAGES];
  integer div_idx;

  wire [255:0] x_disasm;
  Disasm #(.PREFIX("X")) disasm_2execute (.insn(x_state.insn), .disasm(x_disasm));
  wire [255:0] m_disasm;
  Disasm #(.PREFIX("M")) disasm_3memory (.insn(m_state.insn), .disasm(m_disasm));
  wire [255:0] w_disasm;
  Disasm #(.PREFIX("W")) disasm_4writeback (.insn(w_state.insn), .disasm(w_disasm));

  // div_pipe completion signals accessed directly via div_pipe[`DIVIDER_STAGES-1]
  logic div_any_inflight;

  function automatic div_result_t do_divu(
      input logic [31:0] dividend,
      input logic [31:0] divisor
  );
`ifdef SYNTHESIS
    begin
      do_divu.q = (divisor == 32'd0) ? 32'hFFFF_FFFF : 32'd0;
      do_divu.r = (divisor == 32'd0) ? dividend : 32'd0;
    end
`else
    div_result_t out;
    logic [31:0] q;
    logic [31:0] r;
    logic [63:0] rem_ext;
    integer i;
    begin
      q = 32'd0;
      r = 32'd0;
      rem_ext = 64'd0;
      if (divisor == 32'd0) begin
        out.q = 32'hFFFF_FFFF;
        out.r = dividend;
      end else begin
        for (i = 31; i >= 0; i = i - 1) begin
          rem_ext = {rem_ext[62:0], dividend[i]};
          if (rem_ext[31:0] >= divisor) begin
            rem_ext[31:0] = rem_ext[31:0] - divisor;
            q[i] = 1'b1;
          end else begin
            q[i] = 1'b0;
          end
        end
        r = rem_ext[31:0];
        out.q = q;
        out.r = r;
      end
      do_divu = out;
    end
`endif
  endfunction

  function automatic div_result_t do_div_signed(
      input logic [31:0] a,
      input logic [31:0] b
  );
`ifdef SYNTHESIS
    begin
      if (b == 32'd0) begin
        do_div_signed.q = 32'hFFFF_FFFF;
        do_div_signed.r = a;
      end else if ((a == 32'h8000_0000) && (b == 32'hFFFF_FFFF)) begin
        do_div_signed.q = 32'h8000_0000;
        do_div_signed.r = 32'd0;
      end else begin
        do_div_signed.q = 32'd0;
        do_div_signed.r = 32'd0;
      end
    end
`else
    div_result_t out;
    div_result_t mag;
    logic a_neg;
    logic b_neg;
    logic [31:0] a_abs;
    logic [31:0] b_abs;
    begin
      if (b == 32'd0) begin
        out.q = 32'hFFFF_FFFF;
        out.r = a;
      end else if ((a == 32'h8000_0000) && (b == 32'hFFFF_FFFF)) begin
        out.q = 32'h8000_0000;
        out.r = 32'd0;
      end else begin
        a_neg = a[31];
        b_neg = b[31];
        a_abs = a_neg ? (~a + 32'd1) : a;
        b_abs = b_neg ? (~b + 32'd1) : b;
        mag = do_divu(a_abs, b_abs);
        out.q = (a_neg ^ b_neg) ? (~mag.q + 32'd1) : mag.q;
        out.r = a_neg ? (~mag.r + 32'd1) : mag.r;
      end
      do_div_signed = out;
    end
`endif
  endfunction

  logic [`OPCODE_SIZE] d_opcode;
  logic [4:0] d_rs1, d_rs2, d_rd;
  logic [2:0] d_funct3;
  logic [6:0] d_funct7;
  logic [`REG_SIZE] d_imm_i, d_imm_s, d_imm_u, d_imm_b, d_imm_j;

  assign d_opcode = decode_state.insn[6:0];
  assign d_rd     = decode_state.insn[11:7];
  assign d_funct3 = decode_state.insn[14:12];
  assign d_rs1    = decode_state.insn[19:15];
  assign d_rs2    = decode_state.insn[24:20];
  assign d_funct7 = decode_state.insn[31:25];

  assign d_imm_i = {{20{decode_state.insn[31]}}, decode_state.insn[31:20]};
  assign d_imm_s = {{20{decode_state.insn[31]}}, decode_state.insn[31:25], decode_state.insn[11:7]};
  assign d_imm_u = {decode_state.insn[31:12], 12'b0};
  assign d_imm_b = {{19{decode_state.insn[31]}}, decode_state.insn[31], decode_state.insn[7], decode_state.insn[30:25], decode_state.insn[11:8], 1'b0};
  assign d_imm_j = {{11{decode_state.insn[31]}}, decode_state.insn[31], decode_state.insn[19:12], decode_state.insn[20], decode_state.insn[30:21], 1'b0};

  logic d_is_lui, d_is_auipc, d_is_regimm, d_is_regreg;
  logic d_is_branch, d_is_jal, d_is_jalr, d_is_env;
  logic d_is_load, d_is_store;
  logic d_is_mul, d_is_div, d_is_rem;
  logic d_uses_rs1, d_uses_rs2;

  assign d_is_lui    = (d_opcode == OpcodeLui);
  assign d_is_auipc  = (d_opcode == OpcodeAuipc);
  assign d_is_regimm = (d_opcode == OpcodeRegImm);
  assign d_is_regreg = (d_opcode == OpcodeRegReg);
  assign d_is_branch = (d_opcode == OpcodeBranch);
  assign d_is_jal    = (d_opcode == OpcodeJal);
  assign d_is_jalr   = (d_opcode == OpcodeJalr);
  assign d_is_env    = (d_opcode == OpcodeEnviron);
  assign d_is_load   = (d_opcode == OpcodeLoad);
  assign d_is_store  = (d_opcode == OpcodeStore);

  assign d_is_mul = d_is_regreg && (d_funct7 == 7'b0000001) && (d_funct3[2] == 1'b0);
  assign d_is_div = d_is_regreg && (d_funct7 == 7'b0000001) && (d_funct3[2:1] == 2'b10);
  assign d_is_rem = d_is_regreg && (d_funct7 == 7'b0000001) && (d_funct3[2:1] == 2'b11);

  always_comb begin
    d_uses_rs1 = 1'b0;
    d_uses_rs2 = 1'b0;
    if (d_is_regimm || d_is_load || d_is_jalr) begin
      d_uses_rs1 = 1'b1;
    end else if (d_is_regreg || d_is_branch || d_is_store) begin
      d_uses_rs1 = 1'b1;
      d_uses_rs2 = 1'b1;
    end
  end

  logic [`REG_SIZE] rf_rs1_data, rf_rs2_data;
  RegFile rf (
      .rd      (w_state.rd),
      .rd_data (w_state.result),
      .rs1     (d_rs1),
      .rs1_data(rf_rs1_data),
      .rs2     (d_rs2),
      .rs2_data(rf_rs2_data),
      .clk     (clk),
      .we      (w_state.reg_write),
      .rst     (rst)
  );

  logic [`REG_SIZE] m_result_bypass;
  logic [`REG_SIZE] d_rs1_bypassed, d_rs2_bypassed;
  logic [`REG_SIZE] x_result;

  always_comb begin
    d_rs1_bypassed = rf_rs1_data;
    d_rs2_bypassed = rf_rs2_data;

    if (x_state.reg_write && !x_state.is_load && (x_state.rd != 5'd0) && (x_state.rd == d_rs1)) begin
      d_rs1_bypassed = x_result;
    end else if (m_state.reg_write && (m_state.rd != 5'd0) && (m_state.rd == d_rs1)) begin
      d_rs1_bypassed = m_result_bypass;
    end else if (w_state.reg_write && (w_state.rd != 5'd0) && (w_state.rd == d_rs1)) begin
      d_rs1_bypassed = w_state.result;
    end

    if (x_state.reg_write && !x_state.is_load && (x_state.rd != 5'd0) && (x_state.rd == d_rs2)) begin
      d_rs2_bypassed = x_result;
    end else if (m_state.reg_write && (m_state.rd != 5'd0) && (m_state.rd == d_rs2)) begin
      d_rs2_bypassed = m_result_bypass;
    end else if (w_state.reg_write && (w_state.rd != 5'd0) && (w_state.rd == d_rs2)) begin
      d_rs2_bypassed = w_state.result;
    end
  end

  stage_execute_t x_state_next;
  always_comb begin
    x_state_next = '{
        pc: 32'd0,
        insn: 32'd0,
        cycle_status: decode_state.cycle_status,
        rd: 5'd0,
        rs1: d_rs1,
        rs2: d_rs2,
        reg_write: 1'b0,
        is_branch: 1'b0,
        is_jump: 1'b0,
        is_jalr: 1'b0,
        is_halt: 1'b0,
        is_load: 1'b0,
        is_store: 1'b0,
        is_mul: 1'b0,
        waits_for_div: div_any_inflight,
        funct3: 3'd0,
        alu_op: ALU_ADD,
        mul_op: MUL_LO,
        use_imm: 1'b0,
        rs1_val: d_rs1_bypassed,
        rs2_val: d_rs2_bypassed,
        imm: 32'd0
    };

    if (decode_state.insn == 32'd0) begin
      x_state_next = '{
        pc: 32'd0,
        insn: 32'd0,
        cycle_status: decode_state.cycle_status,
        rd: 5'd0,
        rs1: 5'd0,
        rs2: 5'd0,
        reg_write: 1'b0,
        is_branch: 1'b0,
        is_jump: 1'b0,
        is_jalr: 1'b0,
        is_halt: 1'b0,
        is_load: 1'b0,
        is_store: 1'b0,
        is_mul: 1'b0,
        waits_for_div: 1'b0,
        funct3: 3'd0,
        alu_op: ALU_ADD,
        mul_op: MUL_LO,
        use_imm: 1'b0,
        rs1_val: 32'd0,
        rs2_val: 32'd0,
        imm: 32'd0
      };
    end else if (d_is_lui) begin
      x_state_next.pc   = decode_state.pc;
      x_state_next.insn = decode_state.insn;
      x_state_next.rd        = d_rd;
      x_state_next.rs1       = d_rs1;
      x_state_next.reg_write = (d_rd != 5'd0);
      x_state_next.alu_op    = ALU_COPY_B;
      x_state_next.use_imm   = 1'b1;
      x_state_next.imm       = d_imm_u;
    end else if (d_is_auipc) begin
      x_state_next.pc   = decode_state.pc;
      x_state_next.insn = decode_state.insn;
      x_state_next.rd        = d_rd;
      x_state_next.rs1       = d_rs1;
      x_state_next.reg_write = (d_rd != 5'd0);
      x_state_next.alu_op    = ALU_ADD_PC_IMM;
      x_state_next.use_imm   = 1'b1;
      x_state_next.imm       = d_imm_u;
    end else if (d_is_regimm) begin
      x_state_next.pc   = decode_state.pc;
      x_state_next.insn = decode_state.insn;
      x_state_next.rd        = d_rd;
      x_state_next.rs1       = d_rs1;
      x_state_next.reg_write = (d_rd != 5'd0);
      x_state_next.use_imm   = 1'b1;
      x_state_next.imm       = d_imm_i;
      unique case (d_funct3)
        3'b000: x_state_next.alu_op = ALU_ADD;
        3'b010: x_state_next.alu_op = ALU_SLT;
        3'b011: x_state_next.alu_op = ALU_SLTU;
        3'b100: x_state_next.alu_op = ALU_XOR;
        3'b110: x_state_next.alu_op = ALU_OR;
        3'b111: x_state_next.alu_op = ALU_AND;
        3'b001: begin
          x_state_next.alu_op = ALU_SLL;
          x_state_next.imm    = {27'd0, decode_state.insn[24:20]};
        end
        3'b101: begin
          x_state_next.imm = {27'd0, decode_state.insn[24:20]};
          if (decode_state.insn[30]) begin
            x_state_next.alu_op = ALU_SRA;
          end else begin
            x_state_next.alu_op = ALU_SRL;
          end
        end
        default: begin end
      endcase
    end else if (d_is_mul) begin
      x_state_next.pc        = decode_state.pc;
      x_state_next.insn      = decode_state.insn;
      x_state_next.rd        = d_rd;
      x_state_next.rs1       = d_rs1;
      x_state_next.reg_write = (d_rd != 5'd0);
      x_state_next.is_mul    = 1'b1;
      x_state_next.funct3    = d_funct3;
      unique case (d_funct3)
        3'b000: x_state_next.mul_op = MUL_LO;
        3'b001: x_state_next.mul_op = MUL_HI_SS;
        3'b010: x_state_next.mul_op = MUL_HI_SU;
        3'b011: x_state_next.mul_op = MUL_HI_UU;
        default: x_state_next.mul_op = MUL_LO;
      endcase
    end else if (d_is_regreg && !d_is_div && !d_is_rem) begin
      x_state_next.pc   = decode_state.pc;
      x_state_next.insn = decode_state.insn;
      x_state_next.rd        = d_rd;
      x_state_next.rs1       = d_rs1;
      x_state_next.reg_write = (d_rd != 5'd0);
      unique case (d_funct3)
        3'b000: begin
          if (d_funct7[5]) x_state_next.alu_op = ALU_SUB;
          else             x_state_next.alu_op = ALU_ADD;
        end
        3'b001: x_state_next.alu_op = ALU_SLL;
        3'b010: x_state_next.alu_op = ALU_SLT;
        3'b011: x_state_next.alu_op = ALU_SLTU;
        3'b100: x_state_next.alu_op = ALU_XOR;
        3'b101: begin
          if (d_funct7[5]) x_state_next.alu_op = ALU_SRA;
          else             x_state_next.alu_op = ALU_SRL;
        end
        3'b110: x_state_next.alu_op = ALU_OR;
        3'b111: x_state_next.alu_op = ALU_AND;
        default: begin end
      endcase
    end else if (d_is_load) begin
      x_state_next.pc        = decode_state.pc;
      x_state_next.insn      = decode_state.insn;
      x_state_next.rd        = d_rd;
      x_state_next.rs1       = d_rs1;
      x_state_next.reg_write = (d_rd != 5'd0);
      x_state_next.is_load   = 1'b1;
      x_state_next.funct3    = d_funct3;
      x_state_next.use_imm   = 1'b1;
      x_state_next.imm       = d_imm_i;
      x_state_next.alu_op    = ALU_ADD;
    end else if (d_is_store) begin
      x_state_next.pc      = decode_state.pc;
      x_state_next.insn    = decode_state.insn;
      x_state_next.rs1     = d_rs1;
      x_state_next.rs2     = d_rs2;
      x_state_next.is_store = 1'b1;
      x_state_next.funct3   = d_funct3;
      x_state_next.use_imm  = 1'b1;
      x_state_next.imm      = d_imm_s;
      x_state_next.alu_op   = ALU_ADD;
    end else if (d_is_branch) begin
      x_state_next.pc        = decode_state.pc;
      x_state_next.insn      = decode_state.insn;
      x_state_next.rs1       = d_rs1;
      x_state_next.rs2       = d_rs2;
      x_state_next.is_branch = 1'b1;
      x_state_next.imm       = d_imm_b;
      x_state_next.funct3    = d_funct3;
    end else if (d_is_jal) begin
      x_state_next.pc        = decode_state.pc;
      x_state_next.insn      = decode_state.insn;
      x_state_next.rd        = d_rd;
      x_state_next.rs1       = d_rs1;
      x_state_next.reg_write = (d_rd != 5'd0);
      x_state_next.is_jump   = 1'b1;
      x_state_next.imm       = d_imm_j;
    end else if (d_is_jalr) begin
      x_state_next.pc        = decode_state.pc;
      x_state_next.insn      = decode_state.insn;
      x_state_next.rd        = d_rd;
      x_state_next.rs1       = d_rs1;
      x_state_next.reg_write = (d_rd != 5'd0);
      x_state_next.is_jalr   = 1'b1;
      x_state_next.use_imm   = 1'b1;
      x_state_next.imm       = d_imm_i;
    end else if (d_is_env) begin
      if ((decode_state.insn[31:20] == 12'd0) && (d_rs1 == 5'd0) && (d_funct3 == 3'd0) && (d_rd == 5'd0)) begin
        x_state_next.pc   = decode_state.pc;
        x_state_next.insn = decode_state.insn;
        x_state_next.is_halt = 1'b1;
      end
    end
  end

  logic [`REG_SIZE] x_rs1_eff, x_rs2_eff;
  logic [`REG_SIZE] x_operand_b;
  logic x_branch_taken;
  logic [`REG_SIZE] x_branch_target;
  logic [`REG_SIZE] x_jump_target;
  logic [`REG_SIZE] x_jalr_target;
  logic signed [63:0] x_prod_ss;
  logic signed [63:0] x_prod_su;
  logic [63:0] x_prod_uu;

  always_comb begin
    x_rs1_eff = x_state.rs1_val;
    x_rs2_eff = x_state.rs2_val;

    if (m_state.reg_write && !m_state.is_load && (m_state.rd != 5'd0) && (m_state.rd == x_state.rs1)) begin
      x_rs1_eff = m_state.result;
    end else if (w_state.reg_write && (w_state.rd != 5'd0) && (w_state.rd == x_state.rs1)) begin
      x_rs1_eff = w_state.result;
    end

    if (m_state.reg_write && !m_state.is_load && (m_state.rd != 5'd0) && (m_state.rd == x_state.rs2)) begin
      x_rs2_eff = m_state.result;
    end else if (w_state.reg_write && (w_state.rd != 5'd0) && (w_state.rd == x_state.rs2)) begin
      x_rs2_eff = w_state.result;
    end
  end

  assign x_operand_b     = x_state.use_imm ? x_state.imm : x_rs2_eff;
  assign x_branch_target = x_state.pc + x_state.imm;
  assign x_jump_target   = x_state.pc + x_state.imm;
  assign x_jalr_target   = (x_rs1_eff + x_state.imm) & 32'hFFFF_FFFE;
  assign x_prod_ss       = $signed(x_rs1_eff) * $signed(x_rs2_eff);
  assign x_prod_su       = $signed(x_rs1_eff) * $signed({1'b0, x_rs2_eff});
  assign x_prod_uu       = x_rs1_eff * x_rs2_eff;

  always_comb begin
    if (x_state.is_jump || x_state.is_jalr) begin
      x_result = x_state.pc + 32'd4;
    end else if (x_state.is_mul) begin
      unique case (x_state.mul_op)
        MUL_LO:    x_result = x_prod_uu[31:0];
        MUL_HI_SS: x_result = x_prod_ss[63:32];
        MUL_HI_SU: x_result = x_prod_su[63:32];
        MUL_HI_UU: x_result = x_prod_uu[63:32];
        default:   x_result = 32'd0;
      endcase
    end else begin
      unique case (x_state.alu_op)
        ALU_ADD:        x_result = x_rs1_eff + x_operand_b;
        ALU_SUB:        x_result = x_rs1_eff - x_operand_b;
        ALU_AND:        x_result = x_rs1_eff & x_operand_b;
        ALU_OR:         x_result = x_rs1_eff | x_operand_b;
        ALU_XOR:        x_result = x_rs1_eff ^ x_operand_b;
        ALU_SLT:        x_result = ($signed(x_rs1_eff) < $signed(x_operand_b)) ? 32'd1 : 32'd0;
        ALU_SLTU:       x_result = (x_rs1_eff < x_operand_b) ? 32'd1 : 32'd0;
        ALU_SLL:        x_result = x_rs1_eff << x_operand_b[4:0];
        ALU_SRL:        x_result = x_rs1_eff >> x_operand_b[4:0];
        ALU_SRA:        x_result = $signed(x_rs1_eff) >>> x_operand_b[4:0];
        ALU_ADD_PC_IMM: x_result = x_state.pc + x_state.imm;
        ALU_COPY_B:     x_result = x_operand_b;
        default:        x_result = 32'd0;
      endcase
    end
  end

  always_comb begin
    x_branch_taken = 1'b0;
    if (x_state.is_branch) begin
      unique case (x_state.funct3)
        3'b000: x_branch_taken = (x_rs1_eff == x_rs2_eff);
        3'b001: x_branch_taken = (x_rs1_eff != x_rs2_eff);
        3'b100: x_branch_taken = ($signed(x_rs1_eff) <  $signed(x_rs2_eff));
        3'b101: x_branch_taken = ($signed(x_rs1_eff) >= $signed(x_rs2_eff));
        3'b110: x_branch_taken = (x_rs1_eff <  x_rs2_eff);
        3'b111: x_branch_taken = (x_rs1_eff >= x_rs2_eff);
        default: x_branch_taken = 1'b0;
      endcase
    end
  end

  logic [`REG_SIZE] m_addr_aligned;
  logic [1:0] m_byte_off;
  logic [`REG_SIZE] m_store_data_bypassed;
  logic [`REG_SIZE] m_load_result;
  logic [3:0] m_store_we;
  logic [`REG_SIZE] m_store_data_shifted;

  assign m_addr_aligned = {m_state.addr[31:2], 2'b00};
  assign m_byte_off = m_state.addr[1:0];
  assign m_store_data_bypassed = (m_state.is_store && w_state.reg_write && (w_state.rd != 5'd0) && (w_state.rd == m_state.rs2)) ? w_state.result : m_state.store_data;

  always_comb begin
    m_store_we = 4'b0000;
    m_store_data_shifted = 32'd0;
    if (m_state.is_store) begin
      unique case (m_state.funct3)
        3'b000: begin
          unique case (m_byte_off)
            2'd0: begin m_store_we = 4'b0001; m_store_data_shifted = {24'd0, m_store_data_bypassed[7:0]}; end
            2'd1: begin m_store_we = 4'b0010; m_store_data_shifted = {16'd0, m_store_data_bypassed[7:0], 8'd0}; end
            2'd2: begin m_store_we = 4'b0100; m_store_data_shifted = {8'd0, m_store_data_bypassed[7:0], 16'd0}; end
            2'd3: begin m_store_we = 4'b1000; m_store_data_shifted = {m_store_data_bypassed[7:0], 24'd0}; end
          endcase
        end
        3'b001: begin
          if (m_byte_off[1] == 1'b0) begin
            m_store_we = m_byte_off[0] ? 4'b0110 : 4'b0011;
            m_store_data_shifted = m_byte_off[0] ? {8'd0, m_store_data_bypassed[15:0], 8'd0} : {16'd0, m_store_data_bypassed[15:0]};
          end else begin
            m_store_we = 4'b1100;
            m_store_data_shifted = {m_store_data_bypassed[15:0], 16'd0};
          end
        end
        3'b010: begin
          m_store_we = 4'b1111;
          m_store_data_shifted = m_store_data_bypassed;
        end
        default: begin end
      endcase
    end
  end

  always_comb begin
    m_load_result = m_state.result;
    if (m_state.is_load) begin
      unique case (m_state.funct3)
        3'b000: begin
          unique case (m_byte_off)
            2'd0: m_load_result = {{24{load_data_from_dmem[7]}}, load_data_from_dmem[7:0]};
            2'd1: m_load_result = {{24{load_data_from_dmem[15]}}, load_data_from_dmem[15:8]};
            2'd2: m_load_result = {{24{load_data_from_dmem[23]}}, load_data_from_dmem[23:16]};
            2'd3: m_load_result = {{24{load_data_from_dmem[31]}}, load_data_from_dmem[31:24]};
          endcase
        end
        3'b001: begin
          unique case (m_byte_off[1])
            1'b0: m_load_result = {{16{load_data_from_dmem[15]}}, load_data_from_dmem[15:0]};
            1'b1: m_load_result = {{16{load_data_from_dmem[31]}}, load_data_from_dmem[31:16]};
          endcase
        end
        3'b010: m_load_result = load_data_from_dmem;
        3'b100: begin
          unique case (m_byte_off)
            2'd0: m_load_result = {24'd0, load_data_from_dmem[7:0]};
            2'd1: m_load_result = {24'd0, load_data_from_dmem[15:8]};
            2'd2: m_load_result = {24'd0, load_data_from_dmem[23:16]};
            2'd3: m_load_result = {24'd0, load_data_from_dmem[31:24]};
          endcase
        end
        3'b101: begin
          unique case (m_byte_off[1])
            1'b0: m_load_result = {16'd0, load_data_from_dmem[15:0]};
            1'b1: m_load_result = {16'd0, load_data_from_dmem[31:16]};
          endcase
        end
        default: m_load_result = load_data_from_dmem;
      endcase
    end
  end

  assign m_result_bypass = m_state.is_load ? m_load_result : m_state.result;
  assign addr_to_dmem = (m_state.is_load || m_state.is_store) ? m_addr_aligned : 32'd0;
  assign store_data_to_dmem = m_store_data_shifted;
  assign store_we_to_dmem = m_store_we;

  assign trace_completed_pc = (w_state.insn == 32'd0) ? 32'd0 : w_state.pc;
  assign trace_completed_insn = (w_state.insn == 32'd0) ? 32'd0 : w_state.insn;
  assign trace_completed_cycle_status = w_state.cycle_status;

  always_ff @(posedge clk) begin
    if (rst) begin
      halt <= 1'b0;
    end else if (m_state.is_halt && (m_state.insn != 32'd0)) begin
      halt <= 1'b1;
    end
  end

  logic load_use_hazard;
  logic div_dep_hazard;
  logic div_issue;
  logic div_pipe_hold;
  logic x_hold_for_div;
  logic hold_front_for_div_insert;
  div_result_t d_div_calc;

  always_comb begin
    load_use_hazard = x_state.is_load && (x_state.rd != 5'd0) &&
                      ((d_uses_rs1 && (d_rs1 == x_state.rd)) ||
                       (d_uses_rs2 && !d_is_store && (d_rs2 == x_state.rd)));

    div_any_inflight = 1'b0;
    div_dep_hazard = 1'b0;
    for (int i = 0; i < `DIVIDER_STAGES; i = i + 1) begin
      if (div_pipe[i].valid) begin
        div_any_inflight = 1'b1;
      end
      if ((d_is_div || d_is_rem) && div_pipe[i].valid && (div_pipe[i].rd != 5'd0) &&
          ((d_uses_rs1 && (d_rs1 == div_pipe[i].rd)) ||
           (d_uses_rs2 && (d_rs2 == div_pipe[i].rd)))) begin
        div_dep_hazard = 1'b1;
      end
    end

    div_issue = (d_is_div || d_is_rem);
    div_pipe_hold = 1'b0;

    x_hold_for_div = (x_state.insn != 32'd0) && x_state.waits_for_div && div_any_inflight;

    hold_front_for_div_insert = div_pipe[`DIVIDER_STAGES-1].valid && (x_state.insn != 32'd0);

    if (d_is_div || d_is_rem) begin
      if (d_funct3[0]) begin
        d_div_calc = do_divu(d_rs1_bypassed, d_rs2_bypassed);
      end else begin
        d_div_calc = do_div_signed(d_rs1_bypassed, d_rs2_bypassed);
      end
    end else begin
      d_div_calc.q = 32'd0;
      d_div_calc.r = 32'd0;
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      f_pc_current   <= 32'd0;
      f_cycle_status <= CYCLE_NO_STALL;

      decode_state <= '{pc: 32'd0, insn: 32'd0, cycle_status: CYCLE_RESET};

      x_state <= '{
        pc: 32'd0,
        insn: 32'd0,
        cycle_status: CYCLE_RESET,
        rd: 5'd0,
        rs1: 5'd0,
        rs2: 5'd0,
        reg_write: 1'b0,
        is_branch: 1'b0,
        is_jump: 1'b0,
        is_jalr: 1'b0,
        is_halt: 1'b0,
        is_load: 1'b0,
        is_store: 1'b0,
        is_mul: 1'b0,
        waits_for_div: 1'b0,
        funct3: 3'd0,
        alu_op: ALU_ADD,
        mul_op: MUL_LO,
        use_imm: 1'b0,
        rs1_val: 32'd0,
        rs2_val: 32'd0,
        imm: 32'd0
      };

      m_state <= '{
        pc: 32'd0,
        insn: 32'd0,
        cycle_status: CYCLE_RESET,
        rd: 5'd0,
        rs2: 5'd0,
        reg_write: 1'b0,
        is_halt: 1'b0,
        is_load: 1'b0,
        is_store: 1'b0,
        waits_for_div: 1'b0,
        funct3: 3'd0,
        addr: 32'd0,
        result: 32'd0,
        store_data: 32'd0
      };

      w_state <= '{
        pc: 32'd0,
        insn: 32'd0,
        cycle_status: CYCLE_RESET,
        rd: 5'd0,
        reg_write: 1'b0,
        is_halt: 1'b0,
        result: 32'd0
      };

      for (div_idx = 0; div_idx < `DIVIDER_STAGES; div_idx = div_idx + 1) begin
        div_pipe[div_idx] <= '{
          valid: 1'b0,
          pc: 32'd0,
          insn: 32'd0,
          cycle_status: CYCLE_RESET,
          rd: 5'd0,
          reg_write: 1'b0,
          result: 32'd0
        };
      end

    end else begin
      if (div_pipe[`DIVIDER_STAGES-1].valid) begin
        w_state <= '{
          pc: m_state.pc,
          insn: m_state.insn,
          cycle_status: m_state.cycle_status,
          rd: m_state.rd,
          reg_write: m_state.reg_write,
          is_halt: m_state.is_halt,
          result: m_result_bypass
        };

        m_state <= '{
          pc: div_pipe[`DIVIDER_STAGES-1].pc,
          insn: div_pipe[`DIVIDER_STAGES-1].insn,
          cycle_status: div_pipe[`DIVIDER_STAGES-1].cycle_status,
          rd: div_pipe[`DIVIDER_STAGES-1].rd,
          rs2: 5'd0,
          reg_write: div_pipe[`DIVIDER_STAGES-1].reg_write,
          is_halt: 1'b0,
          is_load: 1'b0,
          is_store: 1'b0,
          waits_for_div: 1'b0,
          funct3: 3'd0,
          addr: div_pipe[`DIVIDER_STAGES-1].result,
          result: div_pipe[`DIVIDER_STAGES-1].result,
          store_data: 32'd0
        };
      end else begin
        w_state <= '{
          pc: m_state.pc,
          insn: m_state.insn,
          cycle_status: m_state.cycle_status,
          rd: m_state.rd,
          reg_write: m_state.reg_write,
          is_halt: m_state.is_halt,
          result: m_result_bypass
        };

        if (x_hold_for_div || div_pipe_hold) begin
          m_state <= m_state;
        end else begin
          m_state <= '{
            pc: x_state.pc,
            insn: x_state.insn,
            cycle_status: x_state.cycle_status,
            rd: x_state.rd,
            rs2: x_state.rs2,
            reg_write: x_state.reg_write,
            is_halt: x_state.is_halt,
            is_load: x_state.is_load,
            is_store: x_state.is_store,
            waits_for_div: x_state.waits_for_div,
            funct3: x_state.funct3,
            addr: x_result,
            result: x_result,
            store_data: x_rs2_eff
          };
        end
      end

      if (!div_pipe_hold) begin
        for (div_idx = `DIVIDER_STAGES-1; div_idx > 0; div_idx = div_idx - 1) begin
          div_pipe[div_idx] <= div_pipe[div_idx-1];
        end
        div_pipe[0] <= '{
          valid: 1'b0,
          pc: 32'd0,
          insn: 32'd0,
          cycle_status: CYCLE_DIV,
          rd: 5'd0,
          reg_write: 1'b0,
          result: 32'd0
        };
      end else begin
        for (div_idx = `DIVIDER_STAGES-1; div_idx > 0; div_idx = div_idx - 1) begin
          div_pipe[div_idx] <= div_pipe[div_idx];
        end
        div_pipe[0] <= div_pipe[0];
      end

      if (x_branch_taken || x_state.is_jump || x_state.is_jalr) begin
        x_state <= '{
          pc: 32'd0,
          insn: 32'd0,
          cycle_status: CYCLE_TAKEN_BRANCH,
          rd: 5'd0,
          rs1: 5'd0,
          rs2: 5'd0,
          reg_write: 1'b0,
          is_branch: 1'b0,
          is_jump: 1'b0,
          is_jalr: 1'b0,
          is_halt: 1'b0,
          is_load: 1'b0,
          is_store: 1'b0,
          is_mul: 1'b0,
          waits_for_div: 1'b0,
          funct3: 3'd0,
          alu_op: ALU_ADD,
          mul_op: MUL_LO,
          use_imm: 1'b0,
          rs1_val: 32'd0,
          rs2_val: 32'd0,
          imm: 32'd0
        };

        decode_state <= '{pc: 32'd0, insn: 32'd0, cycle_status: CYCLE_TAKEN_BRANCH};

        if (x_state.is_jump) begin
          f_pc_current <= x_jump_target;
        end else if (x_state.is_jalr) begin
          f_pc_current <= x_jalr_target;
        end else begin
          f_pc_current <= x_branch_target;
        end
        f_cycle_status <= CYCLE_NO_STALL;

      end else if (load_use_hazard) begin
        x_state <= '{
          pc: 32'd0,
          insn: 32'd0,
          cycle_status: CYCLE_LOAD2USE,
          rd: 5'd0,
          rs1: 5'd0,
          rs2: 5'd0,
          reg_write: 1'b0,
          is_branch: 1'b0,
          is_jump: 1'b0,
          is_jalr: 1'b0,
          is_halt: 1'b0,
          is_load: 1'b0,
          is_store: 1'b0,
          is_mul: 1'b0,
          waits_for_div: 1'b0,
          funct3: 3'd0,
          alu_op: ALU_ADD,
          mul_op: MUL_LO,
          use_imm: 1'b0,
          rs1_val: 32'd0,
          rs2_val: 32'd0,
          imm: 32'd0
        };
        decode_state <= decode_state;
        f_pc_current <= f_pc_current;
        f_cycle_status <= CYCLE_NO_STALL;

      end else if (div_pipe_hold || hold_front_for_div_insert) begin
        x_state <= x_state;
        decode_state <= decode_state;
        f_pc_current <= f_pc_current;
        f_cycle_status <= CYCLE_NO_STALL;

      end else if (div_dep_hazard) begin
        x_state <= '{
          pc: 32'd0,
          insn: 32'd0,
          cycle_status: CYCLE_DIV,
          rd: 5'd0,
          rs1: 5'd0,
          rs2: 5'd0,
          reg_write: 1'b0,
          is_branch: 1'b0,
          is_jump: 1'b0,
          is_jalr: 1'b0,
          is_halt: 1'b0,
          is_load: 1'b0,
          is_store: 1'b0,
          is_mul: 1'b0,
          waits_for_div: 1'b0,
          funct3: 3'd0,
          alu_op: ALU_ADD,
          mul_op: MUL_LO,
          use_imm: 1'b0,
          rs1_val: 32'd0,
          rs2_val: 32'd0,
          imm: 32'd0
        };
        decode_state <= decode_state;
        f_pc_current <= f_pc_current;
        f_cycle_status <= CYCLE_NO_STALL;

      end else if (x_hold_for_div) begin
        x_state <= x_state;
        decode_state <= decode_state;
        f_pc_current <= f_pc_current;
        f_cycle_status <= CYCLE_NO_STALL;

      end else if (div_issue) begin
        x_state <= '{
          pc: 32'd0,
          insn: 32'd0,
          cycle_status: CYCLE_DIV,
          rd: 5'd0,
          rs1: 5'd0,
          rs2: 5'd0,
          reg_write: 1'b0,
          is_branch: 1'b0,
          is_jump: 1'b0,
          is_jalr: 1'b0,
          is_halt: 1'b0,
          is_load: 1'b0,
          is_store: 1'b0,
          is_mul: 1'b0,
          waits_for_div: 1'b0,
          funct3: 3'd0,
          alu_op: ALU_ADD,
          mul_op: MUL_LO,
          use_imm: 1'b0,
          rs1_val: 32'd0,
          rs2_val: 32'd0,
          imm: 32'd0
        };

        div_pipe[0] <= '{
          valid: 1'b1,
          pc: decode_state.pc,
          insn: decode_state.insn,
          cycle_status: decode_state.cycle_status,
          rd: d_rd,
          reg_write: (d_rd != 5'd0),
          result: d_is_rem ? d_div_calc.r : d_div_calc.q
        };

        decode_state <= '{
          pc: f_pc_current,
          insn: f_insn,
          cycle_status: f_cycle_status
        };
        f_pc_current <= f_pc_current + 32'd4;
        f_cycle_status <= CYCLE_NO_STALL;

      end else begin
        x_state <= x_state_next;
        decode_state <= '{pc: f_pc_current, insn: f_insn, cycle_status: f_cycle_status};
        f_pc_current <= f_pc_current + 32'd4;
        f_cycle_status <= CYCLE_NO_STALL;
      end
    end
  end

endmodule

module MemorySingleCycle #(
    parameter int NUM_WORDS = 512
) (
    input wire rst,
    input wire clk,
    input wire [`REG_SIZE] pc_to_imem,
    output logic [`REG_SIZE] insn_from_imem,
    input wire [`REG_SIZE] addr_to_dmem,
    output logic [`REG_SIZE] load_data_from_dmem,
    input wire [`REG_SIZE] store_data_to_dmem,
    input wire [3:0] store_we_to_dmem
);

  logic [`REG_SIZE] mem_array[NUM_WORDS];

`ifdef SYNTHESIS
  initial begin
    $readmemh("mem_initial_contents.hex", mem_array);
  end
`endif

  always_comb begin
    assert (pc_to_imem[1:0] == 2'b00);
    assert (addr_to_dmem[1:0] == 2'b00);
  end

  localparam int AddrMsb = $clog2(NUM_WORDS) + 1;
  localparam int AddrLsb = 2;

  always @(negedge clk) begin
    if (rst) begin
    end else begin
      insn_from_imem <= mem_array[{pc_to_imem[AddrMsb:AddrLsb]}];
    end
  end

  always @(negedge clk) begin
    if (rst) begin
    end else begin
      if (store_we_to_dmem[0]) begin
        mem_array[addr_to_dmem[AddrMsb:AddrLsb]][7:0] <= store_data_to_dmem[7:0];
      end
      if (store_we_to_dmem[1]) begin
        mem_array[addr_to_dmem[AddrMsb:AddrLsb]][15:8] <= store_data_to_dmem[15:8];
      end
      if (store_we_to_dmem[2]) begin
        mem_array[addr_to_dmem[AddrMsb:AddrLsb]][23:16] <= store_data_to_dmem[23:16];
      end
      if (store_we_to_dmem[3]) begin
        mem_array[addr_to_dmem[AddrMsb:AddrLsb]][31:24] <= store_data_to_dmem[31:24];
      end
      load_data_from_dmem <= mem_array[{addr_to_dmem[AddrMsb:AddrLsb]}];
    end
  end
endmodule

module Processor (
    input  wire  clk,
    input  wire  rst,
    output logic halt,
    output wire [`REG_SIZE] trace_completed_pc,
    output wire [`INSN_SIZE] trace_completed_insn,
    output cycle_status_e trace_completed_cycle_status
);

  wire [`INSN_SIZE] insn_from_imem;
  wire [`REG_SIZE] pc_to_imem, mem_data_addr, mem_data_loaded_value, mem_data_to_write;
  wire [3:0] mem_data_we;
  wire [(8*32)-1:0] test_case;

  MemorySingleCycle #(
      .NUM_WORDS(8192)
  ) memory (
      .rst                (rst),
      .clk                (clk),
      .pc_to_imem         (pc_to_imem),
      .insn_from_imem     (insn_from_imem),
      .addr_to_dmem       (mem_data_addr),
      .load_data_from_dmem(mem_data_loaded_value),
      .store_data_to_dmem (mem_data_to_write),
      .store_we_to_dmem   (mem_data_we)
  );

  DatapathPipelined datapath (
      .clk(clk),
      .rst(rst),
      .pc_to_imem(pc_to_imem),
      .insn_from_imem(insn_from_imem),
      .addr_to_dmem(mem_data_addr),
      .store_data_to_dmem(mem_data_to_write),
      .store_we_to_dmem(mem_data_we),
      .load_data_from_dmem(mem_data_loaded_value),
      .halt(halt),
      .trace_completed_pc(trace_completed_pc),
      .trace_completed_insn(trace_completed_make insn),
      .trace_completed_cycle_status(trace_completed_cycle_status)
  );

endmodule
