`timescale 1ns / 1ps

module PetStatsSystem(
    input  clk,
    input  feed_mode,          // RAW switches (from top)
    input  play_mode,
    input  paint_mode,
    input  pulseL, pulseC, pulseR,
    output reg [7:0] hunger,   // 0-100
    output reg [7:0] xp,       // 0-100 (loops to 0)
    output reg [7:0] happiness,// 0-100
    output     [7:0] hunger_bar_length,    // 0-90
    output     [7:0] xp_bar_length,        // 0-90
    output     [7:0] happiness_bar_length, // 0-90
    output reg dead
);

    // ---------------- INIT ----------------
    initial begin
        hunger    = 8'd100;
        xp        = 8'd0;
        happiness = 8'd100;
        dead      = 1'b0;
    end

    // ---------------- 1 Hz TICK ----------------
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
    wire sec_pulse = tick & ~tick_d; // 1 pulse per second

    // ---------------- MODES ----------------
    localparam MODE_IDLE  = 2'b00;
    localparam MODE_FEED  = 2'b01;
    localparam MODE_PLAY  = 2'b10;
    localparam MODE_PAINT = 2'b11;

    // RAW from switches:
    reg [1:0] raw_mode;
    always @(*) begin
        if      (feed_mode)  raw_mode = MODE_FEED;
        else if (play_mode)  raw_mode = MODE_PLAY;
        else if (paint_mode) raw_mode = MODE_PAINT;
        else                 raw_mode = MODE_IDLE;
    end
    wire raw_idle = (raw_mode == MODE_IDLE);

    // EFFECTIVE mode (lock to idle when dead):
    reg [1:0] eff_mode;
    always @(*) begin
        eff_mode = dead ? MODE_IDLE : raw_mode;
    end

    // Track previous RAW mode for clean exit penalty:
    reg [1:0] prev_raw_mode = MODE_IDLE;

    // ---------------- MAIN LOGIC ----------------
    always @(posedge clk) begin
        // X-protection
        if (hunger    === 8'bX) hunger    <= 8'd100;
        if (xp        === 8'bX) xp        <= 8'd0;
        if (happiness === 8'bX) happiness <= 8'd100;

        // Death detect
        if (!dead && (hunger == 0 || happiness == 0))
            dead <= 1'b1;

        // Strict reset: must be dead + raw idle + Center press
        if (dead && raw_idle && pulseC) begin
            hunger    <= 8'd100;
            happiness <= 8'd100;
            xp        <= 8'd0;
            dead      <= 1'b0;
        end

        // Alive-only updates
        if (!dead) begin
            // FEED
            if (eff_mode == MODE_FEED) begin
                if (pulseL)
                    hunger <= (hunger + 8'd12 <= 100) ? hunger + 8'd12 : 8'd100;
                else if (pulseC)
                    hunger <= (hunger + 8'd22 <= 100) ? hunger + 8'd22 : 8'd100;
                else if (pulseR)
                    hunger <= (hunger + 8'd32 <= 100) ? hunger + 8'd32 : 8'd100;
                else if (sec_pulse) begin
                    hunger     <= (hunger > 0)    ? hunger - 8'd1 : 8'd0;
                    happiness  <= (happiness > 0) ? happiness - 8'd1 : 8'd0;
                end
            end
            // PLAY (xp over time; hunger frozen; small happiness up)
            else if (eff_mode == MODE_PLAY && sec_pulse) begin
                xp        <= (xp < 8'd100) ? xp + 8'd2 : 8'd0; // loop at 100
                happiness <= (happiness < 8'd100) ? happiness + 8'd1 : 8'd100;
            end
            // PAINT (hunger frozen; happiness refill)
            else if (eff_mode == MODE_PAINT && sec_pulse) begin
                happiness <= (happiness < 8'd100) ? happiness + 8'd3 : 8'd100;
            end
            // IDLE (natural decay)
            else if (sec_pulse) begin
                hunger     <= (hunger > 0)    ? hunger - 8'd1 : 8'd0;
                happiness  <= (happiness > 0) ? happiness - 8'd1 : 8'd0;
            end

            // Exit penalty: only on real RAW transition PLAY/PAINT -> IDLE
            if ((prev_raw_mode == MODE_PLAY || prev_raw_mode == MODE_PAINT) &&
                 raw_mode == MODE_IDLE) begin
                hunger <= (hunger > 8'd10) ? hunger - 8'd10 : 8'd0;
            end
        end

        // update previous RAW mode every cycle
        prev_raw_mode <= raw_mode;
    end

    // ---------------- BAR LENGTHS (FIXED WIDTH MATH) ----------------
    // Use 16-bit intermediates to avoid overflow in (value * 90) / 100
    wire [15:0] hunger_len_calc    = (hunger    * 16'd90) / 16'd100;
    wire [15:0] xp_len_calc        = (xp        * 16'd90) / 16'd100;
    wire [15:0] happiness_len_calc = (happiness * 16'd90) / 16'd100;

    assign hunger_bar_length    = dead ? 8'd90 : hunger_len_calc[7:0];
    assign xp_bar_length        = dead ? 8'd90 : xp_len_calc[7:0];
    assign happiness_bar_length = dead ? 8'd90 : happiness_len_calc[7:0];

endmodule
