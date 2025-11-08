`timescale 1ns / 1ps
module sevenseg_game(
  input  clk100,
  input  [7:0] score,    
  input  [6:0] time_s,   
  input        game_over,
  output reg [3:0] an,
  output reg [7:0] seg

);

  wire [7:0] sc  = (score > 99) ? 8'd99 : score;
  wire [6:0] tm  = (time_s > 99) ? 7'd99 : time_s;

  wire [3:0] sc_tens = sc / 10;
  wire [3:0] sc_ones = sc % 10;
  wire [3:0] tm_tens = tm / 10;
  wire [3:0] tm_ones = tm % 10;

  reg [15:0] scan = 0;
  always @(posedge clk100) scan <= scan + 1;
  wire [1:0] idx = scan[15:14];  // 4 digits

reg [25:0] blink_counter = 0;
always @(posedge clk100)
    blink_counter <= blink_counter + 1;
wire blink = blink_counter[24];  // matches render blink

  function [7:0] seg7;
    input [3:0] d;
    case(d)
      4'd0: seg7 = 8'b11000000;
      4'd1: seg7 = 8'b11111001;
      4'd2: seg7 = 8'b10100100;
      4'd3: seg7 = 8'b10110000;
      4'd4: seg7 = 8'b10011001;
      4'd5: seg7 = 8'b10010010;
      4'd6: seg7 = 8'b10000010;
      4'd7: seg7 = 8'b11111000;
      4'd8: seg7 = 8'b10000000;
      4'd9: seg7 = 8'b10010000;
      default: seg7 = 8'b11111111;
    endcase
  endfunction

  reg [7:0] seg_d;
  reg [3:0] an_d;
  reg dp_d;

  always @* begin


    case (idx)
        2'd0: begin
            an_d = 4'b1110;  // rightmost
            seg_d = seg7(tm_ones);
            seg_d[7] = 1'b1; // DP off
        end
        2'd1: begin
            an_d = 4'b1101;  // next
            seg_d = seg7(tm_tens);
            seg_d[7] = 1'b1; // DP OFF here (between an1 and an0)
        end
        2'd2: begin
            an_d = 4'b1011;  // next
            seg_d = seg7(sc_ones);
            seg_d[7] = 1'b0; // DP ON here (between an3 and an2)
        end
        2'd3: begin
            an_d = 4'b0111;  // leftmost
            seg_d = seg7(sc_tens);
            seg_d[7] = 1'b1; // DP off
        end
    endcase
end

  always @(posedge clk100) begin
    an  <= an_d;
    seg <= seg_d;
  end
endmodule
