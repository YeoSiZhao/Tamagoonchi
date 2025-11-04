`timescale 1ns / 1ps

module led_warning #(
    parameter LOW_THRESH  = 8'd20,  // <=20%: fast blink
    parameter CRIT_THRESH = 8'd10   // <=10%: very fast blink
)(
    input        clk,               // 100 MHz
    input  [7:0] hunger,
    input  [7:0] happiness,
    input        dead,
    output reg [15:0] led
);
    // Drive by worst stat
    wire [7:0] min_stat = (hunger < happiness) ? hunger : happiness;

    // ~2 Hz
    reg [25:0] div_2hz = 0; reg b2 = 0;
    always @(posedge clk) begin
        if (div_2hz == 26'd49_999_999) begin div_2hz <= 0; b2 <= ~b2; end
        else div_2hz <= div_2hz + 1'b1;
    end

    // ~5 Hz
    reg [24:0] div_5hz = 0; reg b5 = 0;
    always @(posedge clk) begin
        if (div_5hz == 25'd19_999_999) begin div_5hz <= 0; b5 <= ~b5; end
        else div_5hz <= div_5hz + 1'b1;
    end

    always @(*) begin
        if (dead)                      led = 16'hFFFF;              // all ON when dead
        else if (min_stat <= CRIT_THRESH) led = b5 ? 16'hFFFF : 16'h0000; // very fast
        else if (min_stat <= LOW_THRESH)  led = b2 ? 16'hFFFF : 16'h0000; // fast
        else                             led = 16'h0000;            // healthy → off
    end
endmodule
