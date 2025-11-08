`timescale 1ns / 1ps

module idle_scene(
    input  wire        clk,
    input  wire        dead,         
    input  wire [6:0]  x,
    input  wire [5:0]  y,
    input  wire [5:0]  jump_offset,   // Jump offset input (0 = ground level)
    output reg  [15:0] pixel
);

    reg [6:0] mushroom_x = 7'd48;     
    reg direction = 1'b1;             // 1 = right, 0 = left
    reg [25:0] move_counter = 0;
    localparam MOVE_SPEED = 26'd25_000_000;
    localparam LEFT_EDGE  = 7'd15;
    localparam RIGHT_EDGE = 7'd80;
    
    // Movement logic
    always @(posedge clk) begin
        if (!dead) begin
            if (move_counter >= MOVE_SPEED) begin
                move_counter <= 0;
                if (direction) begin
                    if (mushroom_x >= RIGHT_EDGE) begin
                        direction <= 1'b0;
                        mushroom_x <= mushroom_x - 1;
                    end else begin
                        mushroom_x <= mushroom_x + 1;
                    end
                end else begin
                    if (mushroom_x <= LEFT_EDGE) begin
                        direction <= 1'b1;
                        mushroom_x <= mushroom_x + 1;
                    end else begin
                        mushroom_x <= mushroom_x - 1;
                    end
                end
            end else begin
                move_counter <= move_counter + 1;
            end
        end
        else begin
            // Freeze mushroom position when dead
            move_counter <= move_counter;
            direction <= direction;
            mushroom_x <= mushroom_x;
        end
    end

    wire signed [7:0] rel_x = x - mushroom_x;

    wire [6:0] y_with_jump = y + jump_offset;
    wire [5:0] mushroom_local_y = (y_with_jump > 63) ? 6'd63 : y_with_jump[5:0];

    wire [6:0] mushroom_local_x = direction ? (48 + rel_x) : (48 - rel_x);

    wire in_mushroom_bounds = (rel_x >= -15 && rel_x <= 15) && 
                              (mushroom_local_x >= 0 && mushroom_local_x < 96) &&
                              (y_with_jump <= 63);
    
    wire [15:0] mushroom_pixel;
    alive_sprite mushroom (
        .x(mushroom_local_x),
        .y(mushroom_local_y),
        .pixel(mushroom_pixel)
    );
    
    wire [15:0] dead_pixel;
    dead_sprite u_dead_scene (
        .clk(clk),
        .x(x),
        .y(y),
        .mushroom_x(mushroom_x),
        .pixel(dead_pixel)
    );
    wire [15:0] bg_pixel;
    maplestory_background background (
        .x(x),
        .y(y),
        .pixel(bg_pixel)
    );

    always @(*) begin
        if (dead)
            pixel = dead_pixel;  
        else if (in_mushroom_bounds && mushroom_pixel != 16'h0000)
            pixel = mushroom_pixel; 
        else
            pixel = bg_pixel;       
    end
endmodule
