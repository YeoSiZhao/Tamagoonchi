`timescale 1ns / 1ps

module lose_sprite(
    input  wire [6:0] x,
    input  wire [5:0] y,
    output reg  [15:0] pixel
);
    // === Color palette ===
    localparam BLACK   = 16'h0000;
    localparam WHITE   = 16'hFFFF;
    localparam BROWN   = 16'h7980;      // Poop brown
    localparam DARK_BROWN = 16'h4200;
    localparam RED     = 16'hF800;
    localparam DARK_RED = 16'h7800;
    
    // === Offsets ===
    localparam X_OFFSET = 0;
    localparam Y_OFFSET = 0;
    
    // Relative coordinates
    wire [6:0] rx = x - X_OFFSET;
    wire [5:0] ry = y - Y_OFFSET;

    // Shift text and emoji
    localparam SHIFT_X = 8;
    localparam SHIFT_Y = 10;
    
    wire [6:0] tx = rx - SHIFT_X;
    wire [5:0] ty = ry - SHIFT_Y;    
    wire [6:0] ex = rx - SHIFT_X;
    wire [5:0] ey = ry - SHIFT_Y;

    always @(*) begin
        pixel = BLACK;

        //------------------------------------------------------------
        // Background (fixed full red gradient)
        //------------------------------------------------------------
        if (x >= X_OFFSET && x < X_OFFSET + 96 && y >= Y_OFFSET && y < Y_OFFSET + 64) begin
            if ((rx[2:0] + ry[2:0]) < 8)
                pixel = DARK_RED;
            else
                pixel = RED;
        end

        //------------------------------------------------------------
        // === Poop Emoji (shifted) ===
        //------------------------------------------------------------


        // Bottom swirl
        if (ex >= 28 && ex <= 47 && ey >= 32 && ey <= 42) begin
            if ((ex >= 30 && ex <= 45 && ey >= 34 && ey <= 40) ||
                (ey == 32 || ey == 42 || ex == 28 || ex == 47))
                pixel = BROWN;
        end

        // Middle swirl
        if (ex >= 30 && ex <= 45 && ey >= 24 && ey <= 32) begin
            if ((ex >= 32 && ex <= 43 && ey >= 26 && ey <= 30) ||
                (ey == 24 || ey == 32 || ex == 30 || ex == 45))
                pixel = BROWN;
        end

        // Top swirl
        if (ex >= 33 && ex <= 42 && ey >= 18 && ey <= 24) begin
            if ((ex >= 35 && ex <= 40 && ey >= 20 && ey <= 22) ||
                (ey == 18 || ey == 24 || ex == 33 || ex == 42))
                pixel = BROWN;
        end

        // Eyes
        if ((ex >= 34 && ex <= 36 && ey >= 36 && ey <= 38) ||
            (ex >= 41 && ex <= 43 && ey >= 36 && ey <= 38))
            pixel = WHITE;

        // Sad mouth (frown)
        if (ey == 39 && ex >= 36 && ex <= 39)
            pixel = DARK_BROWN;
        if ((ey == 40 && (ex == 35 || ex == 40)))
            pixel = DARK_BROWN;

        //------------------------------------------------------------
        // === Text: "YOU LOSE" (shifted) ===
        //------------------------------------------------------------

        // Y
        if ((tx >= 2 && tx <= 4 && ty >= 4 && ty <= 8) ||
            (tx >= 10 && tx <= 12 && ty >= 4 && ty <= 8) ||
            (tx >= 5 && tx <= 9 && ty >= 9 && ty <= 14))
            pixel = WHITE;

        // O
        if (((tx >= 15 && tx <= 17) || (tx >= 23 && tx <= 25)) && ty >= 4 && ty <= 14)
            pixel = WHITE;
        if ((ty >= 4 && ty <= 6) || (ty >= 12 && ty <= 14)) 
            if (tx >= 18 && tx <= 22)
                pixel = WHITE;

        // U
        if (((tx >= 28 && tx <= 30) || (tx >= 36 && tx <= 38)) && ty >= 4 && ty <= 14)
            pixel = WHITE;
        if (ty >= 12 && ty <= 14 && tx >= 31 && tx <= 35)
            pixel = WHITE;

        // L
        if (tx >= 42 && tx <= 44 && ty >= 4 && ty <= 14)
            pixel = WHITE;
        if (ty >= 12 && ty <= 14 && tx >= 42 && tx <= 48)
            pixel = WHITE;

        // O
        if (((tx >= 51 && tx <= 53) || (tx >= 59 && tx <= 61)) && ty >= 4 && ty <= 14)
            pixel = WHITE;
        if ((ty >= 4 && ty <= 6) || (ty >= 12 && ty <= 14)) 
            if (tx >= 54 && tx <= 58)
                pixel = WHITE;

        // S
        if ((ty >= 4 && ty <= 6 && tx >= 64 && tx <= 70) ||
            (tx >= 64 && tx <= 66 && ty >= 4 && ty <= 9) ||
            (ty >= 8 && ty <= 10 && tx >= 64 && tx <= 70) ||
            (tx >= 68 && tx <= 70 && ty >= 8 && ty <= 14) ||
            (ty >= 12 && ty <= 14 && tx >= 64 && tx <= 70))
            pixel = WHITE;

        // E
        if ((tx >= 73 && tx <= 75 && ty >= 4 && ty <= 14) ||
            (ty >= 4 && ty <= 6 && tx >= 73 && tx <= 80) ||
            (ty >= 8 && ty <= 10 && tx >= 73 && tx <= 79) ||
            (ty >= 12 && ty <= 14 && tx >= 73 && tx <= 80))
            pixel = WHITE;
    end
endmodule
