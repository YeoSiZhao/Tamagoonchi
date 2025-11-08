`timescale 1ns / 1ps


module pet_jump_controller(
    input clk,
    input mouse_left,
    input [6:0] mouse_x,      // Scaled mouse X position (0-95)
    input [5:0] mouse_y,      // Scaled mouse Y position (0-63)
    input dead,               // Pet is dead
    output reg [5:0] jump_offset,  // Vertical offset for pet (0-20)
    output reg is_jumping,    // Currently in jump animation
    output reg happiness_boost_pulse  // Pulse when happiness should increase
);

    localparam PET_X_MIN = 0;     // Full width for easier clicking
    localparam PET_X_MAX = 95;   
    localparam PET_Y_MIN = 20;    // Mushroom appears in lower portion of screen
    localparam PET_Y_MAX = 63;    // Bottom of screen
    
    // Jump animation parameters
    localparam JUMP_HEIGHT = 20;      // Maximum jump height in pixels
    localparam JUMP_DURATION = 30;    // Total frames for jump animation
    localparam JUMP_UP_FRAMES = 15;   // Frames going up
    
    // Mouse click detection with proper synchronization
    reg mouse_left_prev;
    reg mouse_left_sync;
    
    always @(posedge clk) begin
        mouse_left_sync <= mouse_left;
        mouse_left_prev <= mouse_left_sync;
    end
    
    wire mouse_click = mouse_left_sync & ~mouse_left_prev;
    
    // Check if mouse is on pet
    wire mouse_on_pet = (mouse_x >= PET_X_MIN) && (mouse_x <= PET_X_MAX) &&
                        (mouse_y >= PET_Y_MIN) && (mouse_y <= PET_Y_MAX);
    
    wire pet_clicked = mouse_click & mouse_on_pet & ~dead;
    
    // Jump animation state machine
    reg [5:0] jump_counter;
    
    // Slow down the animation with a frame divider
    // Faster animation for better responsiveness
    localparam FRAME_DIV = 1000000;  // Faster: 100MHz / 1M = 100Hz (was 2M/50Hz)
    reg [19:0] frame_div_counter;    // Adjusted size for new FRAME_DIV
    wire frame_tick = (frame_div_counter == 0);
    
    // Debug registers - you can view these in simulation or ILA
    reg [31:0] click_count;
    reg last_pet_clicked;
    reg pet_clicked_reg;
    
    
    always @(posedge clk) begin
        // Default: no happiness boost pulse
        happiness_boost_pulse <= 0;
        
        // Frame divider for animation timing
        if (frame_div_counter == FRAME_DIV - 1)
            frame_div_counter <= 0;
        else
            frame_div_counter <= frame_div_counter + 1;
        
        // Debug: Count clicks on pet
        last_pet_clicked <= pet_clicked;
        if (pet_clicked && !last_pet_clicked) begin
            click_count <= click_count + 1;
            pet_clicked_reg <= 1;
        end else begin
            pet_clicked_reg <= 0;
        end
        
        // Jump animation controller
        if (pet_clicked && !is_jumping) begin
            // Start jump and boost happiness!
            is_jumping <= 1;
            jump_counter <= 0;
            jump_offset <= 0;
            happiness_boost_pulse <= 1;  
        end else if (pet_clicked && is_jumping) begin
            // Clicked while already jumping - boost happiness!
            happiness_boost_pulse <= 1;
        end else if (is_jumping && frame_tick) begin
            if (jump_counter < JUMP_DURATION) begin
                jump_counter <= jump_counter + 1;
                
                // Calculate parabolic jump trajectory
                if (jump_counter < JUMP_UP_FRAMES) begin
                    // Going up: linear increase
                    jump_offset <= (jump_counter * JUMP_HEIGHT) / JUMP_UP_FRAMES;
                end else begin
                    // Coming down: linear decrease
                    jump_offset <= JUMP_HEIGHT - ((jump_counter - JUMP_UP_FRAMES) * JUMP_HEIGHT) / (JUMP_DURATION - JUMP_UP_FRAMES);
                end
            end else begin
                // Jump complete
                is_jumping <= 0;
                jump_offset <= 0;
            end
        end
        
        // Reset if pet dies
        if (dead) begin
            is_jumping <= 0;
            jump_offset <= 0;
            jump_counter <= 0;
            click_count <= 0;
        end
    end
endmodule
