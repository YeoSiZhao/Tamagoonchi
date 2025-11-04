`timescale 1ns / 1ps
module exp_display(
    input  [12:0] pixel_index,  // 0-6143
    input  [7:0]  exp,          // EXP value from get_exp
    input         game_over,    // show only when game over
    output reg [15:0] pixel_data
);
    // OLED geometry
    localparam WIDTH  = 96;
    localparam HEIGHT = 64;
    wire [6:0] x = pixel_index % WIDTH;
    wire [5:0] y = pixel_index / WIDTH;

    // Colors
    localparam [15:0] BLACK = 16'h0000;
    localparam [15:0] WHITE = 16'hFFFF;

    // simple 8x12 pixel blocks for two digits centered roughly
    wire [3:0] tens = exp / 10;
    wire [3:0] ones = exp % 10;

    // bounding boxes for digits
    wire in_tens_box = (x >= 35 && x < 43) && (y >= 25 && y < 37);
    wire in_ones_box = (x >= 50 && x < 58) && (y >= 25 && y < 37);

    always @(*) begin
        pixel_data = BLACK;

        if (game_over) begin
            // show tens if >=10
            if (in_tens_box && (exp >= 10))
                pixel_data = WHITE;

            // always show ones digit box (very simple visualization)
            if (in_ones_box)
                pixel_data = WHITE;
        end
    end
endmodule
