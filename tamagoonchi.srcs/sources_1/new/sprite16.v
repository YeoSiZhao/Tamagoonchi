`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// sprite16.v  -  Verilog-2001 compatible 16x16 sprite renderer
// Draws a 16×16 shape defined by a case-based ROM pattern.
// Inputs:  x, y pixel position (0-95, 0-63)
// Outputs: hit (1 if pixel inside sprite), pixel (RGB565 color)
// Usage:   Instantiate and define a local ROM (case sy)
//////////////////////////////////////////////////////////////////////////////////

module sprite16(
    input  [6:0] x, y,          // current OLED pixel position
    input  [6:0] x0, y0,        // top-left coordinate of sprite
    input  [15:0] color,        // RGB565 sprite color
    output       hit,           // 1 if this pixel is active
    output [15:0] pixel         // pixel color output
);

    // Compute local sprite coordinates
    wire [4:0] sx = x - x0;     // relative X inside sprite (0-15)
    wire [4:0] sy = y - y0;     // relative Y inside sprite (0-15)
    wire inside = (x >= x0 && x < x0 + 16 && y >= y0 && y < y0 + 16);

    // Default row pattern - override by module using this as a template
    reg [15:0] row;
    always @(*) begin
        case (sy)
            5'd0:  row = 16'h0000;
            5'd1:  row = 16'h03C0;
            5'd2:  row = 16'h07E0;
            5'd3:  row = 16'h0FF0;
            5'd4:  row = 16'h1FF8;
            5'd5:  row = 16'h3FFC;
            5'd6:  row = 16'h3FFC;
            5'd7:  row = 16'h1FF8;
            5'd8:  row = 16'h0FF0;
            5'd9:  row = 16'h07E0;
            5'd10: row = 16'h03C0;
            5'd11: row = 16'h0000;
            default: row = 16'h0000;
        endcase
    end

    // Activate pixel if bit set in current row
    wire bit_on = inside ? row[15 - sx] : 1'b0;
    assign hit   = bit_on;
    assign pixel = color;

endmodule
