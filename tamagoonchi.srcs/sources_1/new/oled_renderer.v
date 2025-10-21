`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NUS EE2026
// Engineer: Wang Chuhao (S1_07)
//
// Module Name: oled_renderer
// Description:
//   Main OLED display renderer for Tamagoonchi.
//   Each bar now has a white frame (padding on all sides)
//   and uses green ? yellow ? red gradient for all bars.
//
//////////////////////////////////////////////////////////////////////////////////

module oled_renderer(
    input clk,
    input feed_mode,
    input sleep_mode,
    input [6:0] x,            // OLED pixel X (0-95)
    input [6:0] y,            // OLED pixel Y (0-63)
    input [7:0] hunger,
    input [7:0] fatigue,
    input [7:0] health,
    input [7:0] hunger_bar_length,
    input [7:0] fatigue_bar_length,
    input [7:0] health_bar_length,
    input btnL_active,
    input btnC_active,
    input btnR_active,
    output reg [15:0] oled_data
);

    ////////////////////////////////////////////////
    // === COLORS ===
    ////////////////////////////////////////////////
    localparam BLACK    = 16'h0000;
    localparam WHITE    = 16'hFFFF;
    localparam RED      = 16'hF800;
    localparam GREEN    = 16'h07E0;
    localparam YELLOW   = 16'hFFE0;
    localparam CYAN     = 16'h07FF;
    localparam DARKBLUE = 16'h0110;

    ////////////////////////////////////////////////
    // === SPRITES ===
    ////////////////////////////////////////////////
    wire apple_hit, burger_hit, drink_hit;
    wire [15:0] apple_pixel, burger_pixel, drink_pixel;

    apple_sprite apple_inst (.x(x), .y(y), .hit(apple_hit), .pixel(apple_pixel));
    burger_sprite burger_inst (.x(x), .y(y), .hit(burger_hit), .pixel(burger_pixel));
    drink_sprite drink_inst (.x(x), .y(y), .hit(drink_hit), .pixel(drink_pixel));

    ////////////////////////////////////////////////
    // === MAIN RENDERING LOGIC ===
    ////////////////////////////////////////////////
    always @(*) begin
        oled_data = BLACK;

        if (feed_mode)
            render_feed_mode();
        else if (sleep_mode)
            render_sleep_mode();
        else
            render_idle_mode();
    end

    ////////////////////////////////////////////////
    // === ? FEED MODE ===
    ////////////////////////////////////////////////
    task render_feed_mode;
        begin
            // --- Food Sprites ---
            if (apple_hit)
                oled_data = btnL_active ? WHITE : apple_pixel;
            else if (burger_hit)
                oled_data = btnC_active ? WHITE : burger_pixel;
            else if (drink_hit)
                oled_data = btnR_active ? WHITE : drink_pixel;

            // --- Selection Borders ---
            else if (y >= 8 && y <= 42) begin
                if (x >= 2 && x <= 32 && btnL_active)
                    oled_data = CYAN;
                else if (x >= 34 && x <= 64 && btnC_active)
                    oled_data = CYAN;
                else if (x >= 66 && x <= 96 && btnR_active)
                    oled_data = CYAN;
            end

            // --- Labels (L/C/R) ---
            if (y >= 46 && y <= 50) begin
                if (x >= 12 && x <= 18)      oled_data = WHITE;
                else if (x >= 44 && x <= 50) oled_data = WHITE;
                else if (x >= 74 && x <= 80) oled_data = WHITE;
            end

            // --- Hunger bar with frame ---
            draw_bar(55, 60, hunger_bar_length, hunger);
        end
    endtask

    ////////////////////////////////////////////////
    // === ? SLEEP MODE ===
    ////////////////////////////////////////////////
    task render_sleep_mode;
        begin
            oled_data = DARKBLUE;  // Background

            // --- Moon ---
            if ((x >= 75 && x <= 88) && (y >= 6 && y <= 16)) begin
                if ((x-81)*(x-81)+(y-11)*(y-11) <= 25)
                    oled_data = WHITE;
                else if ((x-84)*(x-84)+(y-11)*(y-11) <= 20)
                    oled_data = DARKBLUE;
            end

            // --- Stars ---
            if ((x==10 && y==8) || (x==25 && y==15) || (x==60 && y==10))
                oled_data = WHITE;

            // --- Fatigue bar (middle) ---
            draw_bar(50, 55, fatigue_bar_length, fatigue);

            // --- Health bar (bottom) ---
            draw_bar(58, 63, health_bar_length, health);
        end
    endtask

    ////////////////////////////////////////////////
    // === ? IDLE MODE ===
    ////////////////////////////////////////////////
    task render_idle_mode;
        begin
            // --- Health bar (top) ---
            draw_bar(8, 13, health_bar_length, health);

            // --- Hunger bar (middle) ---
            draw_bar(28, 33, hunger_bar_length, hunger);

            // --- Fatigue bar (bottom) ---
            draw_bar(48, 53, fatigue_bar_length, fatigue);
        end
    endtask

    ////////////////////////////////////////////////
    // === Helper task: Draw framed bar ===
    ////////////////////////////////////////////////
    task draw_bar;
        input [6:0] y_top, y_bottom;
        input [7:0] bar_length;
        input [7:0] stat_value;
        begin
            if (y >= y_top && y <= y_bottom) begin
                // --- Inner colored area ---
                if (x >= 5 && x < (5 + bar_length))
                    oled_data = get_color_for_bar(stat_value);

                // --- White frame borders (top, bottom, left, right) ---
                else if ((x >= 3 && x <= 4) || (x >= (5 + bar_length) && x <= 93) ||
                         (y == y_top || y == y_bottom))
                    oled_data = WHITE;
            end
        end
    endtask

    ////////////////////////////////////////////////
    // === Color logic (green ? yellow ? red) ===
    ////////////////////////////////////////////////
    function [15:0] get_color_for_bar;
        input [7:0] value;
        begin
            if (value > 66)
                get_color_for_bar = GREEN;  // High
            else if (value > 33)
                get_color_for_bar = YELLOW; // Medium
            else
                get_color_for_bar = RED;    // Low
        end
    endfunction

endmodule
