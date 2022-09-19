`timescale 1 ns / 1 ns
`include "mutliplier_accurated.v"
module mul_accurated_tb();
    wire [14:0] prod;
    reg [7:0] num1;
    reg [7:0] num2;
    reg [15:0] actual;
    integer freq [0:15];
    integer i;
    integer count;
    multiplier JAN(prod, num1, num2);
    integer MCD1;

    initial begin
        $dumpfile("mul_accurated_tb.vcd");
        $dumpvars(0, mul_accurated_tb);
        MCD1 = $fopen("result_accurated.txt");
        count=0;
        for(i=0; i<16; i=i+1)
        begin
            freq[i] = 0;
        end
        for(num1=8'd1; num1!=0 && num1<=8'hFF; num1 = num1 + 1)
        begin
            for(num2 = 8'd1; num2!=0 && num2<=num1; num2=num2+1)
            begin
                actual = num1 * num2;
                $fdisplay(MCD1, "%d, %d, %d, %d", num1, num2, prod, actual);
                count= count+1;
                for(i=0; i<16; i=i+1)
                begin 
                    if(prod[i] == 1'b1 && actual[i] == 1'b0)
                        freq[i] = freq[i] + 1;
                    else if(prod[i] == 1'b0 && actual[i] == 1'b1)
                        freq[i] = freq[i] + 1;
                end
                #1;
            end
        end
        $fclose(MCD1);
        for(i=0; i<16; i=i+1)
        begin
            $display("%d", freq[i]);
            #1;
        end
        $display("%d", count);
    end

    initial begin
        #33000;
        $finish;
    end
endmodule

/*
iverilog -o mul_accurated_tb.vvp mul_accurated_tb.v
vvp mul_accurated_tb.vvp
gtkwave
*/