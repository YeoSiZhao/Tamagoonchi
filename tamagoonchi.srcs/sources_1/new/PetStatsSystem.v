`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NUS EE2026
// Engineer: Wang Chuhao (S1_07)
//
// Module Name: PetStatsSystem
// Description:
//   Unified Hunger, Fatigue, and Health management system
//   All stats start full (100) and slowly decrease over time.
//   Handles feeding (L/C/R) and sleep recovery, with internal 1 Hz timing.
//
// Inputs:
//   clk         - 100 MHz FPGA clock
//   feed_mode   - Active when in Feed mode (SW)
//   sleep_mode  - Active when in Sleep mode (SW)
//   pulseL/C/R  - One-shot pulses from button presses
//
// Outputs:
//   hunger, fatigue, health          - 0-100 percentage values (100 = full)
//   hunger_bar_length, fatigue_bar_length, health_bar_length - mapped 0-90 pixel values
//
//////////////////////////////////////////////////////////////////////////////////

module PetStatsSystem(
    input  clk,                // 100 MHz Basys3 clock
    input  feed_mode,          // Feed mode toggle
    input  sleep_mode,         // Sleep mode toggle
    input  pulseL, pulseC, pulseR,  // Button pulses (Left, Center, Right)
    output reg [7:0] hunger,   // 0-100 scale (100 = full)
    output reg [7:0] fatigue,  // 0-100 scale (100 = full energy)
    output reg [7:0] health,   // 0-100 scale (100 = perfect health)
    output [7:0] hunger_bar_length,
    output [7:0] fatigue_bar_length,
    output [7:0] health_bar_length
);

    /////////////////////////////////////////////
    // INITIALIZATION
    /////////////////////////////////////////////
    initial begin
        hunger  = 8'd100;
        fatigue = 8'd100;
        health  = 8'd100;
    end

    /////////////////////////////////////////////
    // 1 Hz TIMING GENERATOR
    /////////////////////////////////////////////
    reg [26:0] counter1 = 0;
    reg tick_1hz = 0;

    always @(posedge clk) begin
        if (counter1 >= 50_000_000) begin
            counter1 <= 0;
            tick_1hz <= ~tick_1hz;
        end else begin
            counter1 <= counter1 + 1;
        end
    end

    reg tick_prev = 0;
    always @(posedge clk) tick_prev <= tick_1hz;
    wire sec_pulse = tick_1hz & ~tick_prev;  // one pulse per second

    /////////////////////////////////////////////
    // MAIN STAT UPDATE LOGIC
    /////////////////////////////////////////////
    always @(posedge clk) begin
        // Initialize on startup
        if (hunger === 8'bX)  hunger  <= 8'd100;
        if (fatigue === 8'bX) fatigue <= 8'd100;
        if (health  === 8'bX) health  <= 8'd100;

        //----------------------------------
        // FEED MODE (SWITCH SELECTED)
        //----------------------------------
        if (feed_mode) begin
            // Button Left ? Apple
            if (pulseL) begin
                hunger  <= (hunger + 8'd12 <= 100) ? hunger + 8'd12 : 8'd100; // fills hunger, ensures max 100
                fatigue <= (fatigue > 8) ? fatigue - 8'd8 : 8'd0;     // uses energy
                health  <= (health < 100) ? health + 8'd2 : 8'd100;
            end
            // Button Center ? Cake
            else if (pulseC) begin
                hunger  <= (hunger + 8'd22 <= 100) ? hunger + 8'd22 : 8'd100;
                fatigue <= (fatigue > 12) ? fatigue - 8'd12 : 8'd0;
                health  <= (health < 100) ? health + 8'd3 : 8'd100;
            end
            // Button Right ? Drink
            else if (pulseR) begin
                hunger  <= (hunger + 8'd32 <= 100) ? hunger + 8'd32 : 8'd100;
                fatigue <= (fatigue > 16) ? fatigue - 8'd16 : 8'd0;
                health  <= (health < 100) ? health + 8'd4 : 8'd100;
            end
            // Natural decay (every second)
            else if (sec_pulse) begin
                hunger  <= (hunger > 0) ? hunger - 8'd1 : 8'd0;      // slowly gets hungry again
                fatigue <= (fatigue > 0) ? fatigue - 8'd1 : 8'd0;    // gets tired
                health  <= (health > 0) ? health - 8'd1 : 8'd0;      // slight health decay
            end
        end
        //----------------------------------
        // SLEEP MODE (SWITCH SELECTED)
        //----------------------------------
        else if (sleep_mode && sec_pulse) begin
            hunger  <= (hunger > 0) ? hunger - 8'd1 : 8'd0;          // gets hungrier during sleep
            fatigue <= (fatigue < 100) ? fatigue + 8'd3 : 8'd100;    // recovers energy during sleep
            health  <= (health < 100) ? health + 8'd2 : 8'd100;      // recovers health during sleep
        end        
        //----------------------------------
        // IDLE MODE (DEFAULT)
        //----------------------------------
        else if (sec_pulse) begin
            hunger  <= (hunger > 0) ? hunger - 8'd1 : 8'd0;          // slowly gets hungry in idle
            fatigue <= (fatigue > 0) ? fatigue - 8'd1 : 8'd0;        // slowly tired in idle
            health  <= (health > 0) ? health - 8'd1 : 8'd0;          // slow health decay in idle
        end
    end

    /////////////////////////////////////////////
    // BAR CONVERSIONS (FOR OLED DISPLAY)
    /////////////////////////////////////////////
    // Ensures that the maximum bar length is 90 (pixel value cap)
    assign hunger_bar_length  = (hunger  * 90) / 100;   // longer bar = fuller
    assign fatigue_bar_length = (fatigue * 90) / 100;   // longer bar = more energy
    assign health_bar_length  = (health  * 90) / 100;   // longer bar = better health

endmodule
