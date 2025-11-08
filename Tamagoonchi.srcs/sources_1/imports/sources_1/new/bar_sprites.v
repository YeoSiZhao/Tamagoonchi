`timescale 1ns / 1ps

// Pixel art icon for hunger (meat on bone)
module hunger_icon(
    input  wire [6:0] x,
    input  wire [5:0] y,
    output reg  [15:0] pixel
);
    localparam BLACK = 16'h0000;
    localparam RED = 16'hF800;
    localparam DARK_RED = 16'h8800;
    localparam WHITE = 16'hFFFF;
    localparam BROWN = 16'h7300;
    localparam LIGHT_BROWN = 16'hA514;
    
    // Icon is 17x17 pixels - meat on bone
    always @(*) begin
        pixel = BLACK;
        
        // Meat portion (red circle, top-left)
        if (y >= 2 && y <= 10 && x >= 2 && x <= 10) begin
            // Circular meat shape
            if ((y == 2 || y == 10) && (x >= 4 && x <= 8))
                pixel = DARK_RED;
            else if ((y == 3 || y == 9) && (x >= 3 && x <= 9))
                pixel = RED;
            else if (y >= 4 && y <= 8) begin
                if (x >= 2 && x <= 10)
                    pixel = RED;
                // Highlight
                if ((x == 4 || x == 5) && (y == 4 || y == 5))
                    pixel = WHITE;
            end
        end
        
        // Bone portion (brown, bottom-right)
        else if (y >= 8 && y <= 15) begin
            // Top knob of bone
            if (y >= 8 && y <= 10) begin
                if ((x >= 7 && x <= 9) && (y == 8 || y == 10))
                    pixel = BROWN;
                else if ((x >= 6 && x <= 10) && y == 9)
                    pixel = LIGHT_BROWN;
            end
            // Bone shaft
            else if (y >= 11 && y <= 12) begin
                if (x >= 8 && x <= 9)
                    pixel = LIGHT_BROWN;
            end
            // Bottom knob of bone
            else if (y >= 13 && y <= 15) begin
                if ((x >= 7 && x <= 11) && (y == 13 || y == 15))
                    pixel = BROWN;
                else if ((x >= 6 && x <= 12) && y == 14)
                    pixel = LIGHT_BROWN;
            end
        end
    end
endmodule

`timescale 1ns / 1ps

// Pixel art icon for happiness (smiley face)
module happiness_icon(
    input  wire [6:0] x,
    input  wire [5:0] y,
    output reg  [15:0] pixel
);
    localparam BLACK = 16'h0000;
    localparam YELLOW = 16'hFFE0;
    localparam ORANGE = 16'hFC00;
    
    // Icon is 17x17 pixels - larger smiley face
    wire signed [4:0] dx = (x >= 8) ? (x - 8) : (8 - x);
    wire signed [4:0] dy = (y >= 8) ? (y - 8) : (8 - y);
    wire [9:0] dist_sq = dx*dx + dy*dy;
    
    always @(*) begin
        pixel = BLACK;
        
        // Circle (radius ~7-8 pixels)
        if (dist_sq <= 64) begin
            // Border
            if (dist_sq >= 49)
                pixel = ORANGE;
            // Fill
            else
                pixel = YELLOW;
                
            // Eyes (two black dots) - made sure they're BLACK
            if (((x == 5 || x == 6) && (y == 6 || y == 7)) || 
                ((x == 10 || x == 11) && (y == 6 || y == 7)))
                pixel = BLACK;
                
            // Smile (curved arc)
            if (y >= 10 && y <= 12) begin
                if (y == 10 && (x == 5 || x == 11))
                    pixel = BLACK;
                else if (y == 11 && ((x >= 6 && x <= 7) || (x >= 9 && x <= 10)))
                    pixel = BLACK;
                else if (y == 12 && x == 8)
                    pixel = BLACK;
            end
        end
    end
endmodule

`timescale 1ns / 1ps

// "XP" text renderer (bold, white)
module xp_text(
    input  wire [6:0] x,
    input  wire [5:0] y,
    output reg  [15:0] pixel
);
    localparam BLACK = 16'h0000;
    localparam WHITE = 16'hFFFF;
    localparam BLUE = 16'h001F;
    
    // Text is 17x17 pixels area - larger, bolder XP
    always @(*) begin
        pixel = BLACK;
        
        // Letter "X" (positions 1-7 in x)
        if (x >= 1 && x <= 7 && y >= 3 && y <= 13) begin
            // Top-left to bottom-right diagonal (thicker - 3 pixels)
            if ((x >= 1 && x <= 3) && (y >= 3 && y <= 5))
                pixel = WHITE;
            else if ((x >= 2 && x <= 4) && (y >= 5 && y <= 7))
                pixel = WHITE;
            else if ((x >= 3 && x <= 5) && (y >= 7 && y <= 9))
                pixel = WHITE;
            else if ((x >= 4 && x <= 6) && (y >= 9 && y <= 11))
                pixel = WHITE;
            else if ((x >= 5 && x <= 7) && (y >= 11 && y <= 13))
                pixel = WHITE;
            // Top-right to bottom-left diagonal (thicker - 3 pixels)
            else if ((x >= 5 && x <= 7) && (y >= 3 && y <= 5))
                pixel = WHITE;
            else if ((x >= 4 && x <= 6) && (y >= 5 && y <= 7))
                pixel = WHITE;
            else if ((x >= 3 && x <= 5) && (y >= 7 && y <= 9))
                pixel = WHITE;
            else if ((x >= 2 && x <= 4) && (y >= 9 && y <= 11))
                pixel = WHITE;
            else if ((x >= 1 && x <= 3) && (y >= 11 && y <= 13))
                pixel = WHITE;
        end
        
        // Letter "P" (positions 10-16 in x)
        else if (x >= 10 && x <= 16 && y >= 3 && y <= 13) begin
            // Vertical stem (thicker - 3 pixels wide)
            if ((x >= 10 && x <= 12) && (y >= 3 && y <= 13))
                pixel = WHITE;
            // Top horizontal (thicker - 3 pixels tall)
            else if ((y >= 3 && y <= 5) && (x >= 10 && x <= 15))
                pixel = WHITE;
            // Middle horizontal (thicker - 3 pixels tall)
            else if ((y >= 7 && y <= 9) && (x >= 10 && x <= 15))
                pixel = WHITE;
            // Right vertical segment of P (thicker - 3 pixels wide)
            else if ((x >= 13 && x <= 15) && (y >= 3 && y <= 9))
                pixel = WHITE;
        end
    end
endmodule