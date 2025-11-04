`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2025 11:44:06 AM
// Design Name: 
// Module Name: get_exp
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


module get_exp(

    input  wire [7:0] score,   // total coins collected
    output reg  [7:0] exp      // experience output
);
    always @(*) begin
        if      (score <= 10)   exp = 8'd1;
        else if (score <= 15)  exp = 8'd5;
        else if (score <= 25)  exp = 8'd15;
        else if (score <= 35)  exp = 8'd25;
        else                   exp = 8'd30;  // cap beyond 20 coins
    end
endmodule