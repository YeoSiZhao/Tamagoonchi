`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/03/2025 08:51:43 PM
// Design Name: 
// Module Name: clock_6_25
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clock_6_25(
    input  wire clk,          // 100 MHz system clock
output reg  clk_out = 1'b0
);
// toggle clk_out every 8 input cycles -> output = fin / (2*8) = fin/16
reg [3:0] div_cnt = 4'd0;

always @(posedge clk) begin
    if (div_cnt == 4'd7) begin
        div_cnt <= 4'd0;
        clk_out <= ~clk_out;
    end else begin
        div_cnt <= div_cnt + 4'd1;
    end
end
endmodule