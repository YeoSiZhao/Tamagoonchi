`timescale 1ns / 1ps

module oled_renderer(
    input  wire        clk,
    input  wire        feed_mode,
    input  wire        dead,
    input  wire [6:0]  x,
    input  wire [6:0]  y,
    input  wire [7:0]  hunger,
    input  wire [7:0]  xp,
    input  wire [7:0]  happiness,
    input  wire [7:0]  hunger_bar_length,
    input  wire [7:0]  xp_bar_length,
    input  wire [7:0]  happiness_bar_length,
    input  wire        btnL_active,
    input  wire        btnC_active,
    input  wire        btnR_active,
    input  wire        game_mode,
    output reg  [15:0] oled_data,
    output wire [1:0]  food_select_out
);

    localparam BLACK    = 16'h0000;
    localparam WHITE    = 16'hFFFF;
    localparam RED      = 16'hF800;
    localparam GREEN    = 16'h07E0;
    localparam YELLOW   = 16'hFFE0;
    localparam CYAN     = 16'h07FF;
    localparam DARKBLUE = 16'h0110;
    localparam GRAY     = 16'h8410;
    localparam ORANGE   = 16'hFD20;
    localparam PURPLE   = 16'h780F;

    localparam DEEP_NAVY    = 16'h0008;
    localparam DARK_TEAL    = 16'h0210;
    localparam MID_TEAL     = 16'h0418;
    localparam PURPLE_BLUE  = 16'h300C;
    localparam DEEP_PURPLE  = 16'h5006;
    localparam PINK_ACCENT  = 16'h8808;

    wire [15:0] apple_pixel, burger_pixel, pizza_pixel;
    wire [15:0] left_arrow_pixel, right_arrow_pixel;

    apple_sprite  u_apple  (.x(x), .y(y), .pixel(apple_pixel));
    burger_sprite u_burger (.x(x), .y(y), .pixel(burger_pixel));
    pizza_sprite  u_pizza  (.x(x), .y(y), .pixel(pizza_pixel));
    left_arrow_sprite  u_left  (.x(x), .y(y), .pixel(left_arrow_pixel));
    right_arrow_sprite u_right (.x(x), .y(y), .pixel(right_arrow_pixel));

    wire [6:0] hunger_icon_x = (x >= 7'd2) ? (x - 7'd2) : 7'd0;
    wire [5:0] hunger_icon_y = (y >= 6'd2) ? (y - 6'd2) : 6'd0;
    wire [15:0] hunger_icon_pixel;
    
    wire [6:0] xp_icon_x = (x >= 7'd2) ? (x - 7'd2) : 7'd0;
    wire [5:0] xp_icon_y = (y >= 6'd22) ? (y - 6'd22) : 6'd0;
    wire [15:0] xp_icon_pixel;
    
    wire [6:0] happiness_icon_x = (x >= 7'd2) ? (x - 7'd2) : 7'd0;
    wire [5:0] happiness_icon_y = (y >= 6'd42) ? (y - 6'd42) : 6'd0;
    wire [15:0] happiness_icon_pixel;
    
    wire [6:0] feed_hunger_icon_x = (x >= 7'd2) ? (x - 7'd2) : 7'd0;
    wire [5:0] feed_hunger_icon_y = (y >= 6'd50) ? (y - 6'd50) : 6'd0;
    wire [15:0] feed_hunger_icon_pixel;

    hunger_icon u_hunger_icon (
        .x(hunger_icon_x),
        .y(hunger_icon_y),
        .pixel(hunger_icon_pixel)
    );

    xp_text u_xp_icon (
        .x(xp_icon_x),
        .y(xp_icon_y),
        .pixel(xp_icon_pixel)
    );

    happiness_icon u_happiness_icon (
        .x(happiness_icon_x),
        .y(happiness_icon_y),
        .pixel(happiness_icon_pixel)
    );
    
    hunger_icon u_feed_hunger (
        .x(feed_hunger_icon_x),
        .y(feed_hunger_icon_y),
        .pixel(feed_hunger_icon_pixel)
    );

    reg [1:0] food_select = 2'd2;
    reg btnR_prev = 0;
    reg btnL_prev = 0;

    always @(posedge clk) begin
        if (feed_mode) begin
            if (btnR_active && !btnR_prev && food_select < 3)
                food_select <= food_select + 1;
            else if (btnL_active && !btnL_prev && food_select > 1)
                food_select <= food_select - 1;
        end
        btnR_prev <= btnR_active;
        btnL_prev <= btnL_active;
    end

    assign food_select_out = food_select;

    function [15:0] get_background_color;
        input [6:0] x_pos, y_pos;
        reg [7:0] dx, dy, pattern;
        reg [14:0] dist_sq;
        begin
            dx = (x_pos > 48) ? (x_pos - 48) : (48 - x_pos);
            dy = (y_pos > 32) ? (y_pos - 32) : (32 - y_pos);
            dist_sq = (dx * dx) + (dy * dy);
            pattern = x_pos + y_pos;
            if (dist_sq < 200)
                get_background_color = (pattern[2:0] == 3'b000) ? MID_TEAL : DARK_TEAL;
            else if (dist_sq < 600)
                get_background_color = (pattern[2:0] == 3'b011 || pattern[2:0] == 3'b100)
                                         ? PURPLE_BLUE : DARK_TEAL;
            else if (dist_sq < 1200)
                get_background_color = (pattern[3:0] == 4'b0101 || pattern[3:0] == 4'b1010)
                                         ? DEEP_PURPLE : PURPLE_BLUE;
            else
                get_background_color = (pattern[2:0] == 3'b111) ? DEEP_PURPLE : DEEP_NAVY;
        end
    endfunction

    reg text_pixel;
    always @(*) begin
        text_pixel = 0;
        if (y >= 1 && y <= 7) begin

            // F (x: 19-23)
            case (y - 1)
                0: if (x >= 19 && x <= 23) text_pixel = 1;
                1: if (x == 19) text_pixel = 1;
                2: if (x == 19) text_pixel = 1;
                3: if (x >= 19 && x <= 22) text_pixel = 1;
                4,5,6: if (x == 19) text_pixel = 1;
            endcase

            // O (x: 25-29)
            case (y - 1)
                0: if (x >= 26 && x <= 28) text_pixel = 1;
                1,2,3,4,5: if (x == 25 || x == 29) text_pixel = 1;
                6: if (x >= 26 && x <= 28) text_pixel = 1;
            endcase

            // O (x: 31-35)
            case (y - 1)
                0: if (x >= 32 && x <= 34) text_pixel = 1;
                1,2,3,4,5: if (x == 31 || x == 35) text_pixel = 1;
                6: if (x >= 32 && x <= 34) text_pixel = 1;
            endcase

            // D (x: 37-41)
            case (y - 1)
                0: if (x >= 37 && x <= 40) text_pixel = 1;
                1,2,3,4,5: if (x == 37 || x == 41) text_pixel = 1;
                6: if (x >= 37 && x <= 40) text_pixel = 1;
            endcase

            // M (x: 45-51)
            case (y - 1)
                0: if (x == 45 || x == 51) text_pixel = 1;
                1: if (x == 45 || x == 46 || x == 50 || x == 51) text_pixel = 1;
                2: if (x == 45 || x == 47 || x == 49 || x == 51) text_pixel = 1;
                3: if (x == 45 || x == 48 || x == 51) text_pixel = 1;
                4,5,6: if (x == 45 || x == 51) text_pixel = 1;
            endcase

            // E (x: 53-57)
            case (y - 1)
                0,6: if (x >= 53 && x <= 57) text_pixel = 1;
                1,2,4,5: if (x == 53) text_pixel = 1;
                3: if (x >= 53 && x <= 56) text_pixel = 1;
            endcase

            // N (x: 59-63)
            case (y - 1)
                0,4,5,6: if (x == 59 || x == 63) text_pixel = 1;
                1: if (x == 59 || x == 60 || x == 63) text_pixel = 1;
                2: if (x == 59 || x == 61 || x == 63) text_pixel = 1;
                3: if (x == 59 || x == 62 || x == 63) text_pixel = 1;
            endcase

            // U (x: 65-69)
            case (y - 1)
                0,1,2,3,4,5: if (x == 65 || x == 69) text_pixel = 1;
                6: if (x >= 66 && x <= 68) text_pixel = 1;
            endcase
        end
    end

    always @(*) begin
        oled_data = BLACK;

        if (dead) begin
            draw_bar_fixed(8,  13, 8'd70, RED);
            draw_bar_fixed(28, 33, 8'd70, RED);
            draw_bar_fixed(48, 53, 8'd70, RED);
            
            if (y >= 2 && y <= 18 && x >= 2 && x <= 18) begin
                if (hunger_icon_pixel != BLACK)
                    oled_data = hunger_icon_pixel;
            end
            if (y >= 22 && y <= 38 && x >= 2 && x <= 18) begin
                if (xp_icon_pixel != BLACK)
                    oled_data = xp_icon_pixel;
            end
            if (y >= 42 && y <= 58 && x >= 2 && x <= 18) begin
                if (happiness_icon_pixel != BLACK)
                    oled_data = happiness_icon_pixel;
            end

        end else if (feed_mode) begin
            oled_data = get_background_color(x, y);
            if (text_pixel) oled_data = ORANGE;
            
            case (food_select)
                2'd1: begin
                    if (apple_pixel != BLACK)
                        oled_data = apple_pixel;
                    if (right_arrow_pixel != BLACK)
                        oled_data = right_arrow_pixel;
                end
                2'd2: begin
                    if (burger_pixel != BLACK)
                        oled_data = burger_pixel;
                    if (left_arrow_pixel  != BLACK)
                        oled_data = left_arrow_pixel;
                    if (right_arrow_pixel != BLACK)
                        oled_data = right_arrow_pixel;
                end
                2'd3: begin
                    if (pizza_pixel != BLACK)
                        oled_data = pizza_pixel;
                    if (left_arrow_pixel  != BLACK)
                        oled_data = left_arrow_pixel;
                end
            endcase

            draw_bar_dyn(56, 61, hunger_bar_length, hunger);
            
            if (y >= 50 && y <= 66 && x >= 2 && x <= 18) begin
                if (feed_hunger_icon_pixel != BLACK)
                    oled_data = feed_hunger_icon_pixel;
            end

        end else begin
            draw_bar_dyn  (8,  13, hunger_bar_length, hunger);
            draw_bar_fixed(28, 33, xp_bar_length, DARKBLUE);
            draw_bar_dyn  (48, 53, happiness_bar_length, happiness);  // FIXED: Changed to draw_bar_dyn
            
            if (y >= 2 && y <= 18 && x >= 2 && x <= 18) begin
                if (hunger_icon_pixel != BLACK)
                    oled_data = hunger_icon_pixel;
            end
            if (y >= 22 && y <= 38 && x >= 2 && x <= 18) begin
                if (xp_icon_pixel != BLACK)
                    oled_data = xp_icon_pixel;
            end
            if (y >= 42 && y <= 58 && x >= 2 && x <= 18) begin
                if (happiness_icon_pixel != BLACK)
                    oled_data = happiness_icon_pixel;
            end
        end
    end

    task draw_bar_dyn;
        input [6:0] y_top, y_bot;
        input [7:0] len;
        input [7:0] stat_value;
        reg [15:0] bar_color;
        reg [7:0] safe_len;
        begin
            // Clamp length to max 70 pixels
            safe_len = (len > 70) ? 70 : len;
            bar_color = get_color_for_bar(stat_value);
            
            if (y >= y_top && y <= y_bot) begin
                // LEFT PURPLE BORDER (x=21-22)
                if (x >= 21 && x <= 22)
                    oled_data = PURPLE;
                
                // FILLED BAR (x=23 to 23+len, max x=92)
                else if (x >= 23 && x < (23 + safe_len) && x <= 92)
                    oled_data = bar_color;
                
                // EMPTY BAR BACKGROUND (from end of filled bar to x=92)
                else if (x >= (23 + safe_len) && x <= 92)
                    oled_data = WHITE;
                
                // RIGHT EDGE (x=93)
                else if (x == 93)
                    oled_data = PURPLE;
            end
        end
    endtask

    task draw_bar_fixed;
        input [6:0] y_top, y_bot;
        input [7:0] len;
        input [15:0] color;
        reg [7:0] safe_len;
        begin
            // Clamp length to max 70 pixels
            safe_len = (len > 70) ? 70 : len;
            
            if (y >= y_top && y <= y_bot) begin
                // LEFT PURPLE BORDER (x=21-22)
                if (x >= 21 && x <= 22)
                    oled_data = PURPLE;
                
                // FILLED BAR (x=23 to 23+len, max x=92)
                else if (x >= 23 && x < (23 + safe_len) && x <= 92)
                    oled_data = color;
                
                // EMPTY BAR BACKGROUND (from end of filled bar to x=92)
                else if (x >= (23 + safe_len) && x <= 92)
                    oled_data = WHITE;
                
                // RIGHT EDGE (x=93)
                else if (x == 93)
                    oled_data = PURPLE;
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