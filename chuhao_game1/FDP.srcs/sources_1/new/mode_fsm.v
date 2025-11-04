// mode_fsm.v
`timescale 1ns / 1ps
module mode_fsm(
  input  [1:0] sw10,      // sw[1:0]
  output       in_game
);
  localparam IDLE=2'b00, FEED=2'b01, PLAY=2'b10, SLEEP=2'b11;
  assign in_game = (sw10 == PLAY);
endmodule
