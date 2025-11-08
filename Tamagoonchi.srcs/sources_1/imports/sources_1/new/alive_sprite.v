module alive_sprite(
    input  [6:0] x, y,
    output reg [15:0] pixel
);

    // Color palette - MapleStory Orange Mushroom colors
    localparam TRANSPARENT = 16'h0000;  // Black is transparent
    localparam WHITE       = 16'hFFFF;
    localparam ORANGE_DARK = 16'hF800;  // Dark orange for cap
    localparam ORANGE_MID  = 16'hFC20;  // Mid orange
    localparam ORANGE_LIT  = 16'hFE60;  // Light orange/peach
    localparam BROWN_DARK  = 16'h6180;  // Dark brown for outline
    localparam BROWN_MID   = 16'h8A40;  // Mid brown
    localparam BEIGE       = 16'hF7BE;  // Beige for body
    localparam BEIGE_DARK  = 16'hEF5D;  // Dark beige shading
    localparam PINK        = 16'hF99E;  // Pink cheeks
    localparam RED_DARK    = 16'hC800;  // Dark red for mouth
    localparam EYE_BLACK   = 16'h1082;  // Very dark gray for eyes (not pure black)
    
    always @(*) begin
        pixel = TRANSPARENT;
        
        // ==================== MUSHROOM CAP ====================
        // Top of cap (rows 15-20)
        if (y >= 15 && y <= 20) begin
            if (y == 15 && x >= 35 && x <= 60) pixel = BROWN_DARK;
            else if (y == 16) begin
                if (x >= 32 && x <= 34 || x >= 61 && x <= 63) pixel = BROWN_DARK;
                else if (x >= 35 && x <= 60) pixel = ORANGE_DARK;
            end
            else if (y >= 17 && y <= 20) begin
                if (x >= 30 && x <= 31 || x >= 64 && x <= 65) pixel = BROWN_DARK;
                else if (x >= 32 && x <= 44) pixel = ORANGE_DARK;
                else if (x >= 45 && x <= 55) pixel = ORANGE_MID;
                else if (x >= 56 && x <= 63) pixel = ORANGE_DARK;
            end
        end
        
        // Middle cap (rows 21-28) - with white spots
        else if (y >= 21 && y <= 28) begin
            if (x >= 28 && x <= 29 || x >= 66 && x <= 67) pixel = BROWN_DARK;
            else if (x >= 30 && x <= 65) begin
                // White spots pattern
                if ((y >= 22 && y <= 25) && (x >= 38 && x <= 42)) pixel = WHITE;
                else if ((y >= 23 && y <= 26) && (x >= 52 && x <= 56)) pixel = WHITE;
                else if ((y >= 24 && y <= 26) && (x >= 33 && x <= 35)) pixel = WHITE;
                // Orange cap fill
                else if (x >= 30 && x <= 43) pixel = ORANGE_DARK;
                else if (x >= 44 && x <= 54) pixel = ORANGE_MID;
                else pixel = ORANGE_DARK;
            end
        end
        
        // Cap bottom edge (rows 29-30)
        else if (y >= 29 && y <= 30) begin
            if (x >= 26 && x <= 27 || x >= 68 && x <= 69) pixel = BROWN_DARK;
            else if (x >= 28 && x <= 67) pixel = BROWN_MID;
        end
        
        // ==================== MUSHROOM BODY ====================
        // Upper body (rows 31-35)
        else if (y >= 31 && y <= 35) begin
            if (x >= 32 && x <= 33 || x >= 62 && x <= 63) pixel = BROWN_DARK;
            else if (x >= 34 && x <= 61) pixel = BEIGE;
        end
        
        // Face area (rows 36-46)
        else if (y >= 36 && y <= 46) begin
            if (x >= 32 && x <= 33 || x >= 62 && x <= 63) pixel = BROWN_DARK;
            else if (x >= 34 && x <= 61) begin
                // Left eye (solid dark gray, not transparent)
                if (y >= 38 && y <= 41 && x >= 40 && x <= 42) pixel = EYE_BLACK;
                // Right eye  
                else if (y >= 38 && y <= 41 && x >= 52 && x <= 54) pixel = EYE_BLACK;
                // Eye highlights (white sparkle on top)
                else if (y == 38 && (x == 41 || x == 53)) pixel = WHITE;
                
                // Rosy cheeks
                else if (y >= 40 && y <= 42) begin
                    if (x >= 36 && x <= 38) pixel = PINK;
                    else if (x >= 57 && x <= 59) pixel = PINK;
                    else pixel = BEIGE;
                end
                
                // Happy smile mouth (curved upward U-shape)
                // Bottom of smile
                else if (y == 44 && x >= 45 && x <= 49) pixel = RED_DARK;
                // Left curve upward
                else if (y == 43 && (x >= 43 && x <= 44)) pixel = RED_DARK;
                // Right curve upward
                else if (y == 43 && (x >= 50 && x <= 51)) pixel = RED_DARK;
                
                // Body shading
                else if (x >= 58 && x <= 61) pixel = BEIGE_DARK;
                else pixel = BEIGE;
            end
        end
        
        // Lower body (rows 47-52)
        else if (y >= 47 && y <= 52) begin
            if (x >= 34 && x <= 35 || x >= 60 && x <= 61) pixel = BROWN_DARK;
            else if (x >= 36 && x <= 59) begin
                if (x >= 56 && x <= 59) pixel = BEIGE_DARK;
                else pixel = BEIGE;
            end
        end
        
        // Bottom edge (row 53)
        else if (y == 53) begin
            if (x >= 36 && x <= 59) pixel = BROWN_DARK;
        end
        
        // ==================== FEET ====================
        // Left foot
        else if (y >= 54 && y <= 56) begin
            if (x >= 38 && x <= 43) begin
                if (y == 54) pixel = BROWN_DARK;
                else pixel = BEIGE_DARK;
            end
            // Right foot
            else if (x >= 52 && x <= 57) begin
                if (y == 54) pixel = BROWN_DARK;
                else pixel = BEIGE_DARK;
            end
        end
    end

endmodule