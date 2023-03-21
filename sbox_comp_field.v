// Author: Aritra Sen
// Roll no.: 19ME10101
// Project Description: AES Canright S-box

module mul_gf_4(
    input [1:0] in_1,
    input [1:0] in_2,
    output [1:0] out
);
wire w1, w2, w3;
assign w1 = (in_1[0] ^ in_1[1]) & (in_2[0] ^ in_2[1]);
assign w2 = (in_1[0] & in_2[0]) ^ w1;
assign w3 = (in_1[1] & in_2[1]) ^ w1;
assign out = {w3, w2};
endmodule

module scale_gf_4(
    input [1:0] in,
    output [1:0] out
);
assign out = {in[0], in[0] ^ in[1]};
endmodule

module scale_sq_gf_4(
    input [1:0] in,
    output [1:0] out
);
assign out = {in[0] ^ in[1], in[1]};
endmodule

module inv_gf_4(
    input [1:0] in,
    output [1:0] out
);
assign out = {in[0], in[1]};
endmodule

module mul_gf_16(
    input [3:0] in_1,
    input [3:0] in_2,
    output [3:0] out
);
wire [1:0] in_1_h, in_1_l, in_2_h, in_2_l, w1, w2, wll, whh;
assign in_1_h = in_1[3:2];
assign in_1_l = in_1[1:0];
assign in_2_h = in_2[3:2];
assign in_2_l = in_2[1:0];
mul_gf_4 mul1(.in_1(in_1_l^in_1_h), .in_2(in_2_h^in_2_l), .out(w1));
scale_gf_4 scl(.in(w1), .out(w2));
mul_gf_4 mul2(.in_1(in_1_l), .in_2(in_2_l), .out(wll));
mul_gf_4 mul3(.in_1(in_1_h), .in_2(in_2_h), .out(whh));
assign out = {whh ^ w2, wll ^ w2};
endmodule

module sq_scale_gf_16(
    input [3:0] in,
    output [3:0] out
);
wire [1:0] w1, w2, w3;
inv_gf_4 inv1(.in(in[3:2] ^ in[1:0]), .out(w1));
inv_gf_4 inv2(.in(in[1:0]), .out(w2));
scale_sq_gf_4 scl(.in(w2), .out(w3));
assign out= {w1, w3};
endmodule

module inv_gf_16(
    input [3:0] in,
    output [3:0] out
);
wire [1:0] in_h, in_l, w0, w1, w2, w3, o1, o2;
assign in_h = in[3:2];
assign in_l = in[1:0];
inv_gf_4 inv1(.in(in_h ^ in_l), .out(w0));
scale_gf_4 scl(.in(w0), .out(w1));
mul_gf_4 mul1(.in_1(in_l), .in_2(in_h), .out(w2));
inv_gf_4 inv2(.in(w1 ^ w2), .out(w3));
mul_gf_4 mul2(.in_1(w3), .in_2(in_l), .out(o1));
mul_gf_4 mul3(.in_1(w3), .in_2(in_h), .out(o2));
assign out = {o1, o2};
endmodule

module inv_gf_256(
    input [7:0] in,
    output [7:0] out
);
wire [3:0] in_h, in_l, w1, w2, w3, o0, o1;
assign in_h = in[7:4];
assign in_l = in[3:0];
sq_scale_gf_16 sqscl(.in(in_h ^ in_l), .out(w1));
mul_gf_16 mul1(.in_1(in_h), .in_2(in_l), .out(w2));
inv_gf_16 inv(.in(w1 ^ w2), .out(w3));
mul_gf_16 mul2(.in_1(w3), .in_2(in_l), .out(o0));
mul_gf_16 mul3(.in_1(w3), .in_2(in_h), .out(o1));
assign out = {o0, o1};
endmodule

module sbox(
    input [7:0] A,
    output [7:0] S
);
wire [7:0] AtoX, X;
wire x65, x10, s53, s60, s41;
assign x65 = A[6] ^ A[5];
assign x10 = A[1] ^ A[0];
assign AtoX[7] = A[7] ^ x65 ^ A[2] ^ x10;
assign AtoX[6] = x65 ^ A[4] ^ A[0];
assign AtoX[5] = x65 ^ x10;
assign AtoX[4] = A[7] ^ x65 ^ A[0];
assign AtoX[3] = A[7] ^ A[4] ^ A[3] ^ x10;
assign AtoX[2] = A[0];
assign AtoX[1] = x65 ^ A[0];
assign AtoX[0] = A[6] ^ A[3] ^ A[2] ^ x10;
inv_gf_256 inv256(.in(AtoX), .out(X));
assign s53 = X[5] ^ X[3];
assign s60 = X[6] ^ X[0];
assign s41 = X[4] ^ X[1] ^ 1'b1;
assign S[7] = s53;
assign S[6] = X[7] ^ X[3] ^ 1'b1;
assign S[5] = s60 ^ 1'b1;
assign S[4] = X[7] ^ s53;
assign S[3] = X[7] ^ X[6] ^ X[4] ^ s53;
assign S[2] = X[2] ^ s53 ^ s60;
assign S[1] = X[5] ^ s41;
assign S[0] = X[6] ^ s41;
endmodule
