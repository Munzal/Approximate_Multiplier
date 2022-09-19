
module conventional_multiplier(
    output [15:0] ans,
    input [7:0] num1,
    input [7:0] num2
);
    assign ans = num1 * num2;

endmodule
