`timescale 1ns / 1ps
module collect_render(
    input      clk,
    input      [12:0] pixel_index,
    input      [6:0]  player_x,
    input      [5:0]  player_y,
    input      [6:0]  coin_x,
    input      [5:0]  coin_y,
    input             game_over,
    output reg [15:0] pixel_rgb
);
    localparam W=96, H=64, P_SIZE=10, C_SIZE=6;
    
    // Enhanced color palette
    localparam [15:0] 
        // Tea/Mint green background
        DARK_GREEN  = 16'h8E8D,  // Tea green base
        MED_GREEN   = 16'hAEEF,  // Mint green
        LIGHT_GREEN = 16'hCF51,  // Light mint
        BROWN       = 16'h9E8C,  // Light brown accentbrown
        
        // Mushroom colors
        MUSHROOM_CAP     = 16'hFB60,  // Orange-red cap
        MUSHROOM_SPOT1   = 16'hFFE0,  // Yellow spots
        MUSHROOM_SPOT2   = 16'hFEE0,  // Light yellow
        MUSHROOM_STEM    = 16'hFFDF,  // Cream/beige stem
        MUSHROOM_FACE    = 16'h8C51,  // Darker beige for face
        MUSHROOM_CHEEK   = 16'hF9E7,  // Pink cheeks
        MUSHROOM_EYE     = 16'h4208,  // Dark brown eyes
        
        // Coin colors
        GOLD_BRIGHT = 16'hFEA0,  // Bright gold
        GOLD_MED    = 16'hFD20,  // Medium gold
        GOLD_DARK   = 16'hC480,  // Dark gold
        
        // Effects
        RED = 16'hF800,  // Game over flash
        BLACK = 16'h0000;
    
    wire [6:0] x = pixel_index % W;
    wire [5:0] y = pixel_index / W;
    
    // Player hitbox (invisible, same as P_SIZE)
    wire in_player_box = (x >= player_x && x < player_x + P_SIZE) && 
                         (y >= player_y && y < player_y + P_SIZE);
    
    // Mushroom character positioning (centered in hitbox)
    wire signed [7:0] rel_x = x - player_x - 5;  // Center offset
    wire signed [6:0] rel_y = y - player_y - 5;
    
    // Mushroom cap (rounded top)
    wire cap_top = (rel_y >= -5 && rel_y <= 0) && 
                   (rel_x >= -4 && rel_x <= 4);
    wire cap_mid = (rel_y >= 1 && rel_y <= 2) && 
                   (rel_x >= -5 && rel_x <= 5);
    wire cap_round_edge = (rel_y == -5 && rel_x >= -3 && rel_x <= 3) ||
                          (rel_y == -4 && rel_x >= -4 && rel_x <= 4);
    wire mushroom_cap = cap_top || cap_mid || cap_round_edge;
    
    // Cap spots (decorative circles)
    wire spot1 = (rel_x == -3 || rel_x == -2) && (rel_y == -3 || rel_y == -2);
    wire spot2 = (rel_x == 2 || rel_x == 3) && (rel_y == -1 || rel_y == 0);
    wire spot3 = (rel_x == 0 || rel_x == 1) && (rel_y == -4);
    wire cap_spots = mushroom_cap && (spot1 || spot2 || spot3);
    
    // Mushroom stem (body)
    wire mushroom_stem = (rel_y >= 3 && rel_y <= 5) && 
                         (rel_x >= -3 && rel_x <= 3);
    
    // Face features
    wire left_eye = (rel_x == -2 && rel_y == 3);
    wire right_eye = (rel_x == 2 && rel_y == 3);
    wire mouth_curve = (rel_y == 4) && (rel_x >= -1 && rel_x <= 1);
    wire left_cheek = (rel_x == -3 && rel_y == 4);
    wire right_cheek = (rel_x == 3 && rel_y == 4);
    
    wire mushroom_eyes = left_eye || right_eye;
    wire mushroom_cheeks = left_cheek || right_cheek;
    
    // Coin positioning (circular)
    wire signed [7:0] coin_rel_x = x - coin_x - 3;  // Center of 6px coin
    wire signed [6:0] coin_rel_y = y - coin_y - 3;
    
    // Circular coin shape (radius ~3 pixels)
    wire coin_circle = (coin_rel_x * coin_rel_x + coin_rel_y * coin_rel_y) <= 9;
    wire coin_inner = (coin_rel_x * coin_rel_x + coin_rel_y * coin_rel_y) <= 4;
    wire coin_highlight = (coin_rel_x >= -1 && coin_rel_x <= 0) && 
                          (coin_rel_y >= -2 && coin_rel_y <= -1);
    
    // Forest background pattern (varied greens with some brown accents)
    wire bg_pattern1 = ((x[2:0] ^ y[2:0]) == 3'b010);
    wire bg_pattern2 = ((x[3:1] + y[3:1]) % 5) == 0;
    wire bg_accent = (x[3:0] == 4'b1010) && (y[2:0] == 3'b101);
    
    // "GAME OVER" text pattern (5x7 pixel font, centered on screen)
    // Screen center: x=48, y=32
    // Text starts at x=24, y=28 (to center "GAME OVER")
    wire signed [7:0] text_x = x - 24;
    wire signed [6:0] text_y = y - 28;
    
    // Letter patterns (5 wide x 7 tall, 1px spacing between letters)
    wire letter_G = (text_x >= 0 && text_x < 5 && text_y >= 0 && text_y < 7) &&
                    ((text_y == 0 || text_y == 6) ||  // top & bottom
                     (text_x == 0) ||                  // left edge
                     (text_y >= 3 && text_x == 4) ||   // right edge bottom half
                     (text_y == 3 && text_x >= 2));    // middle bar
    
    wire letter_A = (text_x >= 6 && text_x < 11 && text_y >= 0 && text_y < 7) &&
                    ((text_y == 0) ||                  // top
                     (text_x == 6 || text_x == 10) ||  // sides
                     (text_y == 3));                   // middle bar
    
    wire letter_M = (text_x >= 12 && text_x < 17 && text_y >= 0 && text_y < 7) &&
                    ((text_x == 12 || text_x == 16) ||    // sides
                     (text_x == 13 && text_y <= 2) ||     // left peak
                     (text_x == 15 && text_y <= 2));      // right peak
    
    wire letter_E1 = (text_x >= 18 && text_x < 23 && text_y >= 0 && text_y < 7) &&
                     ((text_x == 18) ||                // left edge
                      (text_y == 0 || text_y == 3 || text_y == 6)); // horizontal bars
    
    wire letter_O1 = (text_x >= 30 && text_x < 35 && text_y >= 0 && text_y < 7) &&
                     ((text_y == 0 || text_y == 6) ||    // top & bottom
                      (text_x == 30 || text_x == 34));   // sides
    
    wire letter_V = (text_x >= 36 && text_x < 41 && text_y >= 0 && text_y < 7) &&
                    (((text_x == 36 || text_x == 40) && text_y < 5) ||  // sides converging
                     ((text_x == 37 || text_x == 39) && text_y >= 5) ||  // lower converge
                     (text_x == 38 && text_y == 6));                     // bottom point
    
    wire letter_E2 = (text_x >= 42 && text_x < 47 && text_y >= 0 && text_y < 7) &&
                     ((text_x == 42) ||                // left edge
                      (text_y == 0 || text_y == 3 || text_y == 6)); // horizontal bars
    
    wire letter_R = (text_x >= 48 && text_x < 53 && text_y >= 0 && text_y < 7) &&
                    ((text_x == 48) ||                     // left edge
                     ((text_y == 0 || text_y == 3) && text_x < 52) ||  // top and middle bars
                     (text_x == 52 && (text_y == 1 || text_y == 2)) || // top right
                     (text_x == 49 + (text_y - 3) && text_y > 3));     // diagonal leg
    
    wire game_over_text = game_over && (letter_G || letter_A || letter_M || letter_E1 || 
                                        letter_O1 || letter_V || letter_E2 || letter_R);
    
    // Pixel color assignment
    always @* begin
        if (game_over_text) begin
            // Show red "GAME OVER" text
            pixel_rgb = RED;
        end
        else if (mushroom_eyes) begin
            // Eyes
            pixel_rgb = MUSHROOM_EYE;
        end
        else if (mushroom_cheeks) begin
            // Cheeks
            pixel_rgb = MUSHROOM_CHEEK;
        end
        else if (mouth_curve) begin
            // Mouth
            pixel_rgb = MUSHROOM_FACE;
        end
        else if (cap_spots) begin
            // Spots on cap
            pixel_rgb = MUSHROOM_SPOT1;
        end
        else if (mushroom_cap) begin
            // Mushroom cap
            pixel_rgb = MUSHROOM_CAP;
        end
        else if (mushroom_stem) begin
            // Mushroom stem/body
            pixel_rgb = MUSHROOM_STEM;
        end
        else if (coin_highlight && coin_circle) begin
            // Coin highlight
            pixel_rgb = GOLD_BRIGHT;
        end
        else if (coin_inner) begin
            // Inner coin
            pixel_rgb = GOLD_MED;
        end
        else if (coin_circle) begin
            // Outer coin edge
            pixel_rgb = GOLD_DARK;
        end
        else if (bg_accent) begin
            // Brown tree trunks accent
            pixel_rgb = BROWN;
        end
        else if (bg_pattern1) begin
            // Medium green patches
            pixel_rgb = MED_GREEN;
        end
        else if (bg_pattern2) begin
            // Light green highlights
            pixel_rgb = LIGHT_GREEN;
        end
        else begin
            // Default dark forest background
            pixel_rgb = DARK_GREEN;
        end
    end
endmodule