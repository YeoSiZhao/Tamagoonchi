`timescale 1ns / 1ps

module apple_sprite(
    input  [6:0] x, y,
    output       hit,
    output [15:0] pixel
);
    wire [6:0] X0 = 7'd6;
    wire [6:0] Y0 = 7'd10;
    wire [4:0] sx = x - X0;
    wire [4:0] sy = y - Y0;
    wire inside = (x >= X0 && x < X0+24 && y >= Y0 && y < Y0+24);

    reg [23:0] row;
    always @(*) begin
        case (sy)
            5'd0:  row = 24'h000000; // stem
            5'd1:  row = 24'h000400;
            5'd2:  row = 24'h000C00;
            5'd3:  row = 24'h001E00;
            5'd4:  row = 24'h003F00;
            5'd5:  row = 24'h007F80; // apple top
            5'd6:  row = 24'h00FFC0;
            5'd7:  row = 24'h01FFE0;
            5'd8:  row = 24'h03FFF0;
            5'd9:  row = 24'h07FFF8;
            5'd10: row = 24'h0FFFFC;
            5'd11: row = 24'h1FFFFE;
            5'd12: row = 24'h1FFFFE;
            5'd13: row = 24'h1FFFFE;
            5'd14: row = 24'h0FFFFC;
            5'd15: row = 24'h07FFF8;
            5'd16: row = 24'h03FFF0;
            5'd17: row = 24'h01FFE0;
            5'd18: row = 24'h00FFC0;
            5'd19: row = 24'h007F80;
            5'd20: row = 24'h003F00; // leaf
            5'd21: row = 24'h001E00;
            5'd22: row = 24'h000C00;
            5'd23: row = 24'h000000;
            default: row = 24'h000000;
        endcase
    end

    wire bit_on = inside ? row[23 - sx] : 1'b0;
    
    // Color variations for more detail
    wire is_stem = (sy >= 0 && sy <= 4);
    wire is_leaf = (sy >= 20 && sy <= 23);
    
    assign hit = bit_on;
    assign pixel = is_stem ? 16'hA145 :    // brown stem
                  is_leaf ? 16'h07E0 :    // green leaf
                  16'hF800;               // red apple
endmodule