`timescale 1ns / 1ps


module mouse_cursor(
    input [6:0] x,           // Current pixel x (0-95)
    input [5:0] y,           // Current pixel y (0-63)
    input [11:0] mouse_x,    // Mouse x position (0-4095)
    input [11:0] mouse_y,    // Mouse y position (0-4095)
    output reg is_cursor     // 1 if current pixel is part of cursor
);

    wire [11:0] temp_x = mouse_x >> 3;  // Divide by 8
    wire [11:0] temp_y = mouse_y >> 3;  // Divide by 8
    
    // Clamp with proper saturation arithmetic
    wire [6:0] cursor_x = (temp_x >= 12'd96) ? 7'd95 : temp_x[6:0];
    wire [5:0] cursor_y = (temp_y >= 12'd64) ? 6'd63 : temp_y[5:0];
    
    // Calculate differences
    wire signed [7:0] dx = x - cursor_x;
    wire signed [6:0] dy = y - cursor_y;

    // Draw a simple crosshair cursor (5x5)
    always @(*) begin
        // Vertical line of cursor (center and cross pattern)
        if ((dx >= -2 && dx <= 2) && (dy >= -2 && dy <= 2)) begin
            if (dx == 0 || dy == 0)
                is_cursor = 1;
            else
                is_cursor = 0;
        end else begin
            is_cursor = 0;
        end
    end
endmodule