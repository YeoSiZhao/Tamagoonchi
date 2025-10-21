`timescale 1ns / 1ps

module burger_sprite(
    input  [6:0] x, y,
    output       hit,
    output [15:0] pixel
);
    wire [6:0] X0 = 7'd38;
    wire [6:0] Y0 = 7'd12;
    wire [4:0] sx = x - X0;
    wire [4:0] sy = y - Y0;
    wire inside = (x >= X0 && x < X0+24 && y >= Y0 && y < Y0+20);

    reg [23:0] row;
    always @(*) begin
        case (sy)
            5'd0:  row = 24'h000000; // sesame seeds
            5'd1:  row = 24'h082010; // top bun with seeds
            5'd2:  row = 24'h1C3838;
            5'd3:  row = 24'h3E7C7C;
            5'd4:  row = 24'h7FFEFE;
            5'd5:  row = 24'h7FFEFE; // cheese (yellow)
            5'd6:  row = 24'h7FFEFE;
            5'd7:  row = 24'h7FFEFE;
            5'd8:  row = 24'h7FFEFE; // meat (brown)
            5'd9:  row = 24'h7FFEFE;
            5'd10: row = 24'h7FFEFE;
            5'd11: row = 24'h7FFEFE; // lettuce (green)
            5'd12: row = 24'h7FFEFE;
            5'd13: row = 24'h7FFEFE;
            5'd14: row = 24'h7FFEFE; // bottom bun
            5'd15: row = 24'h7FFEFE;
            5'd16: row = 24'h3E7C7C;
            5'd17: row = 24'h1C3838;
            5'd18: row = 24'h082010;
            5'd19: row = 24'h000000;
            default: row = 24'h000000;
        endcase
    end

    wire bit_on = inside ? row[23 - sx] : 1'b0;
    
    // Layer-based coloring
    wire is_top_bun = (sy >= 1 && sy <= 4);
    wire is_cheese = (sy >= 5 && sy <= 7);
    wire is_meat = (sy >= 8 && sy <= 10);
    wire is_lettuce = (sy >= 11 && sy <= 13);
    wire is_bottom_bun = (sy >= 14 && sy <= 18);
    
    assign hit = bit_on;
    assign pixel = is_top_bun ? 16'hFD20 :    // golden brown bun
                  is_cheese ? 16'hFFE0 :      // yellow cheese
                  is_meat ? 16'hA145 :        // brown meat
                  is_lettuce ? 16'h07E0 :     // green lettuce
                  is_bottom_bun ? 16'hFD20 :  // golden brown bun
                  16'h0000;
endmodule