`timescale 1ns / 1ps

module drink_sprite(
    input  [6:0] x, y,
    output       hit,
    output [15:0] pixel
);
    wire [6:0] X0 = 7'd70;
    wire [6:0] Y0 = 7'd10;
    wire [4:0] sx = x - X0;
    wire [4:0] sy = y - Y0;
    wire inside = (x >= X0 && x < X0+24 && y >= Y0 && y < Y0+24);

    reg [23:0] row;
    always @(*) begin
        case (sy)
            5'd0:  row = 24'h000000; // straw top
            5'd1:  row = 24'h000060;
            5'd2:  row = 24'h0000F0;
            5'd3:  row = 24'h0001F8;
            5'd4:  row = 24'h0003FC;
            5'd5:  row = 24'h0007FE; // straw
            5'd6:  row = 24'h0007FE;
            5'd7:  row = 24'h0007FE;
            5'd8:  row = 24'h0007FE;
            5'd9:  row = 24'h0007FE;
            5'd10: row = 24'h003FF0; // cup rim
            5'd11: row = 24'h007FF8;
            5'd12: row = 24'h00FFFC;
            5'd13: row = 24'h01FFFE; // liquid
            5'd14: row = 24'h01FFFE;
            5'd15: row = 24'h01FFFE;
            5'd16: row = 24'h01FFFE;
            5'd17: row = 24'h01FFFE;
            5'd18: row = 24'h00FFFC; // cup bottom
            5'd19: row = 24'h007FF8;
            5'd20: row = 24'h003FF0;
            5'd21: row = 24'h001FE0;
            5'd22: row = 24'h000FC0;
            5'd23: row = 24'h000780;
            default: row = 24'h000000;
        endcase
    end

    wire bit_on = inside ? row[23 - sx] : 1'b0;
    
    // Part-based coloring
    wire is_straw = (sy >= 1 && sy <= 9);
    wire is_cup_rim = (sy >= 10 && sy <= 12);
    wire is_liquid = (sy >= 13 && sy <= 17);
    wire is_cup_bottom = (sy >= 18 && sy <= 23);
    
    assign hit = bit_on;
    assign pixel = is_straw ? 16'hFFE0 :       // yellow straw
                  is_cup_rim ? 16'hFFFF :      // white cup rim
                  is_liquid ? 16'h001F :       // blue liquid
                  is_cup_bottom ? 16'hFFFF :   // white cup
                  16'h0000;
endmodule