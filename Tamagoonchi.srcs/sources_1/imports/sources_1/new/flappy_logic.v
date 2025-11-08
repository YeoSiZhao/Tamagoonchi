`timescale 1ns / 1ps
module flappy_logic(
    input clk,
    input enable,
    input btnU,            
    input btnC,           
    output reg [6:0] bird_y = 30,
    output reg [7:0] pipe_x = 95,
    output reg [5:0] gap_y = 25,
    output reg [7:0] score = 0,
    output reg game_over = 0
);

    localparam PIPE_SPEED = 1;
    localparam BIRD_SPEED = 2;     
    localparam GAP_SIZE   = 20;
    localparam BIRD_SIZE  = 7;     

    localparam [1:0] DIR_IDLE = 2'd0, DIR_UP = 2'd1, DIR_DOWN = 2'd2;
    reg [1:0] dir = DIR_DOWN;  // Start moving down by default

    reg [15:0] rand = 16'hACE1;
    always @(posedge clk)
        rand <= {rand[14:0], rand[15]^rand[13]^rand[12]^rand[10]};

    reg [21:0] tick = 0;
    wire update = (tick == 0);
    always @(posedge clk) tick <= tick + 1;

    reg btnU_prev = 0;
    reg btnC_prev = 0;
    wire btnU_edge = btnU && !btnU_prev;
    wire btnC_edge = btnC && !btnC_prev;

    reg started = 0;

    always @(posedge clk) begin
        btnU_prev <= btnU;
        btnC_prev <= btnC;

        if (!enable || btnC_edge) begin
            bird_y    <= 30;
            pipe_x    <= 95;
            gap_y     <= 25;
            score     <= 0;
            game_over <= 0;
            dir       <= DIR_DOWN;
            started   <= 0;
        end

        else if (enable && !game_over) begin
            if (!started && btnU_edge) begin
                started <= 1;
                dir <= DIR_UP;
            end
            else if (started && btnU_edge) begin
                if (dir == DIR_UP)
                    dir <= DIR_DOWN;
                else
                    dir <= DIR_UP;
            end

            if (update && started) begin
                case (dir)
                    DIR_UP: begin
                        if (bird_y > BIRD_SPEED)
                            bird_y <= bird_y - BIRD_SPEED;
                        else
                            bird_y <= 0;
                    end
                    DIR_DOWN: begin
                        if (bird_y < 63 - BIRD_SIZE - BIRD_SPEED)
                            bird_y <= bird_y + BIRD_SPEED;
                        else
                            bird_y <= 63 - BIRD_SIZE;
                    end
                    default: bird_y <= bird_y;
                endcase

                // Pipe movement
                if (pipe_x > 0)
                    pipe_x <= pipe_x - PIPE_SPEED;
                else begin
                    pipe_x <= 95;
                    gap_y  <= (rand[5:0] % 35) + 10;
                    score  <= score + 1;
                end

                if (bird_y <= 0 || bird_y >= 63 - BIRD_SIZE)
                    game_over <= 1;
                else if (pipe_x < 10 + BIRD_SIZE && pipe_x + 8 > 10) begin
                    if (bird_y < gap_y || bird_y + BIRD_SIZE > gap_y + GAP_SIZE)
                        game_over <= 1;
                end
            end
        end
    end
endmodule

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
    localparam YELLOW = 16'hFFE0;     // Bird color
    localparam ORANGE = 16'hFC00;     // Bird accent
    localparam RED = 16'hF800;        // Game over bird
    localparam BROWN = 16'h8200;      // Ground color
    localparam WHITE = 16'hFFFF;      // Bird eye
    
    // Bird parameters
    localparam BIRD_X = 10;
    localparam BIRD_SIZE = 6;
    
    // Pipe parameters
    localparam PIPE_WIDTH = 8;
    localparam GAP_SIZE = 20;
    
    // Calculate relative positions
    wire [6:0] bird_rel_x = x - BIRD_X;
    wire [6:0] bird_rel_y = y - bird_y;
    
    // Bird boundaries
    wire in_bird_box = (x >= BIRD_X && x < BIRD_X + BIRD_SIZE) && 
                       (y >= bird_y && y < bird_y + BIRD_SIZE);
    
    // Bird shape (6x6 bird with rounded body)
    // Body - rounded oval shape
    wire bird_body = in_bird_box && (
        // Center mass (rows 1-4)
        ((bird_rel_y >= 1 && bird_rel_y <= 4) && (bird_rel_x >= 1 && bird_rel_x <= 4)) ||
        // Top row (row 0) - partial
        (bird_rel_y == 0 && bird_rel_x >= 2 && bird_rel_x <= 3) ||
        // Bottom row (row 5) - partial
        (bird_rel_y == 5 && bird_rel_x >= 2 && bird_rel_x <= 3) ||
        // Side extensions for rounder look
        (bird_rel_y == 2 && bird_rel_x == 0) ||
        (bird_rel_y == 3 && bird_rel_x == 0)
    );
    
    // Head area (upper front portion)
    wire bird_head = in_bird_box && (
        ((bird_rel_y >= 1 && bird_rel_y <= 2) && (bird_rel_x >= 3 && bird_rel_x <= 4))
    );
    
    // Wing shape (small wing on side)
    wire bird_wing = in_bird_box && (
        ((bird_rel_y == 3 || bird_rel_y == 4) && bird_rel_x == 1)
    );
    
    // Eye (white with black pupil)
    wire bird_eye_white = in_bird_box && (bird_rel_x == 4 && bird_rel_y == 1);
    wire bird_eye_pupil = in_bird_box && (bird_rel_x == 4 && bird_rel_y == 1);
    
    // Beak (orange triangle pointing right)
    wire bird_beak = in_bird_box && (
        (bird_rel_x == 5 && bird_rel_y == 2) ||
        (bird_rel_x == 5 && bird_rel_y == 3)
    );
    
    // Tail feathers (back of bird)
    wire bird_tail = in_bird_box && (
        (bird_rel_x == 0 && bird_rel_y == 1) ||
        (bird_rel_x == 0 && bird_rel_y == 4)
    );
    
    wire in_bird = bird_body || bird_wing || bird_tail;
    
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
        
        // Draw bird (top layer)
        if (in_bird) begin
            if (game_over)
                pixel_rgb = RED;             // Dead bird
            else if (bird_eye_white)
                pixel_rgb = WHITE;           // Eye white
            else if (bird_beak)
                pixel_rgb = ORANGE;          // Beak
            else if (bird_wing)
                pixel_rgb = ORANGE;          // Wing accent
            else if (bird_tail)
                pixel_rgb = ORANGE;          // Tail feathers
            else
                pixel_rgb = YELLOW;          // Body
        end
    end
endmodule