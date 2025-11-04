`timescale 1ns / 1ps

module Top_Student(
    input         clk,
    input         btnL, btnC, btnR,
    input  [2:0]  sw,
    output [7:0]  JB,          // OLED (right/primary)
    output [7:0]  JA,          // reserved for 2nd OLED (death sprite later)
    output [15:0] led,         // LED warnings
    output [7:0]  seg,         // 7-seg segments (A..G), active-LOW
    output [3:0]  an           // 7-seg anodes, active-LOW
);

    // ============================
    // OLED JB pin mapping (PMOD)
    // ============================
    wire cs, sdin, sclk, d_cn, resn, vccen, pmoden;
    assign JB = {pmoden, vccen, resn, d_cn, sclk, 1'b0, sdin, cs};

    // Reserve JA (2nd OLED not used yet)
    assign JA = 8'b0;

    // ============================
    // 6.25 MHz OLED pixel clock
    // ============================
    wire clk6p25;
    clock_6_25 clkgen (.clk(clk), .clk_out(clk6p25));

    // ============================
    // Buttons (one-shots + levels)
    // ============================
    wire pulseL, pulseC, pulseR;
    wire btnL_active, btnC_active, btnR_active;
    button_detector btn_det (
        .clk(clk),
        .btnL(btnL), .btnC(btnC), .btnR(btnR),
        .pulseL(pulseL), .pulseC(pulseC), .pulseR(pulseR),
        .btnL_active(btnL_active), .btnC_active(btnC_active), .btnR_active(btnR_active)
    );

    // ============================
    // Modes from switches (RAW)
    // ============================
    wire [2:0] mode = sw[2:0];
    wire feed_mode_raw  = (mode == 3'b001);
    wire play_mode_raw  = (mode == 3'b010);
    wire paint_mode_raw = (mode == 3'b100);
    // idle when none of the above (3'b000)

    // ============================
    // Pet stats core (alive/death)
    // ============================
    wire [7:0] hunger, xp, happiness;
    wire [7:0] hunger_bar_length, xp_bar_length, happiness_bar_length;
    wire       dead;

    PetStatsSystem petStats(
        .clk(clk),
        .feed_mode(feed_mode_raw),
        .play_mode(play_mode_raw),
        .paint_mode(paint_mode_raw),
        .pulseL(pulseL), .pulseC(pulseC), .pulseR(pulseR),
        .hunger(hunger), .xp(xp), .happiness(happiness),
        .hunger_bar_length(hunger_bar_length),
        .xp_bar_length(xp_bar_length),
        .happiness_bar_length(happiness_bar_length),
        .dead(dead)
    );

    // Gate UI modes while dead so the renderer cannot leave Idle
    wire feed_mode_ui  = feed_mode_raw  & ~dead;
    wire play_mode_ui  = play_mode_raw  & ~dead;
    wire paint_mode_ui = paint_mode_raw & ~dead;

    // ============================
    // OLED renderer
    // ============================
    wire [12:0] pixel_index;
    wire [6:0]  x = pixel_index % 96;
    wire [6:0]  y = pixel_index / 96;
    wire [15:0] oled_data;

    oled_renderer renderer(
        .clk(clk),
        .feed_mode(feed_mode_ui),
        .play_mode(play_mode_ui),
        .paint_mode(paint_mode_ui),
        .x(x), .y(y),
        .hunger(hunger), .xp(xp), .happiness(happiness),
        .hunger_bar_length(hunger_bar_length),
        .xp_bar_length(xp_bar_length),
        .happiness_bar_length(happiness_bar_length),
        .btnL_active(btnL_active), .btnC_active(btnC_active), .btnR_active(btnR_active),
        .dead(dead),
        .oled_data(oled_data)
    );

    Oled_Display u_display (
        .clk(clk6p25),
        .reset(1'b0),
        .pixel_index(pixel_index),
        .pixel_data(oled_data),
        .cs(cs), .sdin(sdin), .sclk(sclk), .d_cn(d_cn),
        .resn(resn), .vccen(vccen), .pmoden(pmoden)
    );

    // ============================
    // XP → Level controller
    // ============================
    wire [3:0] level;
    wire       level_up_pulse;

    exp_controller u_exp (
        .clk(clk),
        .xp(xp),
        .dead(dead),
        .level(level),
        .level_up_pulse(level_up_pulse)
    );

    // ============================
    // LED warnings (<=20% fast, <=10% very fast, all ON when dead)
    // ============================
    led_warning u_led_warn (
        .clk(clk),
        .hunger(hunger),
        .happiness(happiness),
        .dead(dead),
        .led(led)
    );

    // ============================
    // 7-segment display (Basys-3 mapping: seg[0]=A..seg[6]=G, active-LOW; an active-LOW)
    // ============================
    segment_display u_seg (
        .clk(clk),
        .dead(dead),
        .level(level),
        .seg(seg),
        .an(an)
        );

endmodule
