`timescale 1ns / 1ps
module left_arrow_sprite(
    input  [6:0] x, y,
    output [15:0] pixel
);
    // Sprite position on OLED
    wire [6:0] X0 = 7'd0;
    wire [6:0] Y0 = 7'd10;
    localparam SCALE = 2;
    wire [4:0] sx = (x - X0) / SCALE;
    wire [4:0] sy = (y - Y0) / SCALE;
    wire inside = (x >= X0 && x < X0+48 && y >= Y0 && y < Y0+48);
    // Color definitions
    localparam [15:0] COLOR_FFFF = 16'hFFFF;
    // Bitmap for color FFFF (horizontally mirrored)
    reg [23:0] bitmap_FFFF;
    always @(*) begin
        case (sy)
            5'd0:  bitmap_FFFF = 24'h000000;
            5'd1:  bitmap_FFFF = 24'h000000;
            5'd2:  bitmap_FFFF = 24'h000000;
            5'd3:  bitmap_FFFF = 24'h000000;
            5'd4:  bitmap_FFFF = 24'h000000;
            5'd5:  bitmap_FFFF = 24'h000400;
            5'd6:  bitmap_FFFF = 24'h000C00;
            5'd7:  bitmap_FFFF = 24'h001C00;
            5'd8:  bitmap_FFFF = 24'h003C00;
            5'd9:  bitmap_FFFF = 24'h007C00;
            5'd10:  bitmap_FFFF = 24'h00FC00;
            5'd11:  bitmap_FFFF = 24'h007C00;
            5'd12:  bitmap_FFFF = 24'h003C00;
            5'd13:  bitmap_FFFF = 24'h001C00;
            5'd14:  bitmap_FFFF = 24'h000C00;
            5'd15:  bitmap_FFFF = 24'h000400;
            5'd16:  bitmap_FFFF = 24'h000000;
            5'd17:  bitmap_FFFF = 24'h000000;
            5'd18:  bitmap_FFFF = 24'h000000;
            5'd19:  bitmap_FFFF = 24'h000000;
            5'd20:  bitmap_FFFF = 24'h000000;
            5'd21:  bitmap_FFFF = 24'h000000;
            5'd22:  bitmap_FFFF = 24'h000000;
            5'd23:  bitmap_FFFF = 24'h000000;
            default: bitmap_FFFF = 24'h000000;
        endcase
    end
    wire bit_FFFF = inside ? bitmap_FFFF[23 - sx] : 1'b0;
    // Pixel color output
    assign pixel = bit_FFFF ? COLOR_FFFF :
                   16'h0000;
endmodule