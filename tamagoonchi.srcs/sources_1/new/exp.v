`timescale 1ns / 1ps

module exp_controller #(
    parameter MAX_LEVEL = 9,          // clamp at 9 for single digit 7-seg
    parameter PULSE_MS  = 800         // level-up display time (ms)
)(
    input        clk,                 // 100 MHz
    input  [7:0] xp,                  // from PetStatsSystem
    input        dead,                // freeze when dead
    output reg [3:0] level = 4'd1,    // start at level 1
    output reg       level_up_pulse   // 1 when just leveled up (stretched)
);

    // 1 kHz (1 ms) tick from 100 MHz
    reg [16:0] div1k = 0;  // 100_000 - 1 fits in 17 bits
    reg tick_1ms = 0;
    always @(posedge clk) begin
        if (div1k == 17'd99_999) begin
            div1k    <= 0;
            tick_1ms <= 1'b1;
        end else begin
            div1k    <= div1k + 1'b1;
            tick_1ms <= 1'b0;
        end
    end

    // Detect xp wrap: prev>=98 and xp==0 (and not dead)
    reg [7:0] prev_xp = 0;

    // Stretch pulse for PULSE_MS
    reg [15:0] ms_count = 0;
    reg pulse_active = 0;

    always @(posedge clk) begin
        if (dead) begin
            // freeze level-up UI, do not change level while dead
            pulse_active   <= 1'b0;
            level_up_pulse <= 1'b0;
        end else begin
            // detect wrap to 0
            if ((prev_xp >= 8'd98) && (xp == 8'd0)) begin
                if (level < MAX_LEVEL[3:0])
                    level <= level + 1'b1;

                // start pulse window
                pulse_active   <= 1'b1;
                ms_count       <= 0;
                level_up_pulse <= 1'b1;
            end else if (pulse_active && tick_1ms) begin
                if (ms_count >= PULSE_MS[15:0]) begin
                    pulse_active   <= 1'b0;
                    level_up_pulse <= 1'b0;
                end else begin
                    ms_count <= ms_count + 1'b1;
                    level_up_pulse <= 1'b1;
                end
            end else begin
                // keep pulse low otherwise
                if (!pulse_active) level_up_pulse <= 1'b0;
            end
        end

        prev_xp <= xp;
    end

endmodule
