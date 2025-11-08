`timescale 1ns / 1ps

module dead_sprite(
    input  wire        clk,
    input  wire [6:0]  x,
    input  wire [5:0]  y,
    input  wire [6:0]  mushroom_x,   // frozen x from idle
    output reg  [15:0] pixel
);

    wire [15:0] bg_pixel_color;
    maplestory_background bg (
        .x(x),
        .y(y),
        .pixel(bg_pixel_color)
    );

    wire [4:0] r = bg_pixel_color[15:11];
    wire [5:0] g = bg_pixel_color[10:5];
    wire [4:0] b = bg_pixel_color[4:0];

    // Original (slightly blueish) ? replace with balanced
    wire [7:0] lum = (r * 19 + g * 37 + b * 7) >> 6;
    wire [15:0] bg_gray = {lum[7:3], lum[7:2], lum[7:3]};

    wire signed [7:0] relx = x - mushroom_x;
    reg [15:0] mush_pixel;

    always @(*) begin
        mush_pixel = 16'h0000; // transparent by default

        if (y >= 15 && y <= 20) begin
            if (y == 15 && relx >= -13 && relx <= 12)
                mush_pixel = 16'h4208; // dark rim
            else if (y == 16) begin
                if ((relx >= -16 && relx <= -14) || (relx >= 13 && relx <= 15))
                    mush_pixel = 16'h4208; // dark edge
                else if (relx >= -13 && relx <= 12)
                    mush_pixel = 16'h6318; // dark grey
            end
            else if (y >= 17 && y <= 20) begin
                if ((relx >= -18 && relx <= -17) || (relx >= 14 && relx <= 17))
                    mush_pixel = 16'h4208; // side outline
                else if (relx >= -16 && relx <= -4)
                    mush_pixel = 16'h6318; // dark grey
                else if (relx >= -3 && relx <= 6)
                    mush_pixel = 16'h8C51; // mid grey
                else if (relx >= 7 && relx <= 14)
                    mush_pixel = 16'h6318; // dark grey
            end
        end

        // Middle of cap (rows 21-28)
        else if (y >= 21 && y <= 28) begin
            if ((relx >= -20 && relx <= -19) || (relx >= 18 && relx <= 19))
                mush_pixel = 16'h4208; // side outline
            else if (relx >= -18 && relx <= 17) begin
                // Light grey "spots"
                if ((y >= 22 && y <= 25) && (relx >= -10 && relx <= -6))
                    mush_pixel = 16'hC618;
                else if ((y >= 23 && y <= 26) && (relx >= 4 && relx <= 8))
                    mush_pixel = 16'hC618;
                else if ((y >= 24 && y <= 26) && (relx >= -15 && relx <= -13))
                    mush_pixel = 16'hC618;
                // Cap fill zones
                else if (relx >= -18 && relx <= -5)
                    mush_pixel = 16'h6318;
                else if (relx >= -4 && relx <= 5)
                    mush_pixel = 16'h8C51;
                else
                    mush_pixel = 16'h6318;
            end
        end

        // Bottom rim (rows 29-30)
        else if (y >= 29 && y <= 30) begin
            if ((relx >= -22 && relx <= -21) || (relx >= 19 && relx <= 20))
                mush_pixel = 16'h4208; // dark edge
            else if (relx >= -20 && relx <= 18)
                mush_pixel = 16'h5AEB; // mid-dark rim
        end

        else if (y >= 31 && y <= 52 && relx >= -17 && relx <= 17)
            mush_pixel = 16'hBDF7; // light grey body

        else if (y >= 54 && y <= 56 && ((relx >= -10 && relx <= -5) || (relx >= 5 && relx <= 10)))
            mush_pixel = 16'h7BEF; // mid-grey feet

        if ((y >= 38 && y <= 41) && (relx >= -8 && relx <= -6))
            if ((x + y) % 2 == 0)
                mush_pixel = 16'h0000;

        if ((y >= 38 && y <= 41) && (relx >= 6 && relx <= 8))
            if ((x + y) % 2 == 0)
                mush_pixel = 16'h0000;

        if (y == 44 && relx >= -3 && relx <= 3)
            mush_pixel = 16'h0000;
        if (y == 43 && (relx == -4 || relx == 4))
            mush_pixel = 16'h0000;
        if (y == 42 && (relx == -5 || relx == 5))
            mush_pixel = 16'h0000;
    end

    reg [15:0] text_pixel;
    always @(*) begin
        text_pixel = 16'h0000; // transparent by default

        // Y
        if ((x >= 11 && x <= 13 && y >= 4 && y <= 8) ||
            (x >= 19 && x <= 21 && y >= 4 && y <= 8) ||
            (x >= 14 && x <= 18 && y >= 9 && y <= 14))
            text_pixel = 16'hE71C;

        // O
        if (((x >= 24 && x <= 26) || (x >= 32 && x <= 34)) && y >= 4 && y <= 14)
            text_pixel = 16'hE71C;
        if ((y >= 4 && y <= 6) || (y >= 12 && y <= 14))
            if (x >= 27 && x <= 31)
                text_pixel = 16'hE71C;

        // U
        if (((x >= 37 && x <= 39) || (x >= 45 && x <= 47)) && y >= 4 && y <= 14)
            text_pixel = 16'hE71C;
        if (y >= 12 && y <= 14 && x >= 40 && x <= 44)
            text_pixel = 16'hE71C;

        // D
        if (x >= 53 && x <= 55 && y >= 4 && y <= 14)
            text_pixel = 16'hE71C;
        if (((y >= 4 && y <= 6) || (y >= 12 && y <= 14)) && x >= 56 && x <= 59)
            text_pixel = 16'hE71C;
        if (x >= 60 && x <= 62 && y >= 7 && y <= 11)
            text_pixel = 16'hE71C;

        // I
        if (x >= 65 && x <= 68 && y >= 4 && y <= 14)
            text_pixel = 16'hE71C;

        // E
        if (x >= 71 && x <= 73 && y >= 4 && y <= 14)
            text_pixel = 16'hE71C;
        if ((y >= 4 && y <= 6) || (y >= 8 && y <= 10) || (y >= 12 && y <= 14))
            if (x >= 71 && x <= 77)
                text_pixel = 16'hE71C;

        // D (final)
        if (x >= 80 && x <= 82 && y >= 4 && y <= 14)
            text_pixel = 16'hE71C;
        if (((y >= 4 && y <= 6) || (y >= 12 && y <= 14)) && x >= 83 && x <= 86)
            text_pixel = 16'hE71C;
        if (x >= 87 && x <= 89 && y >= 7 && y <= 11)
            text_pixel = 16'hE71C;
    end

    always @(*) begin
        // Default background (greyscaled)
        pixel = bg_gray;

        // Draw mushroom if not transparent
        if (mush_pixel != 16'h0000)
            pixel = mush_pixel;

        // Draw centered YOU DIED text (on top)
        if (text_pixel != 16'h0000)
            pixel = text_pixel;
    end

endmodule
