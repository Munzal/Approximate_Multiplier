module HA(
    output Sum,
    output Carry,
    input A,
    input B
);
    assign Sum = A&(~B) | (~A)&B;
    assign Carry = A & B;
endmodule

module HA_NC(
    output Sum,
    input A,
    input B
);
    assign Sum = A&(~B) | (~A)&B;
endmodule
//Full Adder with Non carry
module FA_NC(
    output Sum,
    input A,
    input B,
    input C
);
    wire I;
    assign I = (~A)&B | A&(~B);
    assign Sum = (~I)&C | I&(~C);

endmodule


module FA(
    output Sum,
    output Carry,
    input A,
    input B,
    input C
);
    wire I;
    assign I = (~A)&B | A&(~B);
    assign Sum = (~I)&C | I&(~C);
    assign Carry = A&B | C&I;

endmodule

module mux(out, in0, in1, sel);
    input in0, in1, sel;
    output reg out;
    
    always@(*)
    begin
        if(sel == 1'b0)
            out <= in0;
        else
            out <= in1;
    end
endmodule

module Compressor(sum_out, carry, A, B, C, D);
    input A, B, C, D;
    output sum_out, carry;
    
    wire w1, w2, w3, w4, w5;
    
    mux m1(w1, B, 1'b1, C);
    mux m2(w2, D, 1'b1, A);
    mux m3(w3, 1'b0, w1, w2);
    mux m4(w4, 1'b0, B, C);
    mux m5(w5, 1'b0, A, D);
    mux m6(w6, w4, 1'b1, w5);
    mux m7(carry, w3, 1'b1, w6);
    
    wire t1, t2, t3;
    wire Dn, Cn, t2n;
    
    not n1(Dn, D);
    not n2(t2n, t2);
    not n3(Cn, C);
    
    mux s1(t1, 1'b0, Dn, A);
    mux s2(t2, C, Cn, D);
    mux s3(t3, t2, t2n, B);
    mux s4(sum_out, t1, 1'b1, t3);
    
endmodule


module multiplier(
    output [14:0] w,
    input [7:0] num1,
    input [7:0] num2
);
    wire a[7:0][7:0];
    genvar i,j;

    //level 1
    generate
        for(i=0; i<8; i=i+1)
        begin
            for(j=0; j<8; j=j+1)
            begin
                assign a[i][j] = num1[i] & num2[j];
            end
        end
    endgenerate
    //level 2
    
    wire p[7:0][7:0];
    wire g[7:0][7:0];
    assign p[2][1] = a[2][1] | a[1][2];
    assign g[2][1] = a[2][1] & a[1][2];
    generate
        for(i=3; i<7; i=i+1)
        begin
            for(j=0; j<i; j=j+1)
            begin
                assign p[i][j] = a[i][j] | a[j][i];
                assign g[i][j] = a[i][j] & a[j][i];
            end
        end
    endgenerate
    generate
        for(j=0;j<5;j=j+1)
        begin
            assign p[7][j] = a[7][j] | a[j][7];
            assign g[7][j] = a[7][j] & a[j][7];
        end
    endgenerate
    
    //level 3
    wire r1[10:0], r2[10:0], r3[10:0];

    assign r1[0] = p[3][0];
    assign r2[0] = p[2][1];

    HA          h1(r1[1], r3[2], p[4][0], p[3][1]);
    FA          f1(r1[2], r3[3], p[5][0], p[4][1], p[3][2]);
    Compressor  c1(r1[3], r3[4], p[6][0], p[5][1], p[4][2], a[3][3]);
    Compressor  c2(r1[4], r3[5], p[7][0], p[6][1], p[5][2], p[4][3]);
    Compressor  c3(r1[5], r3[6], p[7][1], p[6][2], p[5][3], a[4][4]);
    FA          f2(r1[6], r3[7], p[7][2], p[6][3], p[5][4]);
    FA          f3(r1[7], r3[8], p[7][3], p[6][4], a[5][5]);
    HA          h2(r1[8], r2[9], p[7][4], p[6][5]);
    HA          h3(r1[9], r3[10],a[7][5], a[5][7]);

    assign r1[10] = a[7][6];
    assign r2[10] = a[6][7];
    assign r3[9] = a[6][6];
    assign r3[0] = g[3][0] | g[2][1];
    assign r3[1] = g[4][0] | g[3][1];

    assign r2[1] = a[2][2];
    assign r2[2] = g[5][0] | g[4][1] | g[3][2];
    assign r2[3] = g[6][0] | g[5][1] | g[4][2];
    assign r2[4] = g[7][0] | g[6][1] | g[5][2] | g[4][3];
    assign r2[5] = g[7][1] | g[6][2] | g[5][3];
    assign r2[6] = g[7][2] | g[6][3] | g[5][4];
    assign r2[7] = g[7][3] | g[6][4];
    assign r2[8] = g[7][4] | g[6][5];
    assign r2[10] = a[6][7];

    //level 4
    //wire w[14:0];
    assign w[0] = a[0][0];
    assign w[1] = a[1][0] | a[0][1];//instead of Approx half adder we use OR gate
    wire [14:0] cll;//carry last level
    wire [13:0] d;
    FA       fn01(d[2], cll[3], a[2][0], a[0][2], a[1][1]);
    FA       fn02(d[3], cll[4], r1[0], r2[0], r3[0]);
    FA       fn03(d[4], cll[5], r1[1], r2[1], r3[1]);
    FA       fn04(d[5], cll[6], r1[2], r2[2], r3[2]);
    FA       fn05(d[6], cll[7], r1[3], r2[3], r3[3]);
    FA       fn06(d[7], cll[8], r1[4], r2[4], r3[4]);
    FA       fn07(d[8], cll[9], r1[5], r2[5], r3[5]);
    FA       fn08(d[9], cll[10], r1[6], r2[6], r3[6]);
    FA       fn09(d[10], cll[11], r1[7], r2[7], r3[7]);
    FA       fn10(d[11], cll[12], r1[8], r2[8], r3[8]);
    FA       fn11(d[12], cll[13], r1[9], r2[9], r3[9]);
    FA       fn12(d[13], cll[14], r1[10], r2[10], r3[10]);

    HA_NC      ka01(w[2], d[2], 1'b0);
    HA_NC      ka02(w[3], d[3], cll[3]);
    HA_NC      ka03(w[4], d[4], cll[4]);
    HA_NC      ka04(w[5], d[5], cll[5]);
    HA_NC      ka05(w[6], d[6], cll[6]);
    HA_NC      ka06(w[7], d[7], cll[7]);
    HA_NC      ka07(w[8], d[8], cll[8]);
    HA_NC      ka08(w[9], d[9], cll[9]);
    HA_NC      ka09(w[10], d[10], cll[10]);
    HA_NC      ka10(w[11], d[11], cll[11]);
    HA_NC      ka11(w[12], d[12], cll[12]);
    HA_NC      ka12(w[13], d[13], cll[13]);
    
    assign w[14] = a[7][7] | cll[14];

endmodule