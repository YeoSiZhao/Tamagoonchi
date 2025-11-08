`timescale 1ns / 1ps

module led_warning #(
    parameter LOW_THRESH  = 8'd20,
    parameter CRIT_THRESH = 8'd10
)(
    input        clk,
    input  [7:0] hunger,
    input  [7:0] happiness,
    input        dead,
    input  [3:0] level,           // Changed to 4-bit
    input        level_up_pulse,  // NEW: direct pulse input
    output reg [15:0] led
);

    // Determine the weakest stat
    wire [7:0] min_stat = (hunger < happiness) ? hunger : happiness;

    // Blink clocks (2 Hz and 5 Hz)
    reg [25:0] div_2hz = 0;
    reg b2 = 0;
    always @(posedge clk) begin
        if (div_2hz == 26'd49_999_999) begin
            div_2hz <= 0;
            b2      <= ~b2;
        end else
            div_2hz <= div_2hz + 1;
    end

    reg [24:0] div_5hz = 0;
    reg b5 = 0;
    always @(posedge clk) begin
        if (div_5hz == 25'd19_999_999) begin
            div_5hz <= 0;
            b5      <= ~b5;
        end else
            div_5hz <= div_5hz + 1;
    end

    // Dual-Wave Animation Control
    reg [31:0] wave_counter = 0;
    reg [4:0]  wave_index = 0;
    reg [1:0]  wave_repeat = 0;
    reg        wave_dir = 0;
    reg        wave_active = 0;

    always @(posedge clk) begin
        if (level_up_pulse && !wave_active) begin
            wave_active  <= 1;
            wave_counter <= 0;
            wave_index   <= 0;
            wave_dir     <= 0;
            wave_repeat  <= 0;
        end else if (wave_active) begin
            if (wave_counter >= 6_250_000 - 1) begin
                wave_counter <= 0;
                if (wave_dir == 0) begin
                    if (wave_index < 15)
                        wave_index <= wave_index + 1;
                    else begin
                        wave_dir   <= 1;
                        wave_index <= 15;
                    end
                end else begin
                    if (wave_index > 0)
                        wave_index <= wave_index - 1;
                    else begin
                        wave_dir    <= 0;
                        wave_repeat <= wave_repeat + 1;
                        if (wave_repeat >= 2)
                            wave_active <= 0;
                    end
                end
            end else
                wave_counter <= wave_counter + 1;
        end
    end

    // LED Output Logic
    always @(*) begin
        if (wave_active) begin
            led = 16'b0;
            led[wave_index]       = 1'b1;
            led[15 - wave_index]  = 1'b1;
        end else if (dead)
            led = 16'hFFFF;
        else if (min_stat <= CRIT_THRESH)
            led = b5 ? 16'hFFFF : 16'h0000;
        else if (min_stat <= LOW_THRESH)
            led = b2 ? 16'hFFFF : 16'h0000;
        else
            led = 16'h0000;
    end

endmodule