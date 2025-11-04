`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
//  STUDENT A NAME: Zhang Yize
//  STUDENT B NAME: Rishabh Ramprasad Shenoy
//  STUDENT C NAME: Yeo Si Zhao
//  STUDENT D NAME: Wang Chuhao
//
//////////////////////////////////////////////////////////////////////////////////

//this is my first game so it is like you control a character to collect as many coins as possible within 15 seconds, to start just press of the direction buttons, C is for reset, 
//I only have one game now so it is turned on whenever it is in game mode which is sw1, in the future will add sw14 and sw15 to control which game

module Top_Student (
  input         clk, 
  input  [15:0] sw,
  input         btnU, btnD, btnL, btnR, btnC,
  // Game OLED on JB
  output [7:0]  JB,
  // Status OLED on JC
  output [7:0]  JC,
  // 7-seg pins
  output [3:0]  an,
  output [6:0]  seg,
  output        dp
);
  // ---------------- Clock Divider ----------------
  // NOTE: your ClockDivider #(8) must truly output ~6.25 MHz.
  // If it's a power-of-two divider, ¡Â16 is 6.25 MHz from 100 MHz.
  wire clk6_25;
  ClockDivider #(8) div6_25 (.clk(clk), .slow_clk(clk6_25));

  // ---------------- Mode ----------------
  // 00=IDLE, 01=FEED, 10=PLAY(COLLECT), 11=SLEEP
  //honestly idk how the fsm state works also so for here i just put 10 first
  wire in_game;
  mode_fsm u_mode(.sw10(sw[1:0]), .in_game(in_game));

  // ---------------- Game state ----------------
  wire [6:0] player_x, coin_x;
  wire [5:0] player_y, coin_y;
  wire [7:0] score;
  wire [6:0] time_s;
  wire       game_over;

//IMPT
//the score will be an output here, should just be a number stored in score, pls try not to change this

  collect_logic game(
    .clk100(clk),
    .enable(in_game),
    .btnU(btnU), .btnD(btnD), .btnL(btnL), .btnR(btnR), .btnC(btnC),
    .player_x(player_x), .player_y(player_y),
    .coin_x(coin_x), .coin_y(coin_y),
    .score(score), .time_s(time_s), .game_over(game_over)
  );
  
 //IMPT
// this was my exp logic can see if you want to use or change
//  wire [7:0] exp;
  
//  get_exp exp_calc (
//      .score(score),
//      .exp(exp)
//  );

  // =====================================================================
  //                        OLED on JB  (GAME DISPLAY)
  // =====================================================================
  //idt need to change this also
  wire        fb_l, send_l, samp_l;
  wire [12:0] pix_idx_l;
  wire [15:0] pix_game_l;
  wire [15:0] pix_left_mux;   // game when in_game, else black

  // Game renderer for JB
  collect_render game_rend_left (
    .pixel_index(pix_idx_l),
    .player_x(player_x), .player_y(player_y),
    .coin_x(coin_x), .coin_y(coin_y),
    .game_over(game_over),
    .pixel_rgb(pix_game_l)
  );

  // When not in_game, blank the JB screen (so other modules can later own it if you wish)
  assign pix_left_mux = in_game ? pix_game_l : 16'h0000;

  // OLED driver on JB
  Oled_Display oled_left (
    .clk(clk6_25), .reset(1'b0),
    .frame_begin(fb_l), .sending_pixels(send_l),
    .sample_pixel(samp_l), .pixel_index(pix_idx_l),
    .pixel_data(pix_left_mux),
    .cs(JB[0]), .sdin(JB[1]), .sclk(JB[3]), .d_cn(JB[4]),
    .resn(JB[5]), .vccen(JB[6]), .pmoden(JB[7])
  );

  // =====================================================================
  //                        OLED on JC  (STATUS/BARS) im just testing out the logic this part should be commented
  // =====================================================================


//wire        fb_r, send_r, samp_r;
//wire [12:0] pix_idx_r;
//wire [15:0] pix_status_r;

//exp_display exp_show (
//    .pixel_index(pix_idx_r),
//    .exp(exp),
//    .game_over(game_over),
//    .pixel_data(pix_status_r)
//);

//Oled_Display oled_right (
//    .clk(clk6_25), .reset(1'b0),
//    .frame_begin(fb_r), .sending_pixels(send_r),
//    .sample_pixel(samp_r), .pixel_index(pix_idx_r),
//    .pixel_data(pix_status_r),
//    .cs(JC[0]), .sdin(JC[1]), .sclk(JC[3]), .d_cn(JC[4]),
//    .resn(JC[5]), .vccen(JC[6]), .pmoden(JC[7])
//);


  // =====================================================================
  //                       7-segment (shared)
  // =====================================================================
  //i use the 7-seg display also but idrk how the seven seg works so i jus turn it on when it is my game
  wire [3:0] an_game; wire [6:0] seg_game; wire dp_game;
  sevenseg_game game7(
    .clk100(clk), .score(score), .time_s(time_s), .game_over(game_over),
    .an(an_game), .seg(seg_game), .dp(dp_game)
  );

  // Non-game 7-seg (placeholder)
  wire [3:0] an_other; wire [6:0] seg_other; wire dp_other;
  status_sevenseg_driver other7(
    .clk100(clk),
    .an(an_other), .seg(seg_other), .dp(dp_other)
  );

  // MUX ownership by mode
  sevenseg_mux ssmux(
    .in_game(in_game),
    .an_game(an_game), .seg_game(seg_game), .dp_game(dp_game),
    .an_other(an_other), .seg_other(seg_other), .dp_other(dp_other),
    .an(an), .seg(seg), .dp(dp)
  );
endmodule
