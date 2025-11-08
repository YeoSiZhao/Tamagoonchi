`timescale 1ns / 1ps

module maplestory_background(
    input  [6:0] x,
    input  [5:0] y,
    output reg [15:0] pixel
);

    // Color palette
    localparam SKY_LIGHT      = 16'h6D7F;  // Light sky blue
    localparam SKY_MID        = 16'h5D5F;  // Mid sky blue
    localparam CLOUD_WHITE    = 16'hFFFF;  // White clouds
    localparam HILL_DARK      = 16'h2320;  // Dark green hills
    localparam HILL_MID       = 16'h3460;  // Mid green hills
    localparam GRASS_BRIGHT   = 16'h07E0;  // Bright grass
    localparam GRASS_MID      = 16'h05C0;  // Mid grass
    localparam DIRT_BROWN     = 16'h7240;  // Brown dirt
    localparam BG_MAIN        = 16'h4D9F;  // Light blue-green background
    localparam FLOWER_RED     = 16'hF800;  // Red flower
    localparam FLOWER_YELLOW  = 16'hFFE0;  // Yellow flower
    localparam FLOWER_PINK    = 16'hF99E;  // Pink flower
    localparam STEM_GREEN     = 16'h04E0;  // Flower stem
    localparam SUN_YELLOW     = 16'hFFE0;  // Sun
    localparam TREE_TRUNK     = 16'h6180;  // Tree trunk brown
    localparam TREE_LEAVES    = 16'h2C60;  // Tree leaves green

    always @(*) begin
        pixel = 16'h0000;  // Default black

        if (y < 6) begin
            pixel = SKY_LIGHT;
        end
        else if (y >= 6 && y < 12) begin
            pixel = SKY_MID;
        end

        if ((x >= 75 && x <= 80) && (y >= 3 && y <= 8)) begin
            // Simple sun circle
            if ((x - 77) * (x - 77) + (y - 5) * (y - 5) <= 9)
                pixel = SUN_YELLOW;
        end

        // Left cloud
        if (y >= 4 && y <= 8) begin
            if ((x >= 10 && x <= 22) && 
                ((x - 16) * (x - 16) + (y - 6) * (y - 6) <= 16))
                pixel = CLOUD_WHITE;
        end
        // Right cloud  
        if (y >= 5 && y <= 9) begin
            if ((x >= 60 && x <= 72) && 
                ((x - 66) * (x - 66) + (y - 7) * (y - 7) <= 16))
                pixel = CLOUD_WHITE;
        end

        if (y >= 12 && y <= 20) begin
            // Left hill
            if (x < 40) begin
                if (y >= 12 + (x / 4) && y <= 20)
                    pixel = HILL_DARK;
            end
            // Right hill
            else if (x >= 50) begin
                if (y >= 12 + ((95 - x) / 4) && y <= 20)
                    pixel = HILL_MID;
            end
            // Valley between
            else begin
                if (y >= 16)
                    pixel = HILL_DARK;
            end
        end

        if (y >= 21 && y <= 53) begin
            pixel = BG_MAIN;
            
            // Left tree
            if (x >= 8 && x <= 12 && y >= 30 && y <= 48) begin
                pixel = TREE_TRUNK;  // Trunk
            end
            if (x >= 5 && x <= 15 && y >= 25 && y <= 35) begin
                if ((x - 10) * (x - 10) + (y - 30) * (y - 30) <= 30)
                    pixel = TREE_LEAVES;  // Leaves
            end
            
            // Right tree
            if (x >= 83 && x <= 87 && y >= 32 && y <= 50) begin
                pixel = TREE_TRUNK;  // Trunk
            end
            if (x >= 80 && x <= 90 && y >= 27 && y <= 37) begin
                if ((x - 85) * (x - 85) + (y - 32) * (y - 32) <= 30)
                    pixel = TREE_LEAVES;  // Leaves
            end
            
            // Small flowers scattered on ground
            // Red flower 1
            if ((y >= 47 && y <= 49) && (x >= 20 && x <= 22))
                pixel = FLOWER_RED;
            if ((y >= 49 && y <= 51) && (x == 21))
                pixel = STEM_GREEN;
                
            // Yellow flower
            if ((y >= 48 && y <= 50) && (x >= 35 && x <= 37))
                pixel = FLOWER_YELLOW;
            if ((y >= 50 && y <= 52) && (x == 36))
                pixel = STEM_GREEN;
                
            // Pink flower
            if ((y >= 46 && y <= 48) && (x >= 70 && x <= 72))
                pixel = FLOWER_PINK;
            if ((y >= 48 && y <= 50) && (x == 71))
                pixel = STEM_GREEN;
                
            // Red flower 2
            if ((y >= 49 && y <= 51) && (x >= 55 && x <= 57))
                pixel = FLOWER_RED;
            if ((y >= 51 && y <= 53) && (x == 56))
                pixel = STEM_GREEN;
        end

        if (y >= 54 && y <= 63) begin
            if (y == 54) begin
                // Grass top with pattern for texture
                if ((x % 8 < 3) || ((x + 4) % 8 < 2))
                    pixel = GRASS_BRIGHT;
                else
                    pixel = GRASS_MID;
            end
            else if (y == 55) begin
                // Grass transition
                pixel = GRASS_MID;
            end
            else begin
                // Dirt/soil below grass
                pixel = DIRT_BROWN;
                // Add some texture to dirt
                if ((x + y) % 7 < 2)
                    pixel = 16'h6A00;  // Slightly darker brown for texture
            end
        end
    end

endmodule