`timescale 1ns / 1ns
`include "conventional_multiplier.v"
module conventional_multiplier_tb();
    wire [15:0] prod;
    reg [7:0] num1;
    reg[7:0] num2;

    conventional_multiplier SEPT(prod, num1, num2);
    integer count;
    integer i=0;
    integer actual;

    initial begin
        $dumpfile("conventional_multiplier_tb.vcd");
        $dumpvars(0, conventional_multiplier_tb);
        count = 0;
        num2 = 19;
        for(num1=12; num1<40; num1=num1+1)
        begin 
            actual = num1 * num2;
            $display("%d, %d, %d, %d", num1, num2, prod, actual);
            #5;
        end    
    end

    initial begin
        #150;
        $finish;
    end
endmodule

/*
iverilog -o conventional_multiplier_tb.vvp conventional_multiplier_tb.v
vvp conventional_multiplier_tb.vvp
gtkwave
*/
