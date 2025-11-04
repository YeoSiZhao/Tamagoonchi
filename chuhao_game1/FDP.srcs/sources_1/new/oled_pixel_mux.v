// oled_pixel_mux.v
`timescale 1ns / 1ps
module oled_pixel_mux(
  input        in_game,                // 1 = show game; 0 = show other content
  input [15:0] game_pixel,
  input [15:0] other_pixel,
  output [15:0] pixel_to_oled
);
  assign pixel_to_oled = in_game ? game_pixel : other_pixel;
endmodule
