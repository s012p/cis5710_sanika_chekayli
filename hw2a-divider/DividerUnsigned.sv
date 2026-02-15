/* INSERT NAME AND PENNKEY HERE */

`timescale 1ns / 1ns

// quotient = dividend / divisor

module DividerUnsigned (
    input  wire [31:0] i_dividend,
    input  wire [31:0] i_divisor,
    output wire [31:0] o_remainder,
    output wire [31:0] o_quotient
);

    // TODO: your code here

    //pipeline wires for each iter
    wire [31:0] dividend_pipe [0:32];
    wire [31:0] remainder_pipe [0:32];
    wire [31:0] quotient_pipe [0:32];

    //initial values: before our 1st iter
    assign dividend_pipe[0] = i_dividend;
    assign remainder_pipe[0] = 32'b0;
    assign quotient_pipe[0] = 32'b0;

    genvar iter;
    generate 
        for (iter = 0; iter < 32; iter = iter + 1) begin : gen_div_iter 
        DividerOneIter step (
            .i_dividend (dividend_pipe[iter]),
            .i_divisor (i_divisor),
            .i_remainder (remainder_pipe[iter]),
            .i_quotient (quotient_pipe [iter]),
            .o_dividend (dividend_pipe[iter+1]),
            .o_remainder (remainder_pipe[iter + 1]),
            .o_quotient (quotient_pipe[iter + 1])
        );
    end
    endgenerate

    // final outputs 
    assign o_remainder = remainder_pipe[32];
    assign o_quotient = quotient_pipe[32];

endmodule


module DividerOneIter (
    input  wire [31:0] i_dividend,
    input  wire [31:0] i_divisor,
    input  wire [31:0] i_remainder,
    input  wire [31:0] i_quotient,
    output wire [31:0] o_dividend,
    output wire [31:0] o_remainder,
    output wire [31:0] o_quotient
);
  /*
    for (int i = 0; i < 32; i++) {
        remainder = (remainder << 1) | ((dividend >> 31) & 0x1);
        if (remainder < divisor) {
            quotient = (quotient << 1);
        } else {
            quotient = (quotient << 1) | 0x1;
            remainder = remainder - divisor;
        }
        dividend = dividend << 1;
    }
    */

    // TODO: your code here
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
