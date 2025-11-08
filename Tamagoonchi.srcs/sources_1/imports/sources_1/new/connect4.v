module connect4(
    input  wire       clk,
    input  wire       pulseL,
    input  wire       pulseR,
    input  wire       pulseC,
    input  wire [6:0] x,
    input  wire [5:0] y,
    input reset,
    output reg  [15:0] oled_data,
    output reg         current_player,
    output reg [7:0] exp
);
    localparam BLACK      = 16'h0000;
    localparam RED        = 16'hF800;
    localparam YELLOW     = 16'hFFE0;
    localparam BLUE_DARK  = 16'h0010;
    localparam GRAY       = 16'h8410;
    localparam COLS = 7;
    localparam ROWS = 6;

    localparam [2:0] IDLE        = 0,
                     PLAYER_TURN = 1,
                     DROP        = 2,
                     CHECK_WIN   = 3,
                     GAME_OVER   = 4;

    reg [2:0] state = IDLE;
    reg [1:0] board [0:COLS-1][0:ROWS-1];
    reg [2:0] selected_col = 3'd3;
    reg [2:0] drop_row;
    reg player = 1'b0;
    reg winner = 0;
    reg winning_player = 0;
    reg [5:0] move_count = 0;

    // Button edge detection
    reg pulseL_prev = 0, pulseR_prev = 0, pulseC_prev = 0;
    wire btnL_edge, btnR_edge, btnC_edge;
    
    always @(posedge clk) begin
        pulseL_prev <= pulseL;
        pulseR_prev <= pulseR;
        pulseC_prev <= pulseC;
    end
    
    assign btnL_edge = pulseL & ~pulseL_prev;
    assign btnR_edge = pulseR & ~pulseR_prev;
    assign btnC_edge = pulseC & ~pulseC_prev;

    function check_win;
        input dummy;
        integer cx, cy;
        begin
            check_win = 0;
            for (cx = 0; cx < COLS; cx = cx + 1)
                for (cy = 0; cy < ROWS; cy = cy + 1)
                    if (board[cx][cy] != 0) begin
                        if (cx <= COLS-4)
                            if (board[cx][cy]==board[cx+1][cy] &&
                                board[cx][cy]==board[cx+2][cy] &&
                                board[cx][cy]==board[cx+3][cy])
                                check_win = 1;
                        if (cy >= 3)
                            if (board[cx][cy]==board[cx][cy-1] &&
                                board[cx][cy]==board[cx][cy-2] &&
                                board[cx][cy]==board[cx][cy-3])
                                check_win = 1;
                        if (cx <= COLS-4 && cy >= 3)
                            if (board[cx][cy]==board[cx+1][cy-1] &&
                                board[cx][cy]==board[cx+2][cy-2] &&
                                board[cx][cy]==board[cx+3][cy-3])
                                check_win = 1;
                        if (cx <= COLS-4 && cy <= ROWS-4)
                            if (board[cx][cy]==board[cx+1][cy+1] &&
                                board[cx][cy]==board[cx+2][cy+2] &&
                                board[cx][cy]==board[cx+3][cy+3])
                                check_win = 1;
                    end
        end
    endfunction

    wire [15:0] sprite_win_pixel;
    wire [15:0] sprite_lose_pixel;

    win_sprite  w_sprite (.x(x), .y(y), .pixel(sprite_win_pixel));
    lose_sprite d_sprite (.x(x), .y(y), .pixel(sprite_lose_pixel));

    integer c, r;
    reg column_full;

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            exp <= 0;
            winner <= 0;
            move_count <= 0;
            player <= 0;
            selected_col <= 3;
            for (c = 0; c < COLS; c = c + 1)
                for (r = 0; r < ROWS; r = r + 1)
                    board[c][r] <= 0;
        end 
        else begin
            case (state)
                IDLE: begin
                    exp <= 0;
                    if (btnC_edge) begin
                        for (c = 0; c < COLS; c = c + 1)
                            for (r = 0; r < ROWS; r = r + 1)
                                board[c][r] <= 0;
                        selected_col <= 3;
                        player <= 0;
                        winner <= 0;
                        winning_player <= 0;
                        move_count <= 0;
                        state <= PLAYER_TURN;
                    end
                end

                PLAYER_TURN: begin
                    if (btnL_edge && selected_col > 0)
                        selected_col <= selected_col - 1;
                    if (btnR_edge && selected_col < COLS-1)
                        selected_col <= selected_col + 1;
        
                    if (btnC_edge) begin
                        column_full = (board[selected_col][ROWS-1] != 0);
                        if (!column_full) begin
                            // Find the lowest empty row (start from bottom row 0)
                            drop_row = 0;
                            for (r = ROWS-1; r >= 0; r = r - 1) begin
                                if (board[selected_col][r] == 0)
                                    drop_row = r;
                            end
                            state <= DROP;
                        end
                    end
                end

                DROP: begin
                    board[selected_col][drop_row] <= player ? 2'd2 : 2'd1;
                    move_count <= move_count + 1;
                    state <= CHECK_WIN;
                end

                CHECK_WIN: begin
                    if (check_win(1'b0)) begin
                        winner <= 1;
                        winning_player <= player;
                        state <= GAME_OVER;
                    end else if (move_count >= 42)
                        state <= GAME_OVER;
                    else begin
                        player <= ~player;
                        state <= PLAYER_TURN;
                    end
                end

                GAME_OVER: begin
                    if (winner) begin
                        exp <= (winning_player == 0) ? 8'd40 : 8'd10;
                    end else begin
                        exp <= 8'd10;
                    end
                    
                    if (btnC_edge)
                        state <= IDLE;
                end
            endcase
        end
    end   

    integer gx, gy, px, py, dx, dy, cx, cy;
    reg in_circle;

    always @(*) begin
        oled_data = BLUE_DARK;

        if (state != GAME_OVER) begin
            for (gx = 0; gx < COLS; gx = gx + 1)
                for (gy = 0; gy < ROWS; gy = gy + 1) begin
                    px = 8 + gx * 12;
                    py = 8 + (ROWS-1-gy) * 9;
                    if ((x >= px && x < px+10) && (y >= py && y < py+8)) begin
                        dx = x - (px + 5);
                        dy = y - (py + 4);
                        in_circle = (dx*dx + dy*dy < 20);
                        if (in_circle) begin
                            case (board[gx][gy])
                                2'd1: oled_data = RED;
                                2'd2: oled_data = YELLOW;
                                default: oled_data = BLACK;
                            endcase
                        end
                    end
                end
            if (state == PLAYER_TURN) begin
                cx = 13 + selected_col * 12;
                cy = 3;
                dx = x - cx;
                dy = y - cy;
                if (dx*dx + dy*dy < 20)
                    oled_data = player ? YELLOW : RED;
            end
        end
        else begin
            if (winner) begin
                if (winning_player == 0)
                    oled_data = (sprite_win_pixel != BLACK) ? sprite_win_pixel : BLUE_DARK;
                else
                    oled_data = (sprite_lose_pixel != BLACK) ? sprite_lose_pixel : BLUE_DARK;
            end else begin
                oled_data = (sprite_lose_pixel != BLACK) ? sprite_lose_pixel : BLUE_DARK;
            end
        end
    end

    always @(posedge clk)
        current_player <= player;

endmodule