`timescale 1ns / 1ps
module burger_sprite(
    input  [6:0] x, y,
    output [15:0] pixel
);
    // Sprite position on OLED
    wire [6:0] X0 = 7'd23;  // shifted ~12 pixels right
    wire [6:0] Y0 = 7'd10;  // shifted ~6 pixels up

    // Scale factor: 2x (24x24 sprite becomes 48x48 on OLED)
    localparam SCALE = 2;
    wire [4:0] sx = (x - X0) / SCALE;
    wire [4:0] sy = (y - Y0) / SCALE;
    wire inside = (x >= X0 && x < X0+48 && y >= Y0 && y < Y0+48);

    // Color definitions
    localparam [15:0] COLOR_FD20 = 16'hFD20;
    localparam [15:0] COLOR_07E0 = 16'h07E0;
    localparam [15:0] COLOR_F800 = 16'hF800;
    localparam [15:0] COLOR_FFE0 = 16'hFFE0;
    localparam [15:0] COLOR_8240 = 16'h8240;

    // Bitmap for color FD20
    reg [23:0] bitmap_FD20;
    always @(*) begin
        case (sy)
            5'd0:  bitmap_FD20 = 24'h000000;
            5'd1:  bitmap_FD20 = 24'h000000;
            5'd2:  bitmap_FD20 = 24'h000000;
            5'd3:  bitmap_FD20 = 24'h000000;
            5'd4:  bitmap_FD20 = 24'h000000;
            5'd5:  bitmap_FD20 = 24'h000000;
            5'd6:  bitmap_FD20 = 24'h007E00;
            5'd7:  bitmap_FD20 = 24'h00FF00;
            5'd8:  bitmap_FD20 = 24'h01FF80;
            5'd9:  bitmap_FD20 = 24'h01FF80;
            5'd10:  bitmap_FD20 = 24'h000000;
            5'd11:  bitmap_FD20 = 24'h000000;
            5'd12:  bitmap_FD20 = 24'h000000;
            5'd13:  bitmap_FD20 = 24'h000000;
            5'd14:  bitmap_FD20 = 24'h01FF80;
            5'd15:  bitmap_FD20 = 24'h01FF80;
            5'd16:  bitmap_FD20 = 24'h00FF00;
            5'd17:  bitmap_FD20 = 24'h000000;
            5'd18:  bitmap_FD20 = 24'h000000;
            5'd19:  bitmap_FD20 = 24'h000000;
            5'd20:  bitmap_FD20 = 24'h000000;
            5'd21:  bitmap_FD20 = 24'h000000;
            5'd22:  bitmap_FD20 = 24'h000000;
            5'd23:  bitmap_FD20 = 24'h000000;
            default: bitmap_FD20 = 24'h000000;
        endcase
    end

    // Bitmap for color 07E0
    reg [23:0] bitmap_07E0;
    always @(*) begin
        case (sy)
            5'd0:  bitmap_07E0 = 24'h000000;
            5'd1:  bitmap_07E0 = 24'h000000;
            5'd2:  bitmap_07E0 = 24'h000000;
            5'd3:  bitmap_07E0 = 24'h000000;
            5'd4:  bitmap_07E0 = 24'h000000;
            5'd5:  bitmap_07E0 = 24'h000000;
            5'd6:  bitmap_07E0 = 24'h000000;
            5'd7:  bitmap_07E0 = 24'h000000;
            5'd8:  bitmap_07E0 = 24'h000000;
            5'd9:  bitmap_07E0 = 24'h000000;
            5'd10:  bitmap_07E0 = 24'h01FF80;
            5'd11:  bitmap_07E0 = 24'h000000;
            5'd12:  bitmap_07E0 = 24'h000000;
            5'd13:  bitmap_07E0 = 24'h000000;
            5'd14:  bitmap_07E0 = 24'h000000;
            5'd15:  bitmap_07E0 = 24'h000000;
            5'd16:  bitmap_07E0 = 24'h000000;
            5'd17:  bitmap_07E0 = 24'h000000;
            5'd18:  bitmap_07E0 = 24'h000000;
            5'd19:  bitmap_07E0 = 24'h000000;
            5'd20:  bitmap_07E0 = 24'h000000;
            5'd21:  bitmap_07E0 = 24'h000000;
            5'd22:  bitmap_07E0 = 24'h000000;
            5'd23:  bitmap_07E0 = 24'h000000;
            default: bitmap_07E0 = 24'h000000;
        endcase
    end

    // Bitmap for color F800
    reg [23:0] bitmap_F800;
    always @(*) begin
        case (sy)
            5'd0:  bitmap_F800 = 24'h000000;
            5'd1:  bitmap_F800 = 24'h000000;
            5'd2:  bitmap_F800 = 24'h000000;
            5'd3:  bitmap_F800 = 24'h000000;
            5'd4:  bitmap_F800 = 24'h000000;
            5'd5:  bitmap_F800 = 24'h000000;
            5'd6:  bitmap_F800 = 24'h000000;
            5'd7:  bitmap_F800 = 24'h000000;
            5'd8:  bitmap_F800 = 24'h000000;
            5'd9:  bitmap_F800 = 24'h000000;
            5'd10:  bitmap_F800 = 24'h000000;
            5'd11:  bitmap_F800 = 24'h01FF80;
            5'd12:  bitmap_F800 = 24'h000000;
            5'd13:  bitmap_F800 = 24'h000000;
            5'd14:  bitmap_F800 = 24'h000000;
            5'd15:  bitmap_F800 = 24'h000000;
            5'd16:  bitmap_F800 = 24'h000000;
            5'd17:  bitmap_F800 = 24'h000000;
            5'd18:  bitmap_F800 = 24'h000000;
            5'd19:  bitmap_F800 = 24'h000000;
            5'd20:  bitmap_F800 = 24'h000000;
            5'd21:  bitmap_F800 = 24'h000000;
            5'd22:  bitmap_F800 = 24'h000000;
            5'd23:  bitmap_F800 = 24'h000000;
            default: bitmap_F800 = 24'h000000;
        endcase
    end

    // Bitmap for color FFE0
    reg [23:0] bitmap_FFE0;
    always @(*) begin
        case (sy)
            5'd0:  bitmap_FFE0 = 24'h000000;
            5'd1:  bitmap_FFE0 = 24'h000000;
            5'd2:  bitmap_FFE0 = 24'h000000;
            5'd3:  bitmap_FFE0 = 24'h000000;
            5'd4:  bitmap_FFE0 = 24'h000000;
            5'd5:  bitmap_FFE0 = 24'h000000;
            5'd6:  bitmap_FFE0 = 24'h000000;
            5'd7:  bitmap_FFE0 = 24'h000000;
            5'd8:  bitmap_FFE0 = 24'h000000;
            5'd9:  bitmap_FFE0 = 24'h000000;
            5'd10:  bitmap_FFE0 = 24'h000000;
            5'd11:  bitmap_FFE0 = 24'h000000;
            5'd12:  bitmap_FFE0 = 24'h01FF80;
            5'd13:  bitmap_FFE0 = 24'h000000;
            5'd14:  bitmap_FFE0 = 24'h000000;
            5'd15:  bitmap_FFE0 = 24'h000000;
            5'd16:  bitmap_FFE0 = 24'h000000;
            5'd17:  bitmap_FFE0 = 24'h000000;
            5'd18:  bitmap_FFE0 = 24'h000000;
            5'd19:  bitmap_FFE0 = 24'h000000;
            5'd20:  bitmap_FFE0 = 24'h000000;
            5'd21:  bitmap_FFE0 = 24'h000000;
            5'd22:  bitmap_FFE0 = 24'h000000;
            5'd23:  bitmap_FFE0 = 24'h000000;
            default: bitmap_FFE0 = 24'h000000;
        endcase
    end

    // Bitmap for color 8240
    reg [23:0] bitmap_8240;
    always @(*) begin
        case (sy)
            5'd0:  bitmap_8240 = 24'h000000;
            5'd1:  bitmap_8240 = 24'h000000;
            5'd2:  bitmap_8240 = 24'h000000;
            5'd3:  bitmap_8240 = 24'h000000;
            5'd4:  bitmap_8240 = 24'h000000;
            5'd5:  bitmap_8240 = 24'h000000;
            5'd6:  bitmap_8240 = 24'h000000;
            5'd7:  bitmap_8240 = 24'h000000;
            5'd8:  bitmap_8240 = 24'h000000;
            5'd9:  bitmap_8240 = 24'h000000;
            5'd10:  bitmap_8240 = 24'h000000;
            5'd11:  bitmap_8240 = 24'h000000;
            5'd12:  bitmap_8240 = 24'h000000;
            5'd13:  bitmap_8240 = 24'h01FF80;
            5'd14:  bitmap_8240 = 24'h000000;
            5'd15:  bitmap_8240 = 24'h000000;
            5'd16:  bitmap_8240 = 24'h000000;
            5'd17:  bitmap_8240 = 24'h000000;
            5'd18:  bitmap_8240 = 24'h000000;
            5'd19:  bitmap_8240 = 24'h000000;
            5'd20:  bitmap_8240 = 24'h000000;
            5'd21:  bitmap_8240 = 24'h000000;
            5'd22:  bitmap_8240 = 24'h000000;
            5'd23:  bitmap_8240 = 24'h000000;
            default: bitmap_8240 = 24'h000000;
        endcase
    end

    wire bit_FD20 = inside ? bitmap_FD20[23 - sx] : 1'b0;
    wire bit_07E0 = inside ? bitmap_07E0[23 - sx] : 1'b0;
    wire bit_F800 = inside ? bitmap_F800[23 - sx] : 1'b0;
    wire bit_FFE0 = inside ? bitmap_FFE0[23 - sx] : 1'b0;
    wire bit_8240 = inside ? bitmap_8240[23 - sx] : 1'b0;

    // Pixel color output
    assign pixel = bit_FD20 ? COLOR_FD20 :
                   bit_07E0 ? COLOR_07E0 :
                   bit_F800 ? COLOR_F800 :
                   bit_FFE0 ? COLOR_FFE0 :
                   bit_8240 ? COLOR_8240 :
                   16'h0000;
endmodule
