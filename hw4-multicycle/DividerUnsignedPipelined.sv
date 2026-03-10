`timescale 1ns / 1ns

module DividerUnsignedPipelined (
    input wire clk, rst, stall,
    input  wire  [31:0] i_dividend,
    input  wire  [31:0] i_divisor,
    output logic [31:0] o_remainder,
    output logic [31:0] o_quotient
);
    logic [31:0] dividend_pipe  [1:7];
    logic [31:0] divisor_pipe   [1:7];
    logic [31:0] remainder_pipe [1:7];
    logic [31:0] quotient_pipe  [1:7];

    genvar stage;
    generate
        for (stage = 0; stage < 8; stage = stage + 1) begin : stages
            logic [31:0] d [0:4];
            logic [31:0] r [0:4];
            logic [31:0] q [0:4];
            logic [31:0] stage_divisor;

            if (stage == 0) begin : first_stage
                assign d[0] = i_dividend;
                assign r[0] = 32'd0;
                assign q[0] = 32'd0;
                assign stage_divisor = i_divisor;
            end else begin : later_stages
                assign d[0] = dividend_pipe[stage];
                assign r[0] = remainder_pipe[stage];
                assign q[0] = quotient_pipe[stage];
                assign stage_divisor = divisor_pipe[stage];
            end

            for (genvar i = 0; i < 4; i = i + 1) begin : div_alg_iters
                divu_1iter iter (
                    .i_dividend  (d[i]),
                    .i_divisor   (stage_divisor),
                    .i_remainder (r[i]),
                    .i_quotient  (q[i]),
                    .o_dividend  (d[i+1]),
                    .o_remainder (r[i+1]),
                    .o_quotient  (q[i+1])
                );
            end

            if (stage < 7) begin : intermediate_stage
                always_ff @(posedge clk) begin
                    if (rst) begin
                        dividend_pipe [stage+1] <= 32'd0;
                        divisor_pipe  [stage+1] <= 32'd0;
                        remainder_pipe[stage+1] <= 32'd0;
                        quotient_pipe [stage+1] <= 32'd0;
                    end else begin
                        dividend_pipe [stage+1] <= d[4];
                        divisor_pipe  [stage+1] <= stage_divisor;
                        remainder_pipe[stage+1] <= r[4];
                        quotient_pipe [stage+1] <= q[4];
                    end
                end
            end else begin : last_stage
                assign o_quotient  = q[4];
                assign o_remainder = r[4];
            end
        end
    endgenerate

endmodule



module divu_1iter (
    input  wire  [31:0] i_dividend,
    input  wire  [31:0] i_divisor,
    input  wire  [31:0] i_remainder,
    input  wire  [31:0] i_quotient,
    output logic [31:0] o_dividend,
    output logic [31:0] o_remainder,
    output logic [31:0] o_quotient
);
     wire dividend_msb_bit;
    wire [31:0] remainder_after_shift;
    wire remainder_less_than_divisor;

    // we take MSB of dividend
    assign dividend_msb_bit = i_dividend[31];

    // we shift remainder left and bring in dividend MSB
    assign remainder_after_shift = {i_remainder[30:0], dividend_msb_bit};

    // now we compare remainder to divisor 
    assign remainder_less_than_divisor = (remainder_after_shift < i_divisor);

    //update quotient
    assign o_quotient = remainder_less_than_divisor ? (i_quotient << 1) : ((i_quotient << 1) | 32'b1);

    // we update remainder to be from pseudocode c above remainder = remainder - divisor when satisfying the else condition
    assign o_remainder = remainder_less_than_divisor ? remainder_after_shift : (remainder_after_shift - i_divisor);

    //shift dividend left for next iteration
    assign o_dividend = i_dividend << 1;

endmodule
