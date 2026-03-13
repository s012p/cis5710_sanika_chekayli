`timescale 1ns / 1ns

// registers are 32 bits in RV32
`define REG_SIZE 31:0

// insns are 32 bits in RV32IM
`define INSN_SIZE 31:0

// RV opcodes are 7 bits
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
  // this code is only for simulation, not synthesis
  string disasm_string;
  always_comb begin
    disasm_string = rv_disasm(insn);
  end
  // HACK: get disasm_string to appear in GtkWave, which can apparently show only wire/logic. Also,
  // string needs to be reversed to render correctly.
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

  // TODO: your code here
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
      // WD bypass
      rs1_data = rd_data;
    end else begin
      rs1_data = regs[rs1];
    end

    if (rs2 == 5'd0) begin
      rs2_data = 32'd0;
    end else if (we && (rd != 5'd0) && (rd == rs2)) begin
      // WD bypass
      rs2_data = rd_data;
    end else begin
      rs2_data = regs[rs2];
    end
  end

endmodule

/** state at the start of Decode stage */
typedef struct packed {
  logic [`REG_SIZE] pc;
  logic [`INSN_SIZE] insn;
  cycle_status_e cycle_status;
} stage_decode_t;

module DatapathPipelined (
    input wire clk,
    input wire rst,
    output logic [`REG_SIZE] pc_to_imem,
    input wire [`INSN_SIZE] insn_from_imem,
    // dmem is read/write
    output logic [`REG_SIZE] addr_to_dmem,
    input wire [`REG_SIZE] load_data_from_dmem,
    output logic [`REG_SIZE] store_data_to_dmem,
    output logic [3:0] store_we_to_dmem,

    output logic halt,

    // The PC of the insn currently in Writeback. 0 if not a valid insn.
    output logic [`REG_SIZE] trace_completed_pc,
    // The bits of the insn currently in Writeback. 0 if not a valid insn.
    output logic [`INSN_SIZE] trace_completed_insn,
    // The status of the insn (or stall) currently in Writeback. See the cycle_status.sv file for valid values.
    output cycle_status_e trace_completed_cycle_status
);
  // opcodes - see section 19 of RiscV spec
  localparam bit [`OPCODE_SIZE] OpcodeBranch  = 7'b11_000_11;
  localparam bit [`OPCODE_SIZE] OpcodeJalr    = 7'b11_001_11;
  localparam bit [`OPCODE_SIZE] OpcodeJal     = 7'b11_011_11;

  localparam bit [`OPCODE_SIZE] OpcodeRegImm  = 7'b00_100_11;
  localparam bit [`OPCODE_SIZE] OpcodeRegReg  = 7'b01_100_11;
  localparam bit [`OPCODE_SIZE] OpcodeEnviron = 7'b11_100_11;

  localparam bit [`OPCODE_SIZE] OpcodeAuipc   = 7'b00_101_11;
  localparam bit [`OPCODE_SIZE] OpcodeLui     = 7'b01_101_11;

  // cycle counter, not really part of any stage but useful for orienting within GtkWave
  // do not rename this as the testbench uses this value
  logic [`REG_SIZE] cycles_current;
  always_ff @(posedge clk) begin
    if (rst) begin
      cycles_current <= 0;
    end else begin
      cycles_current <= cycles_current + 1;
    end
  end

  /***************/
  /* FETCH STAGE */
  /***************/

  logic [`REG_SIZE] f_pc_current;
  wire [`REG_SIZE] f_insn;
  cycle_status_e f_cycle_status;

  // send PC to imem
  assign pc_to_imem = f_pc_current;
  assign f_insn = insn_from_imem;

  // Here's how to disassemble an insn into a string you can view in GtkWave.
  // Use PREFIX to provide a 1-character tag to identify which stage the insn comes from.
  wire [255:0] f_disasm;
  Disasm #(
      .PREFIX("F")
  ) disasm_0fetch (
      .insn  (f_insn),
      .disasm(f_disasm)
  );

  /****************/
  /* DECODE STAGE */
  /****************/

  // this shows how to package up state in a `struct packed`, and how to pass it between stages
  stage_decode_t decode_state;
  wire [255:0] d_disasm;
  Disasm #(
      .PREFIX("D")
  ) disasm_1decode (
      .insn  (decode_state.insn),
      .disasm(d_disasm)
  );

  // TODO: your code here, though you will also need to modify some of the code above
  // TODO: the testbench requires that your register file instance is named `rf`
  /*****************/
  /* EXECUTE STAGE */
  /*****************/

  localparam logic [3:0] ALU_ADD  = 4'd0;
  localparam logic [3:0] ALU_SUB  = 4'd1;
  localparam logic [3:0] ALU_AND  = 4'd2;
  localparam logic [3:0] ALU_OR   = 4'd3;
  localparam logic [3:0] ALU_XOR  = 4'd4;
  localparam logic [3:0] ALU_SLT  = 4'd5;
  localparam logic [3:0] ALU_SLTU = 4'd6;
  localparam logic [3:0] ALU_SLL  = 4'd7;
  localparam logic [3:0] ALU_SRL  = 4'd8;
  localparam logic [3:0] ALU_SRA  = 4'd9;
  localparam logic [3:0] ALU_COPY_B = 4'd10;
  localparam logic [3:0] ALU_ADD_PC_IMM = 4'd11;

  typedef struct packed {
    logic [`REG_SIZE] pc;
    logic [`INSN_SIZE] insn;
    cycle_status_e cycle_status;

    logic [4:0] rd;
    logic reg_write;
    logic is_branch;
    logic is_jump;
    logic is_jalr;
    logic is_halt;

    logic [2:0] funct3;
    logic [3:0] alu_op;
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
  logic reg_write;
  logic is_halt;

  logic [`REG_SIZE] result;
} stage_memory_t;

  typedef stage_memory_t stage_writeback_t;

  stage_execute_t x_state;
  stage_memory_t  m_state;
  stage_writeback_t w_state;

  wire [255:0] x_disasm;
  Disasm #(
      .PREFIX("X")
  ) disasm_2execute (
      .insn  (x_state.insn),
      .disasm(x_disasm)
  );

  wire [255:0] m_disasm;
  Disasm #(
      .PREFIX("M")
  ) disasm_3memory (
      .insn  (m_state.insn),
      .disasm(m_disasm)
  );

  wire [255:0] w_disasm;
  Disasm #(
      .PREFIX("W")
  ) disasm_4writeback (
      .insn  (w_state.insn),
      .disasm(w_disasm)
  );

  // ----------------------------
  // Decode fields
  // ----------------------------
  logic [`OPCODE_SIZE] d_opcode;
  logic [4:0] d_rs1, d_rs2, d_rd;
  logic [2:0] d_funct3;
  logic [6:0] d_funct7;

  logic [`REG_SIZE] d_imm_i, d_imm_u, d_imm_b, d_imm_j;

  assign d_opcode = decode_state.insn[6:0];
  assign d_rd     = decode_state.insn[11:7];
  assign d_funct3 = decode_state.insn[14:12];
  assign d_rs1    = decode_state.insn[19:15];
  assign d_rs2    = decode_state.insn[24:20];
  assign d_funct7 = decode_state.insn[31:25];

  assign d_imm_i = {{20{decode_state.insn[31]}}, decode_state.insn[31:20]};
  assign d_imm_u = {decode_state.insn[31:12], 12'b0};
  assign d_imm_b = {{19{decode_state.insn[31]}},
                    decode_state.insn[31],
                    decode_state.insn[7],
                    decode_state.insn[30:25],
                    decode_state.insn[11:8],
                    1'b0};
  assign d_imm_j = {{11{decode_state.insn[31]}},
                  decode_state.insn[31],
                  decode_state.insn[19:12],
                  decode_state.insn[20],
                  decode_state.insn[30:21],
                  1'b0};

  logic d_is_lui, d_is_auipc, d_is_regimm, d_is_regreg;
  logic d_is_branch, d_is_jal, d_is_jalr, d_is_env;

  assign d_is_lui    = (d_opcode == OpcodeLui);
  assign d_is_auipc  = (d_opcode == OpcodeAuipc);
  assign d_is_regimm = (d_opcode == OpcodeRegImm);
  assign d_is_regreg = (d_opcode == OpcodeRegReg);
  assign d_is_branch = (d_opcode == OpcodeBranch);
  assign d_is_jal    = (d_opcode == OpcodeJal);
  assign d_is_jalr   = (d_opcode == OpcodeJalr);
  assign d_is_env    = (d_opcode == OpcodeEnviron);
  // ----------------------------
  // Register file + WD bypass
  // ----------------------------
  logic [`REG_SIZE] rf_rs1_data, rf_rs2_data;

  // testbench requires instance name `rf`
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

  // ----------------------------
  // MX / WX bypass into the instruction entering X
  // ----------------------------
  logic [`REG_SIZE] d_rs1_bypassed, d_rs2_bypassed;

  always_comb begin
    d_rs1_bypassed = rf_rs1_data;
    d_rs2_bypassed = rf_rs2_data;

  // MX bypass: from current X stage
  if (x_state.reg_write && (x_state.rd != 5'd0) && (x_state.rd == d_rs1)) begin
    d_rs1_bypassed = x_result;
  end else if (m_state.reg_write && (m_state.rd != 5'd0) && (m_state.rd == d_rs1)) begin
    d_rs1_bypassed = m_state.result;
  end else if (w_state.reg_write && (w_state.rd != 5'd0) && (w_state.rd == d_rs1)) begin
    d_rs1_bypassed = w_state.result;
  end

  if (x_state.reg_write && (x_state.rd != 5'd0) && (x_state.rd == d_rs2)) begin
    d_rs2_bypassed = x_result;
  end else if (m_state.reg_write && (m_state.rd != 5'd0) && (m_state.rd == d_rs2)) begin
    d_rs2_bypassed = m_state.result;
  end else if (w_state.reg_write && (w_state.rd != 5'd0) && (w_state.rd == d_rs2)) begin
    d_rs2_bypassed = w_state.result;
  end
end

  // ----------------------------
  // Decode -> X packed control
  // ----------------------------
  stage_execute_t x_state_next;

  always_comb begin
    x_state_next = '{
        pc: 32'd0,
        insn: 32'd0,
        cycle_status: decode_state.cycle_status,
        rd: 5'd0,
        reg_write: 1'b0,
        is_branch: 1'b0,
        is_jump: 1'b0,
        is_jalr: 1'b0,
        is_halt: 1'b0,
        funct3: 3'd0,
        alu_op: ALU_ADD,
        use_imm: 1'b0,
        rs1_val: d_rs1_bypassed,
        rs2_val: d_rs2_bypassed,
        imm: 32'd0
    };

    // bubble / flushed instruction / reset bubble
    if (decode_state.insn == 32'd0) begin
      x_state_next = '{
        pc: 32'd0,
        insn: 32'd0,
        cycle_status: decode_state.cycle_status,
        rd: 5'd0,
        reg_write: 1'b0,
        is_branch: 1'b0,
        is_jump: 1'b0,
        is_jalr: 1'b0,
        is_halt: 1'b0,
        funct3: 3'd0,
        alu_op: ALU_ADD,
        use_imm: 1'b0,
        rs1_val: 32'd0,
        rs2_val: 32'd0,
        imm: 32'd0
      };
    end else if (d_is_lui) begin
      x_state_next.pc   = decode_state.pc;
      x_state_next.insn = decode_state.insn;
      x_state_next.rd        = d_rd;
      x_state_next.reg_write = (d_rd != 5'd0);
      x_state_next.alu_op    = ALU_COPY_B;
      x_state_next.use_imm   = 1'b1;
      x_state_next.imm       = d_imm_u;
    end else if (d_is_auipc) begin
      x_state_next.pc   = decode_state.pc;
      x_state_next.insn = decode_state.insn;
      x_state_next.rd        = d_rd;
      x_state_next.reg_write = (d_rd != 5'd0);
      x_state_next.alu_op    = ALU_ADD_PC_IMM;
      x_state_next.use_imm   = 1'b1;
      x_state_next.imm       = d_imm_u;
    end else if (d_is_regimm) begin
      x_state_next.pc   = decode_state.pc;
      x_state_next.insn = decode_state.insn;
      x_state_next.rd        = d_rd;
      x_state_next.reg_write = (d_rd != 5'd0);
      x_state_next.use_imm   = 1'b1;
      x_state_next.imm       = d_imm_i;

      unique case (d_funct3)
        3'b000: x_state_next.alu_op = ALU_ADD;   // addi
        3'b010: x_state_next.alu_op = ALU_SLT;   // slti
        3'b011: x_state_next.alu_op = ALU_SLTU;  // sltiu
        3'b100: x_state_next.alu_op = ALU_XOR;   // xori
        3'b110: x_state_next.alu_op = ALU_OR;    // ori
        3'b111: x_state_next.alu_op = ALU_AND;   // andi
        3'b001: begin                             // slli
          x_state_next.alu_op = ALU_SLL;
          x_state_next.imm    = {27'd0, decode_state.insn[24:20]};
        end
        3'b101: begin                             // srli / srai
          x_state_next.imm = {27'd0, decode_state.insn[24:20]};
          if (decode_state.insn[30]) begin
            x_state_next.alu_op = ALU_SRA;
          end else begin
            x_state_next.alu_op = ALU_SRL;
          end
        end
        default: begin end
      endcase
    end else if (d_is_regreg) begin
      x_state_next.pc   = decode_state.pc;
      x_state_next.insn = decode_state.insn;
      x_state_next.rd        = d_rd;
      x_state_next.reg_write = (d_rd != 5'd0);

      unique case (d_funct3)
        3'b000: begin
          if (d_funct7[5]) x_state_next.alu_op = ALU_SUB; // sub
          else             x_state_next.alu_op = ALU_ADD; // add
        end
        3'b001: x_state_next.alu_op = ALU_SLL;
        3'b010: x_state_next.alu_op = ALU_SLT;
        3'b011: x_state_next.alu_op = ALU_SLTU;
        3'b100: x_state_next.alu_op = ALU_XOR;
        3'b101: begin
          if (d_funct7[5]) x_state_next.alu_op = ALU_SRA; // sra
          else             x_state_next.alu_op = ALU_SRL; // srl
        end
        3'b110: x_state_next.alu_op = ALU_OR;
        3'b111: x_state_next.alu_op = ALU_AND;
        default: begin end
      endcase
    end else if (d_is_branch) begin
      x_state_next.pc   = decode_state.pc;
      x_state_next.insn = decode_state.insn;
      x_state_next.is_branch = 1'b1;
      x_state_next.imm       = d_imm_b;
      x_state_next.funct3    = d_funct3;
    end else if (d_is_jal) begin
      x_state_next.pc   = decode_state.pc;
      x_state_next.insn = decode_state.insn;
      x_state_next.rd        = d_rd;
      x_state_next.reg_write = (d_rd != 5'd0);
      x_state_next.is_jump   = 1'b1;
      x_state_next.imm       = d_imm_j;
    end else if (d_is_jalr) begin
      x_state_next.pc        = decode_state.pc;
      x_state_next.insn      = decode_state.insn;
      x_state_next.rd        = d_rd;
      x_state_next.reg_write = (d_rd != 5'd0);
      x_state_next.is_jalr   = 1'b1;
      x_state_next.use_imm   = 1'b1;
      x_state_next.imm       = d_imm_i;
    end else if (d_is_env) begin
      // only ECALL should halt
      if ((decode_state.insn[31:20] == 12'd0) && (d_rs1 == 5'd0) && (d_funct3 == 3'd0) && (d_rd == 5'd0)) begin
        x_state_next.pc   = decode_state.pc;
        x_state_next.insn = decode_state.insn;
        x_state_next.is_halt = 1'b1;
      end
    end
  end

  // ----------------------------
  // Execute ALU / branch decision
  // ----------------------------
  logic [`REG_SIZE] x_operand_b;
  logic [`REG_SIZE] x_result;
  logic x_branch_taken;
  logic [`REG_SIZE] x_branch_target;
  logic [`REG_SIZE] x_jump_target;
  logic [`REG_SIZE] x_jalr_target;

  assign x_operand_b     = x_state.use_imm ? x_state.imm : x_state.rs2_val;
  assign x_branch_target = x_state.pc + x_state.imm;
  assign x_jump_target   = x_state.pc + x_state.imm;
  assign x_jalr_target   = (x_state.rs1_val + x_state.imm) & 32'hFFFF_FFFE;

  always_comb begin
    if (x_state.is_jump || x_state.is_jalr) begin
      x_result = x_state.pc + 32'd4;
    end else begin
      unique case (x_state.alu_op)
        ALU_ADD:    x_result = x_state.rs1_val + x_operand_b;
        ALU_SUB:    x_result = x_state.rs1_val - x_operand_b;
        ALU_AND:    x_result = x_state.rs1_val & x_operand_b;
        ALU_OR:     x_result = x_state.rs1_val | x_operand_b;
        ALU_XOR:    x_result = x_state.rs1_val ^ x_operand_b;
        ALU_SLT:    x_result = ($signed(x_state.rs1_val) < $signed(x_operand_b)) ? 32'd1 : 32'd0;
        ALU_SLTU:   x_result = (x_state.rs1_val < x_operand_b) ? 32'd1 : 32'd0;
        ALU_SLL:    x_result = x_state.rs1_val << x_operand_b[4:0];
        ALU_SRL:    x_result = x_state.rs1_val >> x_operand_b[4:0];
        ALU_SRA:    x_result = $signed(x_state.rs1_val) >>> x_operand_b[4:0];
        ALU_ADD_PC_IMM: x_result = x_state.pc + x_state.imm;
        ALU_COPY_B: x_result = x_operand_b;
        default:    x_result = 32'd0;
      endcase
    end
  end

  always_comb begin
    x_branch_taken = 1'b0;

    if (x_state.is_branch) begin
      unique case (x_state.funct3)
        3'b000: x_branch_taken = (x_state.rs1_val == x_state.rs2_val);                      // beq
        3'b001: x_branch_taken = (x_state.rs1_val != x_state.rs2_val);                      // bne
        3'b100: x_branch_taken = ($signed(x_state.rs1_val) <  $signed(x_state.rs2_val));    // blt
        3'b101: x_branch_taken = ($signed(x_state.rs1_val) >= $signed(x_state.rs2_val));    // bge
        3'b110: x_branch_taken = (x_state.rs1_val <  x_state.rs2_val);                      // bltu
        3'b111: x_branch_taken = (x_state.rs1_val >= x_state.rs2_val);                      // bgeu
        default: x_branch_taken = 1'b0;
      endcase
    end
  end

  // ----------------------------
  // Memory interface unused for milestone 1
  // ----------------------------
  assign addr_to_dmem       = 32'd0;
  assign store_data_to_dmem = 32'd0;
  assign store_we_to_dmem   = 4'b0000;

  // ----------------------------
  // Trace outputs are whatever is in W this cycle
  // ----------------------------
  assign trace_completed_pc =
      (w_state.insn == 32'd0) ? 32'd0 : w_state.pc;

  assign trace_completed_insn =
      (w_state.insn == 32'd0) ? 32'd0 : w_state.insn;

  assign trace_completed_cycle_status = w_state.cycle_status;

  // ----------------------------
  // Halt when ECALL reaches W
  // ----------------------------
  always_ff @(posedge clk) begin
    if (rst) begin
      halt <= 1'b0;
    end else if (m_state.is_halt && (m_state.insn != 32'd0)) begin
      halt <= 1'b1;
    end
  end

  // ----------------------------
  // Main pipeline register update
  // ----------------------------
  always_ff @(posedge clk) begin
    if (rst) begin
      f_pc_current   <= 32'd0;
      f_cycle_status <= CYCLE_NO_STALL;

      decode_state <= '{
        pc: 32'd0,
        insn: 32'd0,
        cycle_status: CYCLE_RESET
      };

    x_state <= '{
      pc: 32'd0,
      insn: 32'd0,
      cycle_status: CYCLE_RESET,
      rd: 5'd0,
      reg_write: 1'b0,
      is_branch: 1'b0,
      is_jump: 1'b0,
      is_jalr: 1'b0,
      is_halt: 1'b0,
      funct3: 3'd0,
      alu_op: ALU_ADD,
      use_imm: 1'b0,
      rs1_val: 32'd0,
      rs2_val: 32'd0,
      imm: 32'd0
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

    m_state <= '{
      pc: 32'd0,
      insn: 32'd0,
      cycle_status: CYCLE_RESET,
      rd: 5'd0,
      reg_write: 1'b0,
      is_halt: 1'b0,
      result: 32'd0
    };

    end else begin
      // W gets old M
    w_state <= m_state;

      // M gets old X
      m_state <= '{
        pc: x_state.pc,
        insn: x_state.insn,
        cycle_status: x_state.cycle_status,
        rd: x_state.rd,
        reg_write: x_state.reg_write,
        is_halt: x_state.is_halt,
        result: x_result
      };

      if (x_branch_taken || x_state.is_jump || x_state.is_jalr) begin
        // taken branch:
        // - squash instruction currently in D before it enters X
        // - squash instruction currently in F before it enters D
        // - redirect PC so correct-path instruction appears in F next cycle
        x_state <= '{
          pc: 32'd0,
          insn: 32'd0,
          cycle_status: CYCLE_TAKEN_BRANCH,
          rd: 5'd0,
          reg_write: 1'b0,
          is_branch: 1'b0,
          is_jump: 1'b0,
          is_jalr: 1'b0,
          is_halt: 1'b0,
          funct3: 3'd0,
          alu_op: ALU_ADD,
          use_imm: 1'b0,
          rs1_val: 32'd0,
          rs2_val: 32'd0,
          imm: 32'd0
        };

        decode_state <= '{
          pc: 32'd0,
          insn: 32'd0,
          cycle_status: CYCLE_TAKEN_BRANCH
        };

        if (x_state.is_jump) begin
          f_pc_current <= x_jump_target;
        end else if (x_state.is_jalr) begin
          f_pc_current <= x_jalr_target;
        end else begin
          f_pc_current <= x_branch_target;
        end
        f_cycle_status <= CYCLE_NO_STALL;
      end else begin
        // normal pipeline advance
        x_state <= x_state_next;

        decode_state <= '{
          pc: f_pc_current,
          insn: f_insn,
          cycle_status: f_cycle_status
        };

        f_pc_current   <= f_pc_current + 32'd4;
        f_cycle_status <= CYCLE_NO_STALL;
      end
    end
  end

endmodule

module MemorySingleCycle #(
    parameter int NUM_WORDS = 512
) (
    // rst for both imem and dmem
    input wire rst,

    // clock for both imem and dmem. The memory reads/writes on @(negedge clk)
    input wire clk,

    // must always be aligned to a 4B boundary
    input wire [`REG_SIZE] pc_to_imem,

    // the value at memory location pc_to_imem
    output logic [`REG_SIZE] insn_from_imem,

    // must always be aligned to a 4B boundary
    input wire [`REG_SIZE] addr_to_dmem,

    // the value at memory location addr_to_dmem
    output logic [`REG_SIZE] load_data_from_dmem,

    // the value to be written to addr_to_dmem, controlled by store_we_to_dmem
    input wire [`REG_SIZE] store_data_to_dmem,

    // Each bit determines whether to write the corresponding byte of store_data_to_dmem to memory location addr_to_dmem.
    // E.g., 4'b1111 will write 4 bytes. 4'b0001 will write only the least-significant byte.
    input wire [3:0] store_we_to_dmem
);

  // memory is arranged as an array of 4B words
  logic [`REG_SIZE] mem_array[NUM_WORDS];

`ifdef SYNTHESIS
  initial begin
    $readmemh("mem_initial_contents.hex", mem_array);
  end
`endif

  always_comb begin
    // memory addresses should always be 4B-aligned
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
      // dmem is "read-first": read returns value before the write
      load_data_from_dmem <= mem_array[{addr_to_dmem[AddrMsb:AddrLsb]}];
    end
  end
endmodule

/* This design has just one clock for both processor and memory. */
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

  // This wire is set by cocotb to the name of the currently-running test, to make it easier
  // to see what is going on in the waveforms.
  wire [(8*32)-1:0] test_case;

  MemorySingleCycle #(
      .NUM_WORDS(8192)
  ) memory (
      .rst                (rst),
      .clk                (clk),
      // imem is read-only
      .pc_to_imem         (pc_to_imem),
      .insn_from_imem     (insn_from_imem),
      // dmem is read-write
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
      .trace_completed_insn(trace_completed_insn),
      .trace_completed_cycle_status(trace_completed_cycle_status)
  );

endmodule
