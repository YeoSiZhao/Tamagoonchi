// status_right_render.v  (placeholder non-game screen)
`timescale 1ns / 1ps
module status_right_render(
  input  [12:0] pixel_index,
  output [15:0] pixel_rgb
);
  // simple dark grey background as a placeholder
  assign pixel_rgb = 16'h0000; // black for now
endmodule
