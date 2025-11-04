module ClockDivider #(parameter DIV = 50_000_000) (
    input  wire clk,          // fast 100 MHz FPGA clock
    output reg  slow_clk = 0  // output divided clock
);
    reg [31:0] count = 0;     // internal counter register

    always @(posedge clk) begin
        if (count == DIV - 1) begin
            count <= 0;              // reset the counter
            slow_clk <= ~slow_clk;   // toggle output each time counter completes
        end else
            count <= count + 1;      // increment counter every clock cycle
    end
endmodule

//hi
