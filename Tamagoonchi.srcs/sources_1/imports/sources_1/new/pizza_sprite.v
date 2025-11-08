`timescale 1ns / 1ps
module pizza_sprite(
    input  [6:0] x, y,
    output [15:0] pixel
);
    // Sprite position (centered well on 96x64 OLED)
    wire [6:0] X0 = 7'd24;  
    wire [6:0] Y0 = 7'd10;

    // Approximate 1.5× scale using pattern-based duplication
    // (48x48 rendered area)
    localparam integer WIDTH  = 32;
    localparam integer SCALE3 = 3;  // numerator
    localparam integer SCALE2 = 2;  // denominator

    // --- scaled coordinates (integer math)
    wire [6:0] sx = ((x - X0) * SCALE2) / SCALE3;
    wire [6:0] sy = ((y - Y0) * SCALE2) / SCALE3;
    wire inside = (x >= X0 && x < X0 + (WIDTH * SCALE3 / SCALE2) &&
                   y >= Y0 && y < Y0 + (WIDTH * SCALE3 / SCALE2));

    // === Colors ===
    localparam [15:0] COLOR_FFE0 = 16'hFFE0; // cheese
    localparam [15:0] COLOR_F800 = 16'hF800; // pepperoni
    localparam [15:0] COLOR_8240 = 16'h8240; // crust
    localparam [15:0] COLOR_FD20 = 16'hFD20; // orange crust edge

    // === Bitmaps (same 32x32 data) ===
    reg [31:0] bitmap_FFE0, bitmap_F800, bitmap_8240, bitmap_FD20;

    always @(*) begin
        case (sy)
            5'd6:  bitmap_FFE0 = 32'h00008000;
            5'd7:  bitmap_FFE0 = 32'h0001C000;
            5'd8:  bitmap_FFE0 = 32'h0003E000;
            5'd9:  bitmap_FFE0 = 32'h0007F000;
            5'd10: bitmap_FFE0 = 32'h00067000;
            5'd11: bitmap_FFE0 = 32'h000C3800;
            5'd12: bitmap_FFE0 = 32'h000C3800;
            5'd13: bitmap_FFE0 = 32'h001E7C00;
            5'd14: bitmap_FFE0 = 32'h001FFC00;
            5'd15: bitmap_FFE0 = 32'h003FCE00;
            5'd16: bitmap_FFE0 = 32'h003F8600;
            5'd17: bitmap_FFE0 = 32'h00738700;
            5'd18: bitmap_FFE0 = 32'h0061CF00;
            5'd19: bitmap_FFE0 = 32'h0001F800;
            5'd20: bitmap_FFE0 = 32'h0001C000;
            default: bitmap_FFE0 = 32'h00000000;
        endcase
    end

    always @(*) begin
        case (sy)
            5'd10: bitmap_F800 = 32'h00018000;
            5'd11: bitmap_F800 = 32'h0003C000;
            5'd12: bitmap_F800 = 32'h0003C000;
            5'd13: bitmap_F800 = 32'h00018000;
            5'd15: bitmap_F800 = 32'h00003000;
            5'd16: bitmap_F800 = 32'h00007800;
            5'd17: bitmap_F800 = 32'h000C7800;
            5'd18: bitmap_F800 = 32'h001E3000;
            5'd19: bitmap_F800 = 32'h00060000;
            default: bitmap_F800 = 32'h00000000;
        endcase
    end

    always @(*) begin
        case (sy)
            5'd19: bitmap_8240 = 32'h00780700;
            5'd20: bitmap_8240 = 32'h000E3C00;
            5'd21: bitmap_8240 = 32'h0003E000;
            default: bitmap_8240 = 32'h00000000;
        endcase
    end

    always @(*) begin
        case (sy)
            5'd20: bitmap_FD20 = 32'h00700300;
            5'd21: bitmap_FD20 = 32'h001C1C00;
            5'd22: bitmap_FD20 = 32'h000FF800;
            default: bitmap_FD20 = 32'h00000000;
        endcase
    end

    // === Bit lookup ===
    wire bit_FFE0 = inside ? bitmap_FFE0[31 - sx] : 1'b0;
    wire bit_F800 = inside ? bitmap_F800[31 - sx] : 1'b0;
    wire bit_8240 = inside ? bitmap_8240[31 - sx] : 1'b0;
    wire bit_FD20 = inside ? bitmap_FD20[31 - sx] : 1'b0;

    // === Final pixel color ===
    assign pixel =
        bit_FFE0 ? COLOR_FFE0 :
        bit_F800 ? COLOR_F800 :
        bit_8240 ? COLOR_8240 :
        bit_FD20 ? COLOR_FD20 :
        16'h0000;
endmodule
