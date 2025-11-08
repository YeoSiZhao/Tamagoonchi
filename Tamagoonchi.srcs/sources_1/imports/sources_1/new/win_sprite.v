`timescale 1ns / 1ps

module win_sprite(
    input  wire [6:0] x,
    input  wire [5:0] y,
    output reg  [15:0] pixel
);
    // === Colors ===
    localparam BLACK   = 16'h0000;
    localparam WHITE   = 16'hFFFF;
    localparam GOLD    = 16'hFEA0;
    localparam YELLOW  = 16'hFFE0;
    localparam GREEN   = 16'h07E0;
    localparam DARK_GREEN = 16'h0340;

    // Base coordinate references
    localparam X_OFFSET = 0;
    localparam Y_OFFSET = 0;

    // Relative coordinates
    wire [6:0] rx = x - X_OFFSET;
    wire [5:0] ry = y - Y_OFFSET;

    // Shift values for trophy & text
    localparam TROPHY_X_SHIFT = 9;
    localparam TROPHY_Y_SHIFT = 10;
    localparam TEXT_X_SHIFT   = 9;
    localparam TEXT_Y_SHIFT   = 10;

    wire [6:0] tx = rx - TROPHY_X_SHIFT;
    wire [5:0] ty = ry - TROPHY_Y_SHIFT;
    wire [6:0] lx = rx - TEXT_X_SHIFT;
    wire [5:0] ly = ry - TEXT_Y_SHIFT;
    
    always @(*) begin
        pixel = BLACK;

        //------------------------------------------------------------
        // Background gradient (unchanged, fills entire screen)
        //------------------------------------------------------------
        if (x >= X_OFFSET && x < X_OFFSET + 96 && y >= Y_OFFSET && y < Y_OFFSET + 64) begin
            if ((rx[2:0] + ry[2:0]) < 8)
                pixel = DARK_GREEN;
            else
                pixel = GREEN;
        end

        //------------------------------------------------------------
        // === Trophy (shifted) ===
        //------------------------------------------------------------


        // Base
        if (tx >= 30 && tx <= 45 && ty >= 38 && ty <= 42)
            pixel = GOLD;

        // Stem
        if (tx >= 35 && tx <= 40 && ty >= 30 && ty <= 38)
            pixel = GOLD;

        // Cup
        if (tx >= 28 && tx <= 47 && ty >= 20 && ty <= 30) begin
            if (ty == 20 || ty == 21)
                pixel = YELLOW;
            else if (tx >= 30 && tx <= 45)
                pixel = GOLD;
        end

        // Handles
        if ((tx >= 25 && tx <= 28 && ty >= 22 && ty <= 28) ||
            (tx >= 47 && tx <= 50 && ty >= 22 && ty <= 28))
            pixel = GOLD;

        // Star
        if ((tx >= 36 && tx <= 39 && ty >= 24 && ty <= 27) ||
            (tx == 37 && (ty == 23 || ty == 28)) ||
            (ty == 25 && (tx == 35 || tx == 40)))
            pixel = YELLOW;

        //------------------------------------------------------------
        // === Text: "YOU WIN" (shifted) ===
        //------------------------------------------------------------


        // Y
        if ((lx >= 4 && lx <= 6 && ly >= 4 && ly <= 8) ||
            (lx >= 12 && lx <= 14 && ly >= 4 && ly <= 8) ||
            (lx >= 7 && lx <= 11 && ly >= 9 && ly <= 14))
            pixel = WHITE;

        // O
        if (((lx >= 17 && lx <= 19) || (lx >= 25 && lx <= 27)) && ly >= 4 && ly <= 14)
            pixel = WHITE;
        if ((ly >= 4 && ly <= 6) || (ly >= 12 && ly <= 14))
            if (lx >= 20 && lx <= 24)
                pixel = WHITE;

        // U
        if (((lx >= 30 && lx <= 32) || (lx >= 38 && lx <= 40)) && ly >= 4 && ly <= 14)
            pixel = WHITE;
        if (ly >= 12 && ly <= 14 && lx >= 33 && lx <= 37)
            pixel = WHITE;

        // W
        if ((lx >= 44 && lx <= 46 && ly >= 4 && ly <= 14) ||
            (lx >= 48 && lx <= 50 && ly >= 10 && ly <= 14) ||
            (lx >= 52 && lx <= 54 && ly >= 10 && ly <= 14) ||
            (lx >= 56 && lx <= 58 && ly >= 4 && ly <= 14))
            pixel = WHITE;

        // I
        if (lx >= 61 && lx <= 64 && ly >= 4 && ly <= 14)
            pixel = WHITE;

        // N
        if ((lx >= 67 && lx <= 69 && ly >= 4 && ly <= 14) ||
            (lx >= 73 && lx <= 75 && ly >= 4 && ly <= 14))
            pixel = WHITE;
        if (lx >= 70 && lx <= 72 && ly >= 7 && ly <= 11)
            pixel = WHITE;
    end
endmodule
