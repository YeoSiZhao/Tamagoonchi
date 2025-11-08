module PetStatsSystem(
    input  clk,
    input  feed_mode,
    input  game_mode,
    input  pulseL, pulseC, pulseR,
    input  exit_coin,
    input  exit_flappy,
    input  exit_connect4,
    input  [7:0] game_xp,
    input  [15:0] sw,
    input  [1:0] food_select,
    input  happiness_boost_pulse,
    input  [3:0] level,
    output reg [7:0] hunger,
    output reg [7:0] xp,
    output reg [7:0] happiness,
    output     [7:0] hunger_bar_length,
    output     [7:0] xp_bar_length,
    output     [7:0] happiness_bar_length,
    output reg dead,
    output reg xp_wrap_pulse,
    output reg pet_reset_pulse,
    output reg xp_add_done
);

    initial begin
        hunger           = 8'd100;
        xp               = 8'd0;
        happiness        = 8'd100;
        dead             = 1'b0;
        xp_wrap_pulse    = 1'b0;
        pet_reset_pulse  = 1'b0;
        xp_add_done      = 1'b0;
    end

    // 1 Hz tick
    reg [26:0] cnt = 0;
    reg tick = 0;
    always @(posedge clk) begin
        if (cnt >= 50_000_000) begin
            cnt  <= 0;
            tick <= ~tick;
        end else begin
            cnt <= cnt + 1;
        end
    end
    reg tick_d = 0;
    always @(posedge clk) tick_d <= tick;
    wire sec_pulse = tick & ~tick_d;

    // XP decay counter (every 5 seconds in idle)
    reg [2:0] xp_decay_counter = 0;
    
    // XP addition state machine
    localparam XP_IDLE = 2'b00;
    localparam XP_ADD  = 2'b01;
    localparam XP_DONE = 2'b10;

    reg [1:0] xp_state = XP_IDLE;
    reg [7:0] xp_to_add = 0;
    reg [26:0] xp_add_counter = 0;
    
    localparam XP_ADD_DELAY = 27'd2_000_000; // Faster animation

    // Game exit edge detection
    wire game_exited = exit_flappy || exit_coin || exit_connect4;
    reg game_exited_prev = 0;
    always @(posedge clk) game_exited_prev <= game_exited;
    wire game_exit_edge = game_exited & ~game_exited_prev;

    always @(posedge clk) begin
        xp_wrap_pulse   <= 1'b0;
        pet_reset_pulse <= 1'b0;
        xp_add_done     <= 1'b0;

        // Death check
        if (!dead && (hunger == 0 || happiness == 0))
            dead <= 1'b1;

        // Reset pet - ONLY when sw == 0 and dead
        if (dead && sw == 16'h0000 && pulseC) begin
            hunger          <= 8'd100;
            happiness       <= 8'd100;
            xp              <= 8'd0;
            dead            <= 1'b0;
            pet_reset_pulse <= 1'b1;
            xp_state        <= XP_IDLE;
            xp_to_add       <= 0;
            xp_decay_counter <= 0;
        end

        // XP state machine
        case (xp_state)
            XP_IDLE: begin
                // Disable XP updates if user is level 3
                if (level <= 3) begin
                    if (game_exit_edge && !dead) begin
                        // Apply hunger penalty for all games
                        if (hunger >= 10)
                            hunger <= hunger - 8'd10;
                        else
                            hunger <= 8'd0;
                        
                        // Only start XP addition if game_xp > 0
                        if (level < 3) begin
                            if (game_xp > 0) begin
                                xp_to_add       <= game_xp;
                                xp_state        <= XP_ADD;
                                xp_add_counter  <= 0;
                            end
                        end
                    end
                end
            end

            XP_ADD: begin
                if (level < 3) begin  // ? XP does not add if level 3
                    xp_add_counter <= xp_add_counter + 1;
                    
                    if (xp_add_counter >= XP_ADD_DELAY) begin
                        xp_add_counter <= 0;
                        
                        if (xp_to_add > 0) begin
                            if (xp < 8'd100) begin
                                xp        <= xp + 1'b1;
                                xp_to_add <= xp_to_add - 1'b1;
                            end else begin
                                xp            <= 8'd0;
                                xp_wrap_pulse <= 1'b1;
                                xp_to_add     <= xp_to_add - 1'b1;
                            end
                        end else begin
                            xp_state <= XP_DONE;
                        end
                    end
                end else begin
                    xp_state <= XP_IDLE;
                end
            end

            XP_DONE: begin
                xp_add_done <= 1'b1;
                xp_state    <= XP_IDLE;
            end

            default: xp_state <= XP_IDLE;
        endcase

        // Alive updates (only when not adding XP)
        if (!dead && xp_state == XP_IDLE) begin
            if (feed_mode && !game_mode && pulseC) begin
                case (food_select)
                    2'd1: hunger <= (hunger + 8'd10 <= 100) ? hunger + 8'd10 : 8'd100;
                    2'd2: hunger <= (hunger + 8'd25 <= 100) ? hunger + 8'd25 : 8'd100;
                    2'd3: hunger <= (hunger + 8'd40 <= 100) ? hunger + 8'd40 : 8'd100;
                    default: hunger <= hunger;
                endcase
            end

            if (happiness_boost_pulse && !game_mode) begin
                happiness <= (happiness + 8'd5 <= 100) ? happiness + 8'd5 : 8'd100;
            end

            if (!game_mode && sec_pulse && hunger > 0) begin
                hunger <= hunger - 8'd1;
            end

            if (!game_mode && sec_pulse && happiness > 0) begin
                happiness <= happiness - 8'd1;
            end

            if (level < 3) begin
                if (!game_mode && !feed_mode && sec_pulse) begin
                    if (xp_decay_counter >= 3'd4) begin  // 5 seconds passed
                        xp_decay_counter <= 0;
                        if (xp > 0)
                            xp <= xp - 1'b1;
                    end else begin
                        xp_decay_counter <= xp_decay_counter + 1'b1;
                    end
                end else if (game_mode || feed_mode) begin
                    xp_decay_counter <= 0;
                end
            end else begin
                xp <= 8'd100; // Keep XP full forever at level 3
            end
        end
    end

    wire [15:0] hunger_len_calc    = (hunger    * 16'd70) / 16'd100;
    wire [15:0] xp_len_calc        = (xp        * 16'd70) / 16'd100;
    wire [15:0] happiness_len_calc = (happiness * 16'd70) / 16'd100;

    assign hunger_bar_length    = dead ? 8'd70 : hunger_len_calc[7:0];
    assign xp_bar_length        = dead ? 8'd70 : xp_len_calc[7:0];
    assign happiness_bar_length = dead ? 8'd70 : happiness_len_calc[7:0];

endmodule