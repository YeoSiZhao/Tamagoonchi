`timescale 1ns / 1ps

module Top_Student(
    input clk,
    input btnL, btnC, btnR,
    input [2:0] sw,
    output [7:0] JB
);

    // OLED pin mapping
    wire cs, sdin, sclk, d_cn, resn, vccen, pmoden;
    assign JB = {pmoden, vccen, resn, d_cn, sclk, 1'b0, sdin, cs};

    // Clock generation
    wire clk6p25;
    clock_6_25 clkgen (.clk(clk), .clk_out(clk6p25));

    // Button detection
    wire pulseL, pulseC, pulseR;
    wire btnL_active, btnC_active, btnR_active;
    button_detector btn_det (
        .clk(clk),
        .btnL(btnL),
        .btnC(btnC),
        .btnR(btnR),
        .pulseL(pulseL),
        .pulseC(pulseC),
        .pulseR(pulseR),
        .btnL_active(btnL_active),
        .btnC_active(btnC_active),
        .btnR_active(btnR_active)
    );

    // Mode control
    wire [2:0] mode = sw[2:0]; // 000=Idle, 001=Feed, 010=Play, 100=Sleep
    wire feed_mode  = (mode == 3'b001);
    wire play_mode  = (mode == 3'b010);
    wire sleep_mode = (mode == 3'b100);

    // Hunger system
    wire [7:0] hunger;
    wire [7:0] hunger_bar_length;
    wire [7:0] fatigue;
    wire [7:0] fatigue_bar_length;
    wire [7:0] health;
    wire [7:0] health_bar_length;    
    PetStatsSystem  petStats(
            .clk(clk),
            .feed_mode(feed_mode),
            .sleep_mode(sleep_mode),
            .pulseL(pulseL),
            .pulseC(pulseC),
            .pulseR(pulseR),
            .hunger(hunger),
            .fatigue(fatigue),
            .health(health),
            .hunger_bar_length(hunger_bar_length),
            .fatigue_bar_length(fatigue_bar_length),
            .health_bar_length(health_bar_length)
        );

    // OLED drawing
    wire [12:0] pixel_index;
    wire [6:0] x = pixel_index % 96;
    wire [6:0] y = pixel_index / 96;
    wire [15:0] oled_data;
    
    oled_renderer renderer (
        .clk(clk),
        .feed_mode(feed_mode),
        .sleep_mode(sleep_mode),
        .x(x),
        .y(y),
        .hunger(hunger),
        .fatigue(fatigue),
        .health(health),
        .hunger_bar_length(hunger_bar_length),
        .fatigue_bar_length(fatigue_bar_length),
        .health_bar_length(health_bar_length),
        .btnL_active(btnL_active),
        .btnC_active(btnC_active),
        .btnR_active(btnR_active),
        .oled_data(oled_data)
    );

    // OLED display driver
    Oled_Display u_display (
        .clk(clk6p25),
        .reset(1'b0),
        .pixel_index(pixel_index),
        .pixel_data(oled_data),
        .cs(cs),
        .sdin(sdin),
        .sclk(sclk),
        .d_cn(d_cn),
        .resn(resn),
        .vccen(vccen),
        .pmoden(pmoden)
    );

endmodule