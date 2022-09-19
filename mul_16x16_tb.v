`timescale 1 ns / 1 ns
`include "mul_16x16.v"

module mul_16x16_tb();
    wire [31:0] out;
    reg [15:0] in0;
    reg [15:0] in1;
    reg [31:0] actual;
    real diff;

    mul_16x16 FEB(out, in0, in1);
    integer MCD1;

    initial begin
        $dumpfile("mul_16x16_tb.vcd");
        $dumpvars(0, mul_16x16_tb);
        MCD1 = $fopen("result.txt");
        in1 = 16'd2134;
        for(in0 = 16'd1024; in0 < 16'd1064; in0 = in0+1)
        begin
            #5;
            actual = in0 * in1;
            if(actual > out)
                diff = actual - out;
            else
                diff = out - actual;
            diff = diff/out * 100; 
            $display("Num1 = %d, Num2 = %d, Prod = %d, Actual = %d, Error = %f", in0, in1, out, actual, diff);
            $fdisplay(MCD1, "%d, %d, %d, %d, %f", in0, in1, out, actual, diff);
        end
        $fclose(MCD1);
    end

    initial begin
        #1000;
        $finish;
    end

endmodule

/*
iverilog -o mul_16x16_tb.vvp mul_16x16_tb.v
vvp mul_16x16_tb.vvp
gtkwave
*/