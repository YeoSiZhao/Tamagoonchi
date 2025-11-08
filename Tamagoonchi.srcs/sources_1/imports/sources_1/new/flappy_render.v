`timescale 1ns / 1ps
module flappy_render(
    input [12:0] pixel_index,
    input [6:0] bird_y,
    input [7:0] pipe_x,
    input [5:0] gap_y,
    input game_over,
    output reg [15:0] pixel_rgb
);
    wire [6:0] x = pixel_index % 96;
    wire [6:0] y = pixel_index / 96;
    
    // Color definitions
    localparam BLACK = 16'h0000;
    localparam SKY   = 16'h5D9F;      // Light blue sky
    localparam GREEN = 16'h07E0;      // Pipe body
    localparam DARK_GREEN = 16'h0540; // Pipe shadow
    localparam PIPE_HIGHLIGHT = 16'h0FE0; // Pipe highlight
    localparam BROWN = 16'h8200;      // Ground color
    
    // Mushroom colors
    localparam MUSHROOM_CAP     = 16'hFD20;  // Orange cap
    localparam MUSHROOM_CAP_DARK = 16'hC480; // Darker orange edge
    localparam MUSHROOM_SPOT    = 16'hFFE0;  // Yellow spots
    localparam MUSHROOM_BODY    = 16'hFFDF;  // Cream body
    localparam MUSHROOM_FACE    = 16'h8C51;  // Light brown for face details
    localparam MUSHROOM_CHEEK   = 16'hFBAE;  // Pink cheeks
    localparam MUSHROOM_EYE     = 16'h4208;  // Dark brown eyes
    localparam RED = 16'hF800;               // Game over mushroom
    
    // Mushroom parameters
    localparam MUSHROOM_X = 10;
    localparam MUSHROOM_SIZE = 7;
    
    // Pipe parameters
    localparam PIPE_WIDTH = 8;
    localparam GAP_SIZE = 20;
    
    // Calculate relative positions
    wire [6:0] mushroom_rel_x = x - MUSHROOM_X;
    wire [6:0] mushroom_rel_y = y - bird_y;
    
    // Mushroom boundaries
    wire in_mushroom_box = (x >= MUSHROOM_X && x < MUSHROOM_X + MUSHROOM_SIZE) && 
                           (y >= bird_y && y < bird_y + MUSHROOM_SIZE);
    
    // Mushroom cap (rounded top, orange with yellow spots)
    wire mushroom_cap = in_mushroom_box && (
        // Top rounded part (rows 0-3)
        (mushroom_rel_y == 0 && mushroom_rel_x >= 2 && mushroom_rel_x <= 4) ||
        (mushroom_rel_y == 1 && mushroom_rel_x >= 1 && mushroom_rel_x <= 5) ||
        (mushroom_rel_y == 2 && mushroom_rel_x >= 0 && mushroom_rel_x <= 6) ||
        (mushroom_rel_y == 3 && mushroom_rel_x >= 0 && mushroom_rel_x <= 6)
    );
    
    // Cap edge (darker outline)
    wire cap_edge = in_mushroom_box && mushroom_cap && (
        (mushroom_rel_y == 3 && (mushroom_rel_x == 0 || mushroom_rel_x == 6)) ||
        (mushroom_rel_y == 2 && (mushroom_rel_x == 0 || mushroom_rel_x == 6))
    );
    
    // Yellow spots on cap
    wire spot1 = mushroom_cap && (mushroom_rel_x == 1 && mushroom_rel_y == 1);
    wire spot2 = mushroom_cap && (mushroom_rel_x == 3 && mushroom_rel_y == 1);
    wire spot3 = mushroom_cap && (mushroom_rel_x == 5 && mushroom_rel_y == 1);
    wire spot4 = mushroom_cap && (mushroom_rel_x == 2 && mushroom_rel_y == 3);
    wire spot5 = mushroom_cap && (mushroom_rel_x == 4 && mushroom_rel_y == 3);
    wire mushroom_spots = spot1 || spot2 || spot3 || spot4 || spot5;
    
    // Mushroom body/stem (cream colored, rows 4-6)
    wire mushroom_body = in_mushroom_box && (
        (mushroom_rel_y == 4 && mushroom_rel_x >= 1 && mushroom_rel_x <= 5) ||
        (mushroom_rel_y == 5 && mushroom_rel_x >= 1 && mushroom_rel_x <= 5) ||
        (mushroom_rel_y == 6 && mushroom_rel_x >= 2 && mushroom_rel_x <= 4)
    );
    
    // Cute face on body
    wire left_eye = in_mushroom_box && (mushroom_rel_x == 2 && mushroom_rel_y == 4);
    wire right_eye = in_mushroom_box && (mushroom_rel_x == 4 && mushroom_rel_y == 4);
    wire left_cheek = in_mushroom_box && (mushroom_rel_x == 1 && mushroom_rel_y == 5);
    wire right_cheek = in_mushroom_box && (mushroom_rel_x == 5 && mushroom_rel_y == 5);
    wire mouth = in_mushroom_box && (mushroom_rel_x == 3 && mushroom_rel_y == 5);
    
    wire in_mushroom = mushroom_cap || mushroom_body;
    
    // Pipe boundaries
    wire in_pipe_x = (x >= pipe_x && x < pipe_x + PIPE_WIDTH);
    wire in_gap = (y >= gap_y && y < gap_y + GAP_SIZE);
    wire in_pipe = in_pipe_x && !in_gap;
    
    // Pipe cap (wider top/bottom of pipe sections)
    wire pipe_cap_top = (y == gap_y - 1 || y == gap_y - 2) && 
                        (x >= pipe_x - 1 && x < pipe_x + PIPE_WIDTH + 1);
    wire pipe_cap_bottom = (y == gap_y + GAP_SIZE || y == gap_y + GAP_SIZE + 1) && 
                           (x >= pipe_x - 1 && x < pipe_x + PIPE_WIDTH + 1);
    
    // Pipe 3D effect edges
    wire pipe_left_edge = (x == pipe_x) && in_pipe;
    wire pipe_right_edge = (x == pipe_x + PIPE_WIDTH - 1) && in_pipe;
    wire pipe_inner = in_pipe && !pipe_left_edge && !pipe_right_edge;
    
    // Ground line
    wire on_ground = (y >= 62);
    
    always @(*) begin
        // Default: sky background
        pixel_rgb = SKY;
        
        // Draw ground
        if (on_ground) begin
            if (y == 62)
                pixel_rgb = BROWN;
            else
                pixel_rgb = 16'h6200;  // Darker brown
        end
        
        // Draw pipe caps (wider sections)
        else if (pipe_cap_top || pipe_cap_bottom) begin
            pixel_rgb = GREEN;
        end
        
        // Draw pipe body with 3D effect
        else if (in_pipe) begin
            if (pipe_left_edge)
                pixel_rgb = PIPE_HIGHLIGHT;  // Light edge
            else if (pipe_right_edge)
                pixel_rgb = DARK_GREEN;      // Dark edge
            else
                pixel_rgb = GREEN;           // Body
        end
        
        // Draw mushroom (top layer)
        if (in_mushroom) begin
            if (game_over)
                pixel_rgb = RED;                    // Dead mushroom
            else if (left_eye || right_eye)
                pixel_rgb = MUSHROOM_EYE;           // Eyes
            else if (left_cheek || right_cheek)
                pixel_rgb = MUSHROOM_CHEEK;         // Cheeks
            else if (mouth)
                pixel_rgb = MUSHROOM_FACE;          // Mouth
            else if (mushroom_spots)
                pixel_rgb = MUSHROOM_SPOT;          // Yellow spots
            else if (cap_edge)
                pixel_rgb = MUSHROOM_CAP_DARK;      // Darker cap edge
            else if (mushroom_cap)
                pixel_rgb = MUSHROOM_CAP;           // Orange cap
            else if (mushroom_body)
                pixel_rgb = MUSHROOM_BODY;          // Cream body
        end
    end
endmodule