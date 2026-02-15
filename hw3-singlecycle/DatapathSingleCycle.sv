`timescale 1ns / 1ns

// registers are 32 bits in RV32
`define REG_SIZE 31:0

// insns are 32 bits in RV32IM
`define INSN_SIZE 31:0

// RV opcodes are 7 bits
`define OPCODE_SIZE 6:0

`include "../hw2a-divider/DividerUnsigned.sv"
`include "../hw2b-cla/CarryLookaheadAdder.sv"
`include "cycle_status.sv"

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
  logic [`REG_SIZE] regs [0:NumRegs-1];

  // TODO: your code here
  always_comb begin
    if (rs1 != 0)
      rs1_data = regs[rs1];
    else
      rs1_data = 32'd0;
    if (rs2 != 0)
      rs2_data = regs[rs2];
    else
      rs2_data = 32'd0;
  end
  
  always_ff @(posedge clk) begin
    if (rst) begin
      for (int i = 0; i < NumRegs; i++) regs[i] <= 32'd0;
    end else if (we && (rd != 0)) begin
      regs[rd] <= rd_data;
      end
  end


endmodule

module DatapathSingleCycle (
    input wire                clk,
    input wire                rst,
    output logic              halt,
    output logic [`REG_SIZE]  pc_to_imem,
    input wire [`INSN_SIZE]   insn_from_imem,
    // addr_to_dmem is used for both loads and stores
    output logic [`REG_SIZE]  addr_to_dmem,
    input logic [`REG_SIZE]   load_data_from_dmem,
    output logic [`REG_SIZE]  store_data_to_dmem,
    output logic [3:0]        store_we_to_dmem,

    // the PC of the insn executing in the current cycle
    output logic [`REG_SIZE]  trace_completed_pc,
    // the machine code of the insn executing in the current cycle
    output logic [`INSN_SIZE] trace_completed_insn,
    // the cycle status of the current cycle: should always be CYCLE_NO_STALL
    output cycle_status_e     trace_completed_cycle_status
);

  // components of the instruction
  wire [6:0] insn_funct7;
  wire [4:0] insn_rs2;
  wire [4:0] insn_rs1;
  wire [2:0] insn_funct3;
  wire [4:0] insn_rd;
  wire [`OPCODE_SIZE] insn_opcode;

  // split R-type instruction - see section 2.2 of RiscV spec
  assign {insn_funct7, insn_rs2, insn_rs1, insn_funct3, insn_rd, insn_opcode} = insn_from_imem;

  // setup for I, S, B & J type instructions
  // I - short immediates and loads
  wire [11:0] imm_i;
  assign imm_i = insn_from_imem[31:20];
  wire [ 4:0] imm_shamt = insn_from_imem[24:20];

  // S - stores
  wire [11:0] imm_s;
  assign imm_s = {insn_from_imem[31:25], insn_from_imem[11:7]};

  // B - conditionals
  wire [12:0] imm_b;
  assign imm_b = {insn_from_imem[31], insn_from_imem[7],
                  insn_from_imem[30:25], insn_from_imem[11:8], 1'b0};

  // J - unconditional jumps
  wire [20:0] imm_j;
  assign {imm_j[20], imm_j[10:1], imm_j[11], imm_j[19:12], imm_j[0]} = {insn_from_imem[31:12], 1'b0};

  wire [`REG_SIZE] imm_i_sext = {{20{imm_i[11]}}, imm_i[11:0]};
  wire [`REG_SIZE] imm_s_sext = {{20{imm_s[11]}}, imm_s[11:0]};
  wire [`REG_SIZE] imm_b_sext = {{19{imm_b[12]}}, imm_b[12:0]};
  wire [`REG_SIZE] imm_j_sext = {{11{imm_j[20]}}, imm_j[20:0]};

  // opcodes - see section 19 of RiscV spec
  localparam bit [`OPCODE_SIZE] OpLoad = 7'b00_000_11;
  localparam bit [`OPCODE_SIZE] OpStore = 7'b01_000_11;
  localparam bit [`OPCODE_SIZE] OpBranch = 7'b11_000_11;
  localparam bit [`OPCODE_SIZE] OpJalr = 7'b11_001_11;
  localparam bit [`OPCODE_SIZE] OpMiscMem = 7'b00_011_11;
  localparam bit [`OPCODE_SIZE] OpJal = 7'b11_011_11;

  localparam bit [`OPCODE_SIZE] OpRegImm = 7'b00_100_11;
  localparam bit [`OPCODE_SIZE] OpRegReg = 7'b01_100_11;
  localparam bit [`OPCODE_SIZE] OpEnviron = 7'b11_100_11;

  localparam bit [`OPCODE_SIZE] OpAuipc = 7'b00_101_11;
  localparam bit [`OPCODE_SIZE] OpLui = 7'b01_101_11;

  wire insn_lui   = insn_opcode == OpLui;
  wire insn_auipc = insn_opcode == OpAuipc;
  wire insn_jal   = insn_opcode == OpJal;
  wire insn_jalr  = insn_opcode == OpJalr;

  wire insn_beq  = insn_opcode == OpBranch && insn_from_imem[14:12] == 3'b000;
  wire insn_bne  = insn_opcode == OpBranch && insn_from_imem[14:12] == 3'b001;
  wire insn_blt  = insn_opcode == OpBranch && insn_from_imem[14:12] == 3'b100;
  wire insn_bge  = insn_opcode == OpBranch && insn_from_imem[14:12] == 3'b101;
  wire insn_bltu = insn_opcode == OpBranch && insn_from_imem[14:12] == 3'b110;
  wire insn_bgeu = insn_opcode == OpBranch && insn_from_imem[14:12] == 3'b111;

  wire insn_lb  = insn_opcode == OpLoad && insn_from_imem[14:12] == 3'b000;
  wire insn_lh  = insn_opcode == OpLoad && insn_from_imem[14:12] == 3'b001;
  wire insn_lw  = insn_opcode == OpLoad && insn_from_imem[14:12] == 3'b010;
  wire insn_lbu = insn_opcode == OpLoad && insn_from_imem[14:12] == 3'b100;
  wire insn_lhu = insn_opcode == OpLoad && insn_from_imem[14:12] == 3'b101;

  wire insn_sb = insn_opcode == OpStore && insn_from_imem[14:12] == 3'b000;
  wire insn_sh = insn_opcode == OpStore && insn_from_imem[14:12] == 3'b001;
  wire insn_sw = insn_opcode == OpStore && insn_from_imem[14:12] == 3'b010;

  wire insn_addi  = insn_opcode == OpRegImm && insn_from_imem[14:12] == 3'b000;
  wire insn_slti  = insn_opcode == OpRegImm && insn_from_imem[14:12] == 3'b010;
  wire insn_sltiu = insn_opcode == OpRegImm && insn_from_imem[14:12] == 3'b011;
  wire insn_xori  = insn_opcode == OpRegImm && insn_from_imem[14:12] == 3'b100;
  wire insn_ori   = insn_opcode == OpRegImm && insn_from_imem[14:12] == 3'b110;
  wire insn_andi  = insn_opcode == OpRegImm && insn_from_imem[14:12] == 3'b111;

  wire insn_slli = insn_opcode == OpRegImm && insn_from_imem[14:12] == 3'b001 && insn_from_imem[31:25] == 7'd0;
  wire insn_srli = insn_opcode == OpRegImm && insn_from_imem[14:12] == 3'b101 && insn_from_imem[31:25] == 7'd0;
  wire insn_srai = insn_opcode == OpRegImm && insn_from_imem[14:12] == 3'b101 && insn_from_imem[31:25] == 7'b0100000;

  wire insn_add  = insn_opcode == OpRegReg && insn_from_imem[14:12] == 3'b000 && insn_from_imem[31:25] == 7'd0;
  wire insn_sub  = insn_opcode == OpRegReg && insn_from_imem[14:12] == 3'b000 && insn_from_imem[31:25] == 7'b0100000;
  wire insn_sll  = insn_opcode == OpRegReg && insn_from_imem[14:12] == 3'b001 && insn_from_imem[31:25] == 7'd0;
  wire insn_slt  = insn_opcode == OpRegReg && insn_from_imem[14:12] == 3'b010 && insn_from_imem[31:25] == 7'd0;
  wire insn_sltu = insn_opcode == OpRegReg && insn_from_imem[14:12] == 3'b011 && insn_from_imem[31:25] == 7'd0;
  wire insn_xor  = insn_opcode == OpRegReg && insn_from_imem[14:12] == 3'b100 && insn_from_imem[31:25] == 7'd0;
  wire insn_srl  = insn_opcode == OpRegReg && insn_from_imem[14:12] == 3'b101 && insn_from_imem[31:25] == 7'd0;
  wire insn_sra  = insn_opcode == OpRegReg && insn_from_imem[14:12] == 3'b101 && insn_from_imem[31:25] == 7'b0100000;
  wire insn_or   = insn_opcode == OpRegReg && insn_from_imem[14:12] == 3'b110 && insn_from_imem[31:25] == 7'd0;
  wire insn_and  = insn_opcode == OpRegReg && insn_from_imem[14:12] == 3'b111 && insn_from_imem[31:25] == 7'd0;

  wire insn_mul    = insn_opcode == OpRegReg && insn_from_imem[31:25] == 7'd1 && insn_from_imem[14:12] == 3'b000;
  wire insn_mulh   = insn_opcode == OpRegReg && insn_from_imem[31:25] == 7'd1 && insn_from_imem[14:12] == 3'b001;
  wire insn_mulhsu = insn_opcode == OpRegReg && insn_from_imem[31:25] == 7'd1 && insn_from_imem[14:12] == 3'b010;
  wire insn_mulhu  = insn_opcode == OpRegReg && insn_from_imem[31:25] == 7'd1 && insn_from_imem[14:12] == 3'b011;
  wire insn_div    = insn_opcode == OpRegReg && insn_from_imem[31:25] == 7'd1 && insn_from_imem[14:12] == 3'b100;
  wire insn_divu   = insn_opcode == OpRegReg && insn_from_imem[31:25] == 7'd1 && insn_from_imem[14:12] == 3'b101;
  wire insn_rem    = insn_opcode == OpRegReg && insn_from_imem[31:25] == 7'd1 && insn_from_imem[14:12] == 3'b110;
  wire insn_remu   = insn_opcode == OpRegReg && insn_from_imem[31:25] == 7'd1 && insn_from_imem[14:12] == 3'b111;

  wire insn_ecall = insn_opcode == OpEnviron && insn_from_imem[31:7] == 25'd0;
  wire insn_fence = insn_opcode == OpMiscMem;

  // this code is only for simulation, not synthesis
  `ifndef SYNTHESIS
  `include "RvDisassembler.sv"
  string disasm_string;
  always_comb begin
    disasm_string = rv_disasm(insn_from_imem);
  end
  // HACK: get disasm_string to appear in GtkWave, which can apparently show only wire/logic...
  wire [(8*32)-1:0] disasm_wire;
  genvar i;
  for (i = 0; i < 32; i = i + 1) begin : gen_disasm
    assign disasm_wire[(((i+1))*8)-1:((i)*8)] = disasm_string[31-i];
  end
  `endif

  // program counter
  logic [`REG_SIZE] pcNext, pcCurrent;
  always @(posedge clk) begin
    if (rst) begin
      pcCurrent <= 32'd0;
    end else begin
      pcCurrent <= pcNext;
    end
  end
  assign pc_to_imem = pcCurrent;

  // cycle/insn_from_imem counters
  logic [`REG_SIZE] cycles_current, num_insns_current;
  always @(posedge clk) begin
    if (rst) begin
      cycles_current <= 0;
      num_insns_current <= 0;
    end else begin
      cycles_current <= cycles_current + 1;
      if (!rst) begin
        num_insns_current <= num_insns_current + 1;
      end
    end
  end

  // NOTE: don't rename your RegFile instance as the tests expect it to be `rf`
  // TODO: you will need to edit the port connections, however.
  wire [`REG_SIZE] rs1_data;
  wire [`REG_SIZE] rs2_data;
  logic [`REG_SIZE] rd_data;
  logic write;

  RegFile rf (
    .clk(clk),
    .rst(rst),
    .we(write),
    .rd(insn_rd),
    .rd_data(rd_data),
    .rs1(insn_rs1),
    .rs2(insn_rs2),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data));

  logic [31:0] a; 
  logic [31:0] b;
  logic illegal_insn;
  logic [31:0] temp_sum;
  logic cin;

  //declared logic for loading and storing
  logic [1:0] byte_off;
  logic [31:0] word;
  logic [1:0] byte_off_s;

  //for dividerunsigned
  logic signed [31:0] s_rs1, s_rs2;
  assign s_rs1 = $signed(rs1_data);
  assign s_rs2 = $signed(rs2_data);

  logic rs1_neg, rs2_neg;
  assign rs1_neg = s_rs1[31];
  assign rs2_neg = s_rs2[31];

  logic [31:0] rs1_abs, rs2_abs;

// use CLA to compute two's complement: neg_x = ~x + 1
logic [31:0] neg_rs1_sum, neg_rs2_sum;


  CarryLookaheadAdder ca
  (.a(a),
    .b(b),
   .cin(cin),
    .sum(temp_sum));

  CarryLookaheadAdder neg1 (
  .a(~rs1_data),
  .b(32'd0),
  .cin(1'b1),
  .sum(neg_rs1_sum));

CarryLookaheadAdder neg2 (
  .a(~rs2_data),
  .b(32'd0),
  .cin(1'b1),
  .sum(neg_rs2_sum));

assign rs1_abs = rs1_neg ? neg_rs1_sum : rs1_data;
assign rs2_abs = rs2_neg ? neg_rs2_sum : rs2_data;

logic [31:0] div_quot_abs, div_rem_abs;

DividerUnsigned sdiv_abs (
  .i_dividend(rs1_abs),
  .i_divisor (rs2_abs),
  .o_quotient(div_quot_abs),
  .o_remainder(div_rem_abs)
);

// Unsigned div/rem for DIVU/REMU
logic [31:0] divu_quot, divu_rem;

DividerUnsigned udiv (
  .i_dividend(rs1_data),
  .i_divisor (rs2_data),
  .o_quotient(divu_quot),
  .o_remainder(divu_rem)
);

logic quot_neg;
assign quot_neg = rs1_neg ^ rs2_neg;

logic [31:0] quot_signed, rem_signed;

logic [31:0] neg_quot_sum, neg_rem_sum;

CarryLookaheadAdder negq (
  .a(~div_quot_abs),
  .b(32'd0),
  .cin(1'b1),
  .sum(neg_quot_sum)
);

CarryLookaheadAdder negr (
  .a(~div_rem_abs),
  .b(32'd0),
  .cin(1'b1),
  .sum(neg_rem_sum)
);

assign quot_signed = quot_neg ? neg_quot_sum : div_quot_abs;
// remainder sign follows dividend sign in RISC-V
assign rem_signed  = rs1_neg ? neg_rem_sum : div_rem_abs;

  // Multiply intermediate products
  // Correct-width multiply helpers(32x32 -> 64)
  logic signed [63:0] rs1_sext64, rs2_sext64;
  logic        [63:0] rs1_zext64, rs2_zext64;

  always_comb begin
    rs1_sext64 = {{32{rs1_data[31]}}, rs1_data};
    rs2_sext64 = {{32{rs2_data[31]}}, rs2_data};
    rs1_zext64 = {32'd0, rs1_data};
    rs2_zext64 = {32'd0, rs2_data};
  end

  logic signed [63:0] prod_ss; //signed*signed full 64b product
  logic signed [63:0] prod_su; //signed*unsigned full 64b product
  logic        [63:0] prod_uu; //unsigned*unsigned full 64b product

  always_comb begin
    prod_ss = rs1_sext64 * rs2_sext64;
    // unsigned operand must be zero-extended so we treat it as positive signed 64
    prod_su = rs1_sext64 * $signed(rs2_zext64);
    prod_uu = rs1_zext64 * rs2_zext64;
  end

  // Signed div/rem helpers
  logic rs2_is_zero;
  logic signed_overflow_div; // INT_MIN / -1
  assign rs2_is_zero = (rs2_data == 32'd0);
  assign signed_overflow_div =
  ($signed(rs1_data) == 32'sh8000_0000) &&
  ($signed(rs2_data) == 32'shFFFF_FFFF); // -1 in two's complement


  always_comb begin
    illegal_insn = 1'b0;
    write = 1'b0;
    rd_data = '0;
    a = '0;
    b = '0;
    halt = 1'b0;
    cin = 1'b0;

    //give pc a default
    pcNext = pcCurrent + 32'd4;


    //drive dmem outputs to avoid X propagation
    addr_to_dmem = 32'd0;
    store_data_to_dmem = 32'd0;
    store_we_to_dmem = 4'b0000;

    // defaults to avoid inferred latches bc Verilator treats latch warnings as errors
    byte_off = 2'b00;
    byte_off_s = 2'b00;
    word = 32'd0;

    trace_completed_pc = pcCurrent;
    trace_completed_insn = insn_from_imem;
    trace_completed_cycle_status = CYCLE_NO_STALL;

    case (insn_opcode)
      OpLoad: begin
        // addr = rs1 + imm_i
        a = rs1_data;
        b = imm_i_sext;
        addr_to_dmem = temp_sum;
        byte_off = addr_to_dmem[1:0];
        word = load_data_from_dmem;

        if (insn_lw) begin
          write = 1'b1;
          rd_data = word;
        end else if (insn_lb) begin
          write = 1'b1;
        unique case (byte_off)
          2'd0: rd_data = {{24{word[7]}},  word[7:0]};
          2'd1: rd_data = {{24{word[15]}}, word[15:8]};
          2'd2: rd_data = {{24{word[23]}}, word[23:16]};
          2'd3: rd_data = {{24{word[31]}}, word[31:24]};
        endcase
      end else if (insn_lbu) begin
        write = 1'b1;
        unique case (byte_off)
          2'd0: rd_data = {24'd0, word[7:0]};
          2'd1: rd_data = {24'd0, word[15:8]};
          2'd2: rd_data = {24'd0, word[23:16]};
          2'd3: rd_data = {24'd0, word[31:24]};
        endcase
      end else if (insn_lh) begin
        write = 1'b1;
        // halfword uses byte_off[1]
        if (byte_off[1] == 1'b0)
          rd_data = {{16{word[15]}}, word[15:0]};
        else
          rd_data = {{16{word[31]}}, word[31:16]};
      end else if (insn_lhu) begin
          write = 1'b1;
          if (byte_off[1] == 1'b0)
            rd_data = {16'd0, word[15:0]};
          else
          rd_data = {16'd0, word[31:16]};
          end else begin
          illegal_insn = 1'b1;
        end
      end
      OpStore: begin
        // addr = rs1 + imm_s
        a = rs1_data;
        b = imm_s_sext;
        addr_to_dmem = temp_sum;
        byte_off_s = addr_to_dmem[1:0];

        if (insn_sw) begin
          store_data_to_dmem = rs2_data;
          store_we_to_dmem = 4'b1111;
        end else if (insn_sb) begin
        // write 1 byte into the selected lane
        store_data_to_dmem = {4{rs2_data[7:0]}}; // replicated; only enabled lane matters
        unique case (byte_off_s)
          2'd0: store_we_to_dmem = 4'b0001;
          2'd1: store_we_to_dmem = 4'b0010;
          2'd2: store_we_to_dmem = 4'b0100;
          2'd3: store_we_to_dmem = 4'b1000;
        endcase
      end else if (insn_sh) begin
      // write 2 bytes; choose lower or upper halfword lane
        store_data_to_dmem = {2{rs2_data[15:0]}};
        if (byte_off_s[1] == 1'b0)
          store_we_to_dmem = 4'b0011; // bytes 0,1
        else
          store_we_to_dmem = 4'b1100; // bytes 2,3
      end else begin
        illegal_insn = 1'b1;
      end
      end
      OpAuipc: begin
        write = 1'b1;
        a = pcCurrent;
        b = {insn_from_imem[31:12], 12'b0};
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
        pcNext = temp_sum & 32'hFFFF_FFFE; // clear bit 0
      end

      OpLui: begin
        write = 1'd1;
        rd_data = insn_from_imem[31:12] << 12;
        pcNext = pcCurrent + 4;
      end
      OpRegImm: begin
        if (insn_addi) begin
          write = 1'd1;
          a = rs1_data;
          b = imm_i_sext;
          rd_data = temp_sum;
          pcNext = pcCurrent + 4;
        end
        else if (insn_slti) begin
          write = 1'd1;
          if ($signed(rs1_data) < $signed(imm_i_sext)) begin
            rd_data = 1;
          end else begin
            rd_data = '0;
          end
          pcNext = pcCurrent + 4;
        end
        else if (insn_sltiu) begin
          write = 1'd1;
          if (rs1_data < imm_i_sext) begin
            rd_data = 1;
          end else begin
            rd_data = '0;
          end
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
        else begin
          pcNext = pcCurrent + 4;
        end
      end
      OpBranch: begin
        if (insn_bne) begin
          if (rs1_data != rs2_data) begin
            pcNext = pcCurrent + imm_b_sext;
          end else begin
            pcNext = pcCurrent + 4;
          end 
        end else if (insn_beq) begin
          if (rs1_data == rs2_data) begin
            pcNext = pcCurrent + imm_b_sext;
          end else begin
            pcNext = pcCurrent + 4;
          end 
        end
        else if (insn_blt) begin
          if ($signed(rs1_data) < $signed(rs2_data)) begin
            pcNext = pcCurrent + imm_b_sext;
          end else begin
            pcNext = pcCurrent + 4;
          end 
        end
        else if (insn_bltu) begin
          if (rs1_data < rs2_data) begin
            pcNext = pcCurrent + imm_b_sext;
          end else begin
            pcNext = pcCurrent + 4;
          end 
        end
        else if (insn_bge) begin
          if ($signed(rs1_data) >= $signed(rs2_data)) begin
            pcNext = pcCurrent + imm_b_sext;
          end else begin
            pcNext = pcCurrent + 4;
          end 
        end
        else if (insn_bgeu) begin
          if (rs1_data >= rs2_data) begin
            pcNext = pcCurrent + imm_b_sext;
          end else begin
            pcNext = pcCurrent + 4;
          end 
        end
        else begin
          pcNext = pcCurrent + 4;
        end
      end
      OpEnviron: begin
        if (insn_ecall) halt = 1'b1;
        else illegal_insn = 1'b1;
      end
       OpRegReg: begin
        if (insn_add) begin
          write = 1'd1;
          a = rs1_data;
          b = rs2_data;
          rd_data = temp_sum;
          pcNext = pcCurrent + 4;
        end
        else if (insn_slt) begin
          write = 1'd1;
          if ($signed(rs1_data) < $signed(rs2_data)) begin
            rd_data = 1;
          end else begin
            rd_data = '0;
          end
          pcNext = pcCurrent + 4;
        end
        else if (insn_sltu) begin
          write = 1'd1;
          if (rs1_data < rs2_data) begin
            rd_data = 1;
          end else begin
            rd_data = '0;
          end
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
          rd_data = prod_ss[31:0];// low 32 bits
          pcNext = pcCurrent + 4;
        end
        else if (insn_mulh) begin
          write = 1'b1;
          rd_data = prod_ss[63:32];// high 32 bits signed*signed
          pcNext = pcCurrent + 4;
        end
        else if (insn_mulhsu) begin
          write = 1'b1;
          rd_data = prod_su[63:32];// high 32 bits signed*unsigned
          pcNext = pcCurrent + 4;
        end
        else if (insn_mulhu) begin
          write = 1'b1;
          rd_data = prod_uu[63:32]; // high 32 bits unsigned*unsigned
          pcNext = pcCurrent + 4;
        end

        else if (insn_divu) begin
          write = 1'b1;
          // RISC-V: div by 0 => all 1s
          rd_data = rs2_is_zero ? 32'hFFFF_FFFF : divu_quot;
          pcNext = pcCurrent + 4;
        end
        else if (insn_remu) begin
          write = 1'b1;
          // RISC-V: rem by 0 => dividend
          rd_data = rs2_is_zero ? rs1_data : divu_rem;
          pcNext = pcCurrent + 4;
        end

        else if (insn_div) begin
          write = 1'b1;
          if (rs2_is_zero) begin
            // div by 0 => -1
            rd_data = 32'hFFFF_FFFF;
          end else if (signed_overflow_div) begin
            // INT_MIN / -1 => INT_MIN
            rd_data = 32'h8000_0000;
          end else begin
            rd_data = quot_signed;
          end
          pcNext = pcCurrent + 4;
        end
        else if (insn_rem) begin
          write = 1'b1;
          if (rs2_is_zero) begin
            // rem by 0 => dividend
            rd_data = rs1_data;
          end else if (signed_overflow_div) begin
            // INT_MIN % -1 => 0
            rd_data = 32'd0;
          end else begin
            rd_data = rem_signed;
          end
          pcNext = pcCurrent + 4;
        end
        else begin
          pcNext = pcCurrent + 4;
        end
        
      end
      OpMiscMem: begin
      // treat FENCE as a no-op
        pcNext = pcCurrent + 4;
      end
      
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

endmodule

/* A memory module that supports 1-cycle reads and writes, with one read-only port
 * and one read+write port.
 */
module MemorySingleCycle #(
    parameter int NUM_WORDS = 512
) (
    // rst for both imem and dmem
    input wire rst,

    // clock for both imem and dmem. See RiscvProcessor for clock details.
    input wire clock_mem,

    // must always be aligned to a 4B boundary
    input wire [`REG_SIZE] pc_to_imem,

    // the value at memory location pc_to_imem
    output logic [`INSN_SIZE] insn_from_imem,

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

  wire [`REG_SIZE] addr_to_dmem_aligned = {addr_to_dmem[31:2], 2'b00};
  always_comb begin
    // memory addresses should always be 4B-aligned
    assert (pc_to_imem[1:0] == 2'b00);
  end

  localparam int AddrMsb = $clog2(NUM_WORDS) + 1;
  localparam int AddrLsb = 2;

  always @(posedge clock_mem) begin
    if (rst) begin
    end else begin
      insn_from_imem <= mem_array[{pc_to_imem[AddrMsb:AddrLsb]}];
    end
  end

  always @(negedge clock_mem) begin
    if (rst) begin
    end else begin
      if (store_we_to_dmem[0]) begin
        mem_array[addr_to_dmem_aligned[AddrMsb:AddrLsb]][7:0] <= store_data_to_dmem[7:0];
      end
      if (store_we_to_dmem[1]) begin
        mem_array[addr_to_dmem_aligned[AddrMsb:AddrLsb]][15:8] <= store_data_to_dmem[15:8];
      end
      if (store_we_to_dmem[2]) begin
        mem_array[addr_to_dmem_aligned[AddrMsb:AddrLsb]][23:16] <= store_data_to_dmem[23:16];
      end
      if (store_we_to_dmem[3]) begin
        mem_array[addr_to_dmem_aligned[AddrMsb:AddrLsb]][31:24] <= store_data_to_dmem[31:24];
      end
      // dmem is "read-first": read returns value before the write
      load_data_from_dmem <= mem_array[{addr_to_dmem_aligned[AddrMsb:AddrLsb]}];
    end
  end
endmodule

/*
This shows the relationship between clock_proc and clock_mem. The clock_mem is
phase-shifted 90° from clock_proc. You could think of one proc cycle being
broken down into 3 parts. During part 1 (which starts @posedge clock_proc)
the current PC is sent to the imem. In part 2 (starting @posedge clock_mem) we
read from imem. In part 3 (starting @negedge clock_mem) we read/write memory and
prepare register/PC updates, which occur at @posedge clock_proc.

        ____
 proc: |    |______
           ____
 mem:  ___|    |___
*/
module Processor (
    input wire               clock_proc,
    input wire               clock_mem,
    input wire               rst,
    output wire [`REG_SIZE]  trace_completed_pc,
    output wire [`INSN_SIZE] trace_completed_insn,
    output cycle_status_e    trace_completed_cycle_status, 
    output logic             halt
);

  wire [`REG_SIZE] pc_to_imem, mem_data_addr, mem_data_loaded_value, mem_data_to_write;
  wire [`INSN_SIZE] insn_from_imem;
  wire [3:0] mem_data_we;

  // This wire is set by cocotb to the name of the currently-running test, to make it easier
  // to see what is going on in the waveforms.
  wire [(8*32)-1:0] test_case;

  MemorySingleCycle #(
      .NUM_WORDS(8192)
  ) memory (
      .rst      (rst),
      .clock_mem (clock_mem),
      // imem is read-only
      .pc_to_imem(pc_to_imem),
      .insn_from_imem(insn_from_imem),
      // dmem is read-write
      .addr_to_dmem(mem_data_addr),
      .load_data_from_dmem(mem_data_loaded_value),
      .store_data_to_dmem (mem_data_to_write),
      .store_we_to_dmem  (mem_data_we)
  );

  DatapathSingleCycle datapath (
      .clk(clock_proc),
      .rst(rst),
      .pc_to_imem(pc_to_imem),
      .insn_from_imem(insn_from_imem),
      .addr_to_dmem(mem_data_addr),
      .store_data_to_dmem(mem_data_to_write),
      .store_we_to_dmem(mem_data_we),
      .load_data_from_dmem(mem_data_loaded_value),
      .trace_completed_pc(trace_completed_pc),
      .trace_completed_insn(trace_completed_insn),
      .trace_completed_cycle_status(trace_completed_cycle_status),
      .halt(halt)
  );

endmodule
