`timescale 1ns / 1ps

module game_menu(
    input  wire [6:0] x,        
    input  wire [5:0] y,        
    output reg  [15:0] pixel   
);

    localparam BLACK       = 16'h0000;
    localparam WHITE       = 16'hFFFF;
    localparam CYAN        = 16'h07FF;
    localparam BLUE        = 16'h001F;
    localparam DARK_BLUE   = 16'h0010;
    localparam GREEN       = 16'h07E0;
    localparam YELLOW      = 16'hFFE0;
    localparam RED         = 16'hF800;
    localparam ORANGE      = 16'hFD20;
    localparam PURPLE      = 16'hF81F;
    localparam GRAY        = 16'h8410;
    localparam LIGHT_GRAY  = 16'hC618;

    localparam TITLE_Y_START = 2;
    localparam TITLE_Y_END   = 9;

    localparam ICON_Y_START = 18;
    localparam ICON_HEIGHT  = 24;
    localparam ICON_WIDTH   = 20;

    localparam ICON1_X = 6;   // Connect 4
    localparam ICON2_X = 38;  // Flappy Bird  
    localparam ICON3_X = 70;  // Snake
    
    // Label area: rows 46-58
    localparam LABEL_Y_START = 46;

    wire in_border = (x == 0 || x == 95 || y == 0 || y == 63);
    wire in_title_area = (y >= TITLE_Y_START && y <= TITLE_Y_END);
    wire title_underline = (y == TITLE_Y_END + 1);

    wire in_title_text;
    wire [15:0] title_color;
    
    render_title_text title_renderer(
        .x(x), 
        .y(y),
        .in_text(in_title_text),
        .text_color(title_color)
    );

    // Icon 1: "4" for Connect 4
    wire in_icon1 = (x >= ICON1_X && x < ICON1_X + ICON_WIDTH &&
                     y >= ICON_Y_START && y < ICON_Y_START + ICON_HEIGHT);
    wire [6:0] x_icon1 = x - ICON1_X;
    wire [5:0] y_icon1 = y - ICON_Y_START;
    wire [15:0] pix_icon1;
    
    render_number_4 icon4(
        .x(x_icon1),
        .y(y_icon1),
        .pixel(pix_icon1)
    );
    
    // Icon 2: Flappy Bird
    wire in_icon2 = (x >= ICON2_X && x < ICON2_X + ICON_WIDTH &&
                     y >= ICON_Y_START && y < ICON_Y_START + ICON_HEIGHT);
    wire [6:0] x_icon2 = x - ICON2_X;
    wire [5:0] y_icon2 = y - ICON_Y_START;
    wire [15:0] pix_icon2;
    
    render_flappy_bird icon_flappy(
        .x(x_icon2),
        .y(y_icon2),
        .pixel(pix_icon2)
    );
    
    // Icon 3: Snake
    wire in_icon3 = (x >= ICON3_X && x < ICON3_X + ICON_WIDTH &&
                     y >= ICON_Y_START && y < ICON_Y_START + ICON_HEIGHT);
    wire [6:0] x_icon3 = x - ICON3_X;
    wire [5:0] y_icon3 = y - ICON_Y_START;
    wire [15:0] pix_icon3;
    
    render_snake icon_snake(
        .x(x_icon3),
        .y(y_icon3),
        .pixel(pix_icon3)
    );

    wire in_label1, in_label2, in_label3;
    wire [15:0] label1_color, label2_color, label3_color;
    
    // SW15
    render_sw15_label label1(
        .x(x),
        .y(y),
        .in_label(in_label1),
        .label_color(label1_color)
    );
    
    // SW14
    render_sw14_label label2(
        .x(x),
        .y(y),
        .in_label(in_label2),
        .label_color(label2_color)
    );
    
    // SW13
    render_sw13_label label3(
        .x(x),
        .y(y),
        .in_label(in_label3),
        .label_color(label3_color)
    );

    always @(*) begin
//        // Default: gradient background
        if (y < 13)
            pixel = DARK_BLUE;
        else
            pixel = BLACK;
       
        
        // Title text
        if (in_title_text)
            pixel = title_color;
        
        // Icon frames (subtle boxes)
        if (in_icon1 && (x_icon1 == 0 || x_icon1 == ICON_WIDTH-1 || 
                         y_icon1 == 0 || y_icon1 == ICON_HEIGHT-1))
            pixel = GRAY;
        if (in_icon2 && (x_icon2 == 0 || x_icon2 == ICON_WIDTH-1 || 
                         y_icon2 == 0 || y_icon2 == ICON_HEIGHT-1))
            pixel = GRAY;
        if (in_icon3 && (x_icon3 == 0 || x_icon3 == ICON_WIDTH-1 || 
                         y_icon3 == 0 || y_icon3 == ICON_HEIGHT-1))
            pixel = GRAY;
        
        // Game icons
        if (in_icon1 && pix_icon1 != BLACK)
            pixel = pix_icon1;
        if (in_icon2 && pix_icon2 != BLACK)
            pixel = pix_icon2;
        if (in_icon3 && pix_icon3 != BLACK)
            pixel = pix_icon3;
        
        // Switch labels
        if (in_label1)
            pixel = label1_color;
        if (in_label2)
            pixel = label2_color;
        if (in_label3)
            pixel = label3_color;
        
        // Border frame
//        if (in_border)
//            pixel = CYAN;
    end

endmodule

module render_title_text(
    input  wire [6:0] x,
    input  wire [5:0] y,
    output reg  in_text,
    output reg  [15:0] text_color
);
    localparam WHITE = 16'hFFFF;
    localparam YELLOW = 16'hFFE0;
    localparam BLACK = 16'h0000;
    
    always @(*) begin
        in_text = 0;
        text_color = WHITE;
        
        // "GAME MENU" centered at top (rows 3-8)
        if (y >= 3 && y <= 8) begin
            // G - column 20-24
            if (x >= 20 && x <= 24) begin
                if ((y == 3 || y == 8) || 
                    (x == 20) ||
                    (y >= 6 && x >= 22)) begin
                    in_text = 1;
                    text_color = YELLOW;
                end
            end
            // A - column 26-30
            else if (x >= 26 && x <= 30) begin
                if ((y == 3 && x >= 27) || 
                    (x == 26 && y >= 4) || 
                    (x == 30 && y >= 4) ||
                    (y == 5)) begin
                    in_text = 1;
                    text_color = YELLOW;
                end
            end
            // M - column 32-38
            else if (x >= 32 && x <= 38) begin
                if ((x == 32) || (x == 38) ||
                    (y == 3 && x >= 33 && x <= 37) ||
                    (y == 4 && x == 35)) begin
                    in_text = 1;
                    text_color = YELLOW;
                end
            end
            // E - column 40-44
            else if (x >= 40 && x <= 44) begin
                if ((x == 40) || (y == 3) || (y == 5) || (y == 8)) begin
                    in_text = 1;
                    text_color = YELLOW;
                end
            end
            
            // M - column 48-54
            else if (x >= 48 && x <= 54) begin
                if ((x == 48) || (x == 54) ||
                    (y == 3 && x >= 49 && x <= 53) ||
                    (y == 4 && x == 51)) begin
                    in_text = 1;
                    text_color = WHITE;
                end
            end
            // E - column 56-60
            else if (x >= 56 && x <= 60) begin
                if ((x == 56) || (y == 3) || (y == 5) || (y == 8)) begin
                    in_text = 1;
                    text_color = WHITE;
                end
            end
            // N - column 62-66
            else if (x >= 62 && x <= 66) begin
                if ((x == 62) || (x == 66) ||
                    (y == 4 && x == 63) ||
                    (y == 5 && x == 64) ||
                    (y == 6 && x == 65)) begin
                    in_text = 1;
                    text_color = WHITE;
                end
            end
            // U - column 68-72
            else if (x >= 68 && x <= 72) begin
                if ((x == 68 && y < 8) || 
                    (x == 72 && y < 8) ||
                    (y == 8 && x >= 69)) begin
                    in_text = 1;
                    text_color = WHITE;
                end
            end
        end
    end
endmodule

module render_number_4(
    input  wire [6:0] x,
    input  wire [5:0] y,
    output reg  [15:0] pixel
);
    localparam RED = 16'hF800;
    localparam YELLOW = 16'hFFE0;
    localparam BLACK = 16'h0000;
    
    always @(*) begin
        pixel = BLACK;
        
        // Draw thicker "4" (using Connect 4 colors)
        if (x >= 5 && x <= 15 && y >= 4 && y <= 20) begin
            // Vertical left stroke (thicker - 2 pixels wide)
            if ((x == 6 || x == 7) && y >= 4 && y <= 12)
                pixel = RED;
            // Horizontal middle stroke (thicker - 2 pixels tall)
            else if ((y == 11 || y == 12) && x >= 6 && x <= 13)
                pixel = RED;
            // Vertical right stroke (thicker - 2 pixels wide)
            else if ((x == 12 || x == 13) && y >= 4 && y <= 20)
                pixel = RED;
        end
    end
endmodule

module render_flappy_bird(
    input  wire [6:0] x,
    input  wire [5:0] y,
    output reg  [15:0] pixel
);
    localparam YELLOW = 16'hFFE0;
    localparam ORANGE = 16'hFD20;
    localparam WHITE = 16'hFFFF;
    localparam BLACK = 16'h0000;
    
    always @(*) begin
        pixel = BLACK;
        
        // Simple bird shape (centered)
        if (x >= 5 && x <= 14 && y >= 8 && y <= 15) begin
            // Bird body (yellow circle-ish)
            if (((x >= 7 && x <= 12) && (y >= 9 && y <= 14)) ||
                ((x >= 6 && x <= 13) && (y >= 10 && y <= 13)))
                pixel = YELLOW;
            
            // Wing
            if (x >= 5 && x <= 8 && y >= 11 && y <= 13)
                pixel = ORANGE;
            
            // Eye
            if (x == 10 && y == 11)
                pixel = BLACK;
            else if ((x == 9 || x == 11) && y == 11)
                pixel = WHITE;
            
            // Beak
            if (x >= 13 && x <= 14 && y >= 11 && y <= 12)
                pixel = ORANGE;
        end
    end
endmodule

module render_snake(
    input  wire [6:0] x,
    input  wire [5:0] y,
    output reg  [15:0] pixel
);
    localparam GREEN = 16'h07E0;
    localparam DARK_GREEN = 16'h0340;
    localparam BLACK = 16'h0000;
    localparam RED = 16'hF800;
    
    always @(*) begin
        pixel = BLACK;
        
        // S-shaped snake
        if (x >= 5 && x <= 15 && y >= 6 && y <= 18) begin
            // Head (top)
            if (x >= 7 && x <= 10 && y >= 6 && y <= 8)
                pixel = GREEN;
            
            // Eyes
            if ((x == 8 || x == 10) && y == 7)
                pixel = BLACK;
            
            // Tongue
            if (x == 11 && (y == 7 || y == 8))
                pixel = RED;
            
            // Body segments (S-curve)
            // Upper segment
            if (x >= 7 && x <= 10 && y >= 9 && y <= 11)
                pixel = DARK_GREEN;
            
            // Middle segment
            if (x >= 9 && x <= 12 && y >= 12 && y <= 14)
                pixel = GREEN;
            
            // Lower segment
            if (x >= 7 && x <= 10 && y >= 15 && y <= 17)
                pixel = DARK_GREEN;
            
            // Tail
            if (x >= 7 && x <= 8 && y == 18)
                pixel = GREEN;
        end
    end
endmodule

module render_sw15_label(
    input  wire [6:0] x,
    input  wire [5:0] y,
    output reg  in_label,
    output reg  [15:0] label_color
);
    localparam WHITE = 16'hFFFF;
    localparam RED = 16'hF800;
    localparam BLACK = 16'h0000;
    
    always @(*) begin
        in_label = 0;
        label_color = WHITE;

        if (y >= 48 && y <= 58) begin
            // S 
            if (x >= 2 && x <= 6) begin
                if ((y == 48 || y == 49) || (y == 53 || y == 54) || (y == 57 || y == 58) ||
                    ((x == 2 || x == 3) && y >= 48 && y <= 54) ||
                    ((x == 5 || x == 6) && y >= 53 && y <= 58))
                    in_label = 1;
            end
            // W 
            else if (x >= 8 && x <= 15) begin
                if (((x == 8 || x == 9) && y >= 48) || 
                    ((x == 14 || x == 15) && y >= 48) ||
                    ((y == 57 || y == 58) && x >= 9 && x <= 14) ||
                    ((y == 55 || y == 56) && (x == 10 || x == 11 || x == 12 || x == 13)))
                    in_label = 1;
            end
            // 1 
            else if (x >= 17 && x <= 20) begin
                if (((x == 18 || x == 19) && y >= 48) || 
                    ((y == 57 || y == 58) && x >= 17 && x <= 20)) begin
                    in_label = 1;
                    label_color = RED;
                end
            end
            // 5 
            else if (x >= 22 && x <= 26) begin
                if ((y == 48 || y == 49) || (y == 53 || y == 54) || (y == 57 || y == 58) ||
                    ((x == 22 || x == 23) && y >= 48 && y <= 54) ||
                    ((x == 25 || x == 26) && y >= 53 && y <= 58)) begin
                    in_label = 1;
                    label_color = RED;
                end
            end
        end
    end
endmodule

module render_sw14_label(
    input  wire [6:0] x,
    input  wire [5:0] y,
    output reg  in_label,
    output reg  [15:0] label_color
);
    localparam WHITE = 16'hFFFF;
    localparam YELLOW = 16'hFFE0;
    localparam BLACK = 16'h0000;
    
    always @(*) begin
        in_label = 0;
        label_color = WHITE;

        if (y >= 48 && y <= 58) begin
            // S 
            if (x >= 34 && x <= 38) begin
                if ((y == 48 || y == 49) || (y == 53 || y == 54) || (y == 57 || y == 58) ||
                    ((x == 34 || x == 35) && y >= 48 && y <= 54) ||
                    ((x == 37 || x == 38) && y >= 53 && y <= 58))
                    in_label = 1;
            end
            // W 
            else if (x >= 40 && x <= 47) begin
                if (((x == 40 || x == 41) && y >= 48) || 
                    ((x == 46 || x == 47) && y >= 48) ||
                    ((y == 57 || y == 58) && x >= 41 && x <= 46) ||
                    ((y == 55 || y == 56) && (x == 42 || x == 43 || x == 44 || x == 45)))
                    in_label = 1;
            end
            // 1 
            else if (x >= 49 && x <= 52) begin
                if (((x == 50 || x == 51) && y >= 48) || 
                    ((y == 57 || y == 58) && x >= 49 && x <= 52)) begin
                    in_label = 1;
                    label_color = YELLOW;
                end
            end
            // 4 
            else if (x >= 54 && x <= 59) begin
                if (((x == 54 || x == 55) && y >= 48 && y <= 54) ||
                    ((y == 53 || y == 54) && x >= 54 && x <= 59) ||
                    ((x == 57 || x == 58) && y >= 48)) begin
                    in_label = 1;
                    label_color = YELLOW;
                end
            end
        end
    end
endmodule

module render_sw13_label(
    input  wire [6:0] x,
    input  wire [5:0] y,
    output reg  in_label,
    output reg  [15:0] label_color
);
    localparam WHITE = 16'hFFFF;
    localparam GREEN = 16'h07E0;
    localparam BLACK = 16'h0000;
    
    always @(*) begin
        in_label = 0;
        label_color = WHITE;
        
        if (y >= 48 && y <= 58) begin
            // S 
            if (x >= 66 && x <= 70) begin
                if ((y == 48 || y == 49) || (y == 53 || y == 54) || (y == 57 || y == 58) ||
                    ((x == 66 || x == 67) && y >= 48 && y <= 54) ||
                    ((x == 69 || x == 70) && y >= 53 && y <= 58))
                    in_label = 1;
            end
            // W 
            else if (x >= 72 && x <= 79) begin
                if (((x == 72 || x == 73) && y >= 48) || 
                    ((x == 78 || x == 79) && y >= 48) ||
                    ((y == 57 || y == 58) && x >= 73 && x <= 78) ||
                    ((y == 55 || y == 56) && (x == 74 || x == 75 || x == 76 || x == 77)))
                    in_label = 1;
            end
            // 1 
            else if (x >= 81 && x <= 84) begin
                if (((x == 82 || x == 83) && y >= 48) || 
                    ((y == 57 || y == 58) && x >= 81 && x <= 84)) begin
                    in_label = 1;
                    label_color = GREEN;
                end
            end
            // 3 
            else if (x >= 86 && x <= 90) begin
                if ((y == 48 || y == 49) || (y == 53 || y == 54) || (y == 57 || y == 58) ||
                    ((x == 89 || x == 90) && y >= 48 && y <= 58)) begin
                    in_label = 1;
                    label_color = GREEN;
                end
            end
        end
    end
endmodule