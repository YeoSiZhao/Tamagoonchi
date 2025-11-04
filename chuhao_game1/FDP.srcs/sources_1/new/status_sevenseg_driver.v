// status_sevenseg_driver.v  (placeholder non-game driver)
`timescale 1ns / 1ps
module status_sevenseg_driver(
  input  clk100,
  output reg [3:0] an,
  output reg [6:0] seg,
  output reg       dp
);
  // show nothing (all off) while not in game
  always @(posedge clk100) begin
    an <= 4'b1111; seg <= 7'b1111111; dp <= 1'b1;
  end
endmodule
