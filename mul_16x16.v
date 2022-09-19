`include "multiplier.v"

module mul_16x16(
    output [31:0] prod32,
    input [15:0] num16_1,
    input [15:0] num16_2
);
    wire [7:0] n1_l;
    wire [7:0] n1_h;
    wire [7:0] n2_l;
    wire [7:0] n2_h;

    assign {n1_h, n1_l} = num16_1;
    assign {n2_h, n2_l} = num16_2;

    wire [14:0] op_1, op_2, op_3, op_4;

    multiplier mp_1(op_1, n1_l, n2_l);
    multiplier mp_2(op_2, n1_h, n2_l);
    multiplier mp_3(op_3, n1_l, n2_h);
    multiplier mp_4(op_4, n1_h, n2_h);

    //for testing using data flow

    wire [7:0] k1 = op_1[7:0]; 
    wire [7:0] k2 = op_1[14:8] + op_2[7:0] + op_3[7:0];
    wire [7:0] k3 = op_2[14:8] + op_3[14:8] + op_4[7:0];
    wire [7:0] k4 = {1'b0,op_4[14:8]};

    assign prod32 = {k4, k3, k2, k1};

endmodule