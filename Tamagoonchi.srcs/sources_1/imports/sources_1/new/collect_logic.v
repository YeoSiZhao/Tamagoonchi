`timescale 1ns / 1ps
module collect_logic(
    input  clk100,
    input  enable,                   // run only when 1 (PLAY mode)
    input  dead,                     // disable game when pet dies - ADDED
    input  btnU, btnD, btnL, btnR, btnC,
    output reg [6:0] player_x = 15,
    output reg [5:0] player_y = 25,
    output reg [6:0] coin_x   = 55,
    output reg [5:0] coin_y   = 25,
    output reg [7:0] score    = 0,  
    output reg [6:0] time_s   = 15, 
    output reg       game_over = 1'b0
);

    localparam W=96, H=64, P_SIZE=10, C_SIZE=6, STEP=2;
    localparam PX_MAX=W-P_SIZE, PY_MAX=H-P_SIZE, CX_MAX=W-C_SIZE, CY_MAX=H-C_SIZE;

    reg [21:0] div = 0;
    wire tick = (div == 0);
    always @(posedge clk100)
        div <= div + 1;

    reg [26:0] secdiv = 0;
    wire sec_tick = (secdiv == 0);
    always @(posedge clk100)
        secdiv <= secdiv + 1;

    reg [15:0] lfsr = 16'hACE1;
    always @(posedge clk100)
        lfsr <= {lfsr[14:0], lfsr[15]^lfsr[13]^lfsr[12]^lfsr[10]};

    reg [7:0] rand_x_reg;
    reg [7:0] rand_y_reg;
    
    always @(posedge clk100) begin
        rand_x_reg <= lfsr[7:0] ^ lfsr[15:8];
        rand_y_reg <= {1'b0, lfsr[6:0]} ^ {1'b0, lfsr[14:8]};
    end

    function automatic [6:0] clamp7;
        input integer v, lo, hi;
        begin
            if (v < lo)      clamp7 = lo[6:0];
            else if (v > hi) clamp7 = hi[6:0];
            else             clamp7 = v[6:0];
        end
    endfunction

    function automatic [5:0] clamp6;
        input integer v, lo, hi;
        begin
            if (v < lo)      clamp6 = lo[5:0];
            else if (v > hi) clamp6 = hi[5:0];
            else             clamp6 = v[5:0];
        end
    endfunction

    function automatic [6:0] snap_x;
        input [7:0] val;
        reg [6:0] temp;
        begin
            temp = (val > CX_MAX) ? val[6:0] % (CX_MAX + 1) : val[6:0];
            snap_x = (temp / STEP) * STEP;
        end
    endfunction
    
    function automatic [5:0] snap_y;
        input [7:0] val;
        reg [5:0] temp;
        begin
            temp = (val > CY_MAX) ? val[5:0] % (CY_MAX + 1) : val[5:0];
            snap_y = (temp / STEP) * STEP;
        end
    endfunction

    localparam [1:0] DIR_UP = 2'd0, DIR_DOWN = 2'd1, DIR_LEFT = 2'd2, DIR_RIGHT = 2'd3;
    reg [1:0] dir = DIR_RIGHT;

    wire hit_x = (coin_x + C_SIZE >= player_x) && (coin_x <= player_x + P_SIZE);
    wire hit_y = (coin_y + C_SIZE >= player_y) && (coin_y <= player_y + P_SIZE);
    wire caught = hit_x & hit_y;

    reg started = 0;

    always @(posedge clk100) begin
        if (btnC) begin
            player_x <= 15;
            player_y <= 25;
            coin_x   <= 55;
            coin_y   <= 25;
            score    <= 0;
            time_s   <= 15;
            game_over<= 1'b0;
            started  <= 1'b0;
            dir      <= DIR_RIGHT;
        end

        else if (enable && !dead) begin
            if (!started && (btnU | btnD | btnL | btnR)) begin
                started <= 1'b1;
                if (btnU) dir <= DIR_UP;
                else if (btnD) dir <= DIR_DOWN;
                else if (btnL) dir <= DIR_LEFT;
                else if (btnR) dir <= DIR_RIGHT;
            end
            else if (started && !game_over) begin
                if (btnU) dir <= DIR_UP;
                else if (btnD) dir <= DIR_DOWN;
                else if (btnL) dir <= DIR_LEFT;
                else if (btnR) dir <= DIR_RIGHT;
            end

            // movement tick
            if (tick && started && !game_over) begin
                case (dir)
                    DIR_UP:    player_y <= clamp6(player_y - STEP, 0, PY_MAX);
                    DIR_DOWN:  player_y <= clamp6(player_y + STEP, 0, PY_MAX);
                    DIR_LEFT:  player_x <= clamp7(player_x - STEP, 0, PX_MAX);
                    DIR_RIGHT: player_x <= clamp7(player_x + STEP, 0, PX_MAX);
                endcase
            end

            // boundary hit
            if (started && (player_x <= 0 || player_x >= PX_MAX ||
                            player_y <= 0 || player_y >= PY_MAX))
                game_over <= 1'b1;

            if (tick && started && !game_over && caught) begin
                score  <= score + 1;

                coin_x <= clamp7(snap_x(rand_x_reg), 0, CX_MAX);
                coin_y <= clamp6(snap_y(rand_y_reg), 0, CY_MAX);
            end

            if (started && time_s != 0 && sec_tick && !game_over) begin
                time_s <= time_s - 1;
                if (time_s <= 1)
                    game_over <= 1'b1;
            end
        end

        else if (!enable || dead) begin
            started <= 1'b0;
        end
    end
endmodule