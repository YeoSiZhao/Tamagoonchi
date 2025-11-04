// sevenseg_mux.v
`timescale 1ns / 1ps
module sevenseg_mux(
  input        in_game,
  input  [3:0] an_game,
  input  [6:0] seg_game,
  input        dp_game,
  input  [3:0] an_other,
  input  [6:0] seg_other,
  input        dp_other,
  output [3:0] an,
  output [6:0] seg,
  output       dp
);
  assign an  = in_game ? an_game  : an_other;
  assign seg = in_game ? seg_game : seg_other;
  assign dp  = in_game ? dp_game  : dp_other;
endmodule
