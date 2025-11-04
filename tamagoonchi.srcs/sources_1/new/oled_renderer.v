`timescale 1ns / 1ps

module oled_renderer(
    input clk,
    input feed_mode,
    input play_mode,
    input paint_mode,
    input [6:0] x,
    input [6:0] y,
    input [7:0] hunger,
    input [7:0] xp,
    input [7:0] happiness,
    input [7:0] hunger_bar_length,
    input [7:0] xp_bar_length,
    input [7:0] happiness_bar_length,
    input btnL_active,
    input btnC_active,
    input btnR_active,
    input dead,                    // <-- NEW
    output reg [15:0] oled_data
);

    // Colors
    localparam BLACK    = 16'h0000;
    localparam WHITE    = 16'hFFFF;
    localparam RED      = 16'hF800;
    localparam GREEN    = 16'h07E0;
    localparam YELLOW   = 16'hFFE0;
    localparam CYAN     = 16'h07FF;
    localparam DARKBLUE = 16'h0110;  // dark blue for XP fill
    localparam YELLOW_BALL = 16'hFFE0;

    // Feed sprites (if you have these modules already)
    wire apple_hit, burger_hit, drink_hit;
    wire [15:0] apple_pixel, burger_pixel, drink_pixel;
    apple_sprite  apple_inst  (.x(x), .y(y), .hit(apple_hit), .pixel(apple_pixel));
    burger_sprite burger_inst (.x(x), .y(y), .hit(burger_hit), .pixel(burger_pixel));
    drink_sprite  drink_inst  (.x(x), .y(y), .hit(drink_hit),  .pixel(drink_pixel));

    // Play vars
    reg [6:0] ball_x = 48, ball_y = 32, paddle_x = 40;
    reg ball_dx = 1, ball_dy = 1;
    reg [19:0] frame_counter = 0;

    always @(posedge clk) begin
        frame_counter <= frame_counter + 1;

        if (btnL_active && paddle_x > 3)      paddle_x <= paddle_x - 2;
        else if (btnR_active && paddle_x < 80) paddle_x <= paddle_x + 2;

        if (frame_counter[17]) begin
            ball_x <= ball_x + (ball_dx ? 1 : -1);
            ball_y <= ball_y + (ball_dy ? 1 : -1);
            if (ball_x <= 2 || ball_x >= 92) ball_dx <= ~ball_dx;
            if (ball_y <= 2)                 ball_dy <= ~ball_dy;
            if (ball_y >= 54 && ball_y <= 56 && ball_x >= paddle_x && ball_x <= paddle_x + 16)
                ball_dy <= 0;
            else if (ball_y >= 63)
                ball_y <= 32;
        end
    end

    // Main render
    always @(*) begin
        oled_data = BLACK;

        if (dead) begin
            render_dead_bars();                 // <-- OVERRIDE when dead
        end else if (feed_mode) begin
            render_feed_mode();
        end else if (play_mode) begin
            render_play_mode();
        end else if (paint_mode) begin
            render_paint_mode();
        end else begin
            render_idle_mode();
        end
    end

    // ----- Modes -----

    task render_feed_mode;
        begin
            if (apple_hit)       oled_data = btnL_active ? WHITE : apple_pixel;
            else if (burger_hit) oled_data = btnC_active ? WHITE : burger_pixel;
            else if (drink_hit)  oled_data = btnR_active ? WHITE : drink_pixel;

            // selection borders
            else if (y >= 8 && y <= 42) begin
                if (x >= 2  && x <= 32 && btnL_active)       oled_data = CYAN;
                else if (x >= 34 && x <= 64 && btnC_active) oled_data = CYAN;
                else if (x >= 66 && x <= 96 && btnR_active) oled_data = CYAN;
            end

            // labels (optional)
            if (y >= 46 && y <= 50) begin
                if (x >= 12 && x <= 18)      oled_data = WHITE;
                else if (x >= 44 && x <= 50) oled_data = WHITE;
                else if (x >= 74 && x <= 80) oled_data = WHITE;
            end

            // Bars (bottom only for feed, or keep your preferred layout)
            draw_bar_dyn(55, 60, hunger_bar_length, hunger);   // dynamic G/Y/R
        end
    endtask

    task render_play_mode;
        begin
            if (x == 0 || x == 95 || y == 0 || y == 63) oled_data = WHITE;
            if (y >= 57 && y <= 59 && x >= paddle_x && x <= paddle_x + 16) oled_data = CYAN;
            if ((x - ball_x)*(x - ball_x) + (y - ball_y)*(y - ball_y) <= 4) oled_data = YELLOW_BALL;
        end
    endtask

    task render_paint_mode;
        begin
            // minimalist placeholder (you can keep your grid/cursor logic here)
            if ((x % 8 == 0) || (y % 8 == 0)) oled_data = WHITE;
        end
    endtask

    task render_idle_mode;
        begin
            // Hunger = dynamic color; XP = DARK BLUE; Happiness = dynamic color
            draw_bar_dyn  (8,  13, hunger_bar_length,    hunger);
            draw_bar_fixed(28, 33, xp_bar_length,        DARKBLUE);
            draw_bar_dyn  (48, 53, happiness_bar_length, happiness);
        end
    endtask

    // ----- Dead override -----

    task render_dead_bars;
        begin
            // All three bars full RED (length is already 90 when dead, but force color here)
            draw_bar_fixed(8,  13, 8'd90, RED);
            draw_bar_fixed(28, 33, 8'd90, RED);
            draw_bar_fixed(48, 53, 8'd90, RED);
        end
    endtask

    // ----- Helpers -----

    // Dynamic color (green/yellow/red by stat value)
    task draw_bar_dyn;
        input [6:0] y_top, y_bot;
        input [7:0] len;
        input [7:0] stat_value;
        begin
            if (y >= y_top && y <= y_bot) begin
                if (x >= 5 && x < (5 + len))
                    oled_data = get_color_for_bar(stat_value);
                else if ((x >= 3 && x <= 4) || (x >= (5 + len) && x <= 93) ||
                         (y == y_top || y == y_bot))
                    oled_data = WHITE;
            end
        end
    endtask

    // Fixed color fill (used for XP and dead state)
    task draw_bar_fixed;
        input [6:0] y_top, y_bot;
        input [7:0] len;
        input [15:0] color;
        begin
            if (y >= y_top && y <= y_bot) begin
                if (x >= 5 && x < (5 + len))
                    oled_data = color;
                else if ((x >= 3 && x <= 4) || (x >= (5 + len) && x <= 93) ||
                         (y == y_top || y == y_bot))
                    oled_data = WHITE;
            end
        end
    endtask

    function [15:0] get_color_for_bar;
        input [7:0] value;
        begin
            if (value > 66)      get_color_for_bar = GREEN;
            else if (value > 33) get_color_for_bar = YELLOW;
            else                 get_color_for_bar = RED;
        end
    endfunction

endmodule
