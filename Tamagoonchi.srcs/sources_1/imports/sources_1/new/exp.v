`timescale 1ns / 1ps

module exp_controller #(
    parameter MAX_LEVEL   = 3,
    parameter START_LEVEL = 1,
    parameter PULSE_MS    = 800
)(
    input        clk,
    input        dead,
    input        xp_wrap_pulse,
    input        pet_reset_pulse,
    output reg [3:0] level,
    output reg       level_up_pulse
);

    initial begin
        level          = START_LEVEL[3:0];
        level_up_pulse = 1'b0;
    end

    // 1 ms tick
    reg [16:0] div1k = 0;
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

    // Pulse stretcher
    reg [15:0] ms_count = 0;
    reg active = 0;

    always @(posedge clk) begin
        if (dead) begin
            active         <= 1'b0;
            level_up_pulse <= 1'b0;
            // Keep level frozen while dead
        end else begin
            // Explicit reset from PetStatsSystem
            if (pet_reset_pulse) begin
                level          <= START_LEVEL[3:0];
                active         <= 1'b0;
                level_up_pulse <= 1'b0;
            end
            // Level-up on XP wrap
            else if (xp_wrap_pulse) begin
                if (level < MAX_LEVEL[3:0])
                    level <= level + 1'b1;
                active         <= 1'b1;
                ms_count       <= 0;
                level_up_pulse <= 1'b1;
            end
            // Stretch UI pulse
            else if (active && tick_1ms) begin
                if (ms_count >= PULSE_MS[15:0]) begin
                    active         <= 1'b0;
                    level_up_pulse <= 1'b0;
                end else begin
                    ms_count       <= ms_count + 1'b1;
                    level_up_pulse <= 1'b1;
                end
            end else if (!active) begin
                level_up_pulse <= 1'b0;
            end
        end
    end

endmodule