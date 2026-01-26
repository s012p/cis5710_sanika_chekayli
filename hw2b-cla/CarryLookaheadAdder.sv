`timescale 1ns / 1ps

/**
 * @param a first 1-bit input
 * @param b second 1-bit input
 * @param g whether a and b generate a carry
 * @param p whether a and b would propagate an incoming carry
 */
module gp1(input wire a, b,
           output wire g, p);
   assign g = a & b;
   assign p = a | b;
endmodule

/**
 * Computes aggregate generate/propagate signals over a 4-bit window.
 * @param gin incoming generate signals
 * @param pin incoming propagate signals
 * @param cin the incoming carry
 * @param gout whether these 4 bits internally would generate a carry-out (independent of cin)
 * @param pout whether these 4 bits internally would propagate an incoming carry from cin
 * @param cout the carry outs for the low-order 3 bits
 */
module gp4(input wire [3:0] gin, pin,
           input wire cin,
           output wire gout, pout,
           output wire [2:0] cout);

   // your code here

   //bit carry: c0 = cin, cout [0 ... 2]
   wire c0;
   assign c0 = cin;

   assign cout[0] = gin[0] | (pin[0] & c0);
   assign cout[1] = gin[1] | (pin[1] & gin[0]) | (pin[1] & pin[0] & c0);
   assign cout[2] = gin[2] | (pin[2] & gin[1]) | (pin[2] & pin[1] & gin[0]) | (pin[2] & pin[1] & pin[0] &c0);

   //generate over 4 bits
   assign pout = &pin; // we have pin[3]&pin[2]&pin[1]&pin[0]

   assign gout = gin [3] | (pin[3] & gin[2]) | (pin[3] & pin[2] & gin[1]) | (pin[3] & pin[2] & pin[1] & gin[0]);
endmodule

/** Same as gp4 but for an 8-bit window instead */
module gp8(input wire [7:0] gin, pin,
           input wire cin,
           output wire gout, pout,
           output wire [6:0] cout);

   // your code here
   wire c1, c2, c3, c4, c5, c6, c7;

   // internal carries (carry into bit i+1), with c0 = cin
   assign c1 = gin[0] | (pin[0] & cin);
   assign c2 = gin[1] | (pin[1] & c1);
   assign c3 = gin[2] | (pin[2] & c2);
   assign c4 = gin[3] | (pin[3] & c3);
   assign c5 = gin[4] | (pin[4] & c4);
   assign c6 = gin[5] | (pin[5] & c5);
   assign c7 = gin[6] | (pin[6] & c6);

   // cout[k] = carry into bit (k+1) within this 8-bit slice
   assign cout = {c7, c6, c5, c4, c3, c2, c1};

   // pout = group propagate (all bits propagate a carry through)
   assign pout = &pin;

   // gout = group generate (slice produces carry-out regardless of cin)
   assign gout = gin[7]
               | (pin[7] & gin[6])
               | (pin[7] & pin[6] & gin[5])
               | (pin[7] & pin[6] & pin[5] & gin[4])
               | (pin[7] & pin[6] & pin[5] & pin[4] & gin[3])
               | (pin[7] & pin[6] & pin[5] & pin[4] & pin[3] & gin[2])
               | (pin[7] & pin[6] & pin[5] & pin[4] & pin[3] & pin[2] & gin[1])
               | (pin[7] & pin[6] & pin[5] & pin[4] & pin[3] & pin[2] & pin[1] & gin[0]);
endmodule

module CarryLookaheadAdder
  (input wire [31:0]  a, b,
   input wire         cin,
   output wire [31:0] sum);

   // your code here
      //High level code logic:
      // 1. compute bit-level g/p for all 32 bits
      // 2. split into four 8-bit blocks; each gp8 produces (G,P) for its block + internal carries
      // 3. run a top gp4 over the four block (G,P) pairs to get carries into blocks 1..3
      // 4. assemble carry-in per bit, then sum = a ^ b ^ carry_in

   wire [31:0] g, p;

   //1.
   genvar i;
   generate 
      for (i = 0; i < 32; i = i + 1) begin : gpP
         gp1 u(.a(a[i]), .b(b[i]), .g(g[i]), .p(p[i]));
      end
   endgenerate

   wire [3:0] g8, p8;
   wire [2:0] cblk;
   wire [6:0] c0, c1, c2, c3;
   wire dg, dp;

   //2.
   gp8 b0(.gin(g[7:0]), .pin(p[7:0]), .cin(cin), .gout(g8[0]), .pout(p8[0]), .cout(c0));
   gp8 b1(.gin(g[15:8]), .pin(p[15:8]), .cin(cblk[0]), .gout(g8[1]), .pout(p8[1]), .cout(c1));
   gp8 b2(.gin(g[23:16]), .pin(p[23:16]), .cin(cblk[1]), .gout(g8[2]), .pout(p8[2]), .cout(c2));
   gp8 b3(.gin(g[31:24]), .pin(p[31:24]), .cin(cblk[2]), .gout(g8[3]), .pout(p8[3]), .cout(c3));

   //3.
   gp4 top(.gin(g8), .pin(p8), .cin(cin), .gout(dg), .pout(dp), .cout(cblk));

   //4.
   wire [31:0] c_in;
   assign {c_in[31:25], c_in[24], c_in[23:17], c_in[16], c_in[15:9], c_in[8], c_in[7:1], c_in[0]} = {c3, cblk[2], c2, cblk[1], c1, cblk[0], c0, cin};

   assign sum = a ^ b ^ c_in;
endmodule
