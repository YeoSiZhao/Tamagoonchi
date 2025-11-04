// sevenseg_game.v  (Basys3: an[3:0], seg[6:0], dp)
`timescale 1ns / 1ps
module sevenseg_game(
  input  clk100,
  input  [7:0] score,    // 0..255 (we clamp to 00..99)
  input  [6:0] time_s,   // 0..99 expected
  input        game_over,
  output reg [3:0] an,
  output reg [6:0] seg,
  output reg       dp
);
  // split to BCD (clamp 0..99)
  wire [7:0] sc  = (score>99)?8'd99:score;
  wire [6:0] tm  = (time_s>99)?7'd99:time_s;

  wire [3:0] sc_tens = sc/10;
  wire [3:0] sc_ones = sc%10;
  wire [3:0] tm_tens = tm/10;
  wire [3:0] tm_ones = tm%10;

  // simple scan ~1kHz
  reg [15:0] scan=0; always @(posedge clk100) scan<=scan+1;
  wire [1:0] idx = scan[15:14];   // 4 digits

  // blink for game_over
  reg [25:0] blkc=0; always @(posedge clk100) blkc<=blkc+1;
  wire blink = blkc[23];  // ~3 Hz

  // BCD -> segments (abcdefg, active LOW assumed for Basys3: set high if using common anode/cathode accordingly)
  function [6:0] seg7; input [3:0] d;
    case(d)
      4'd0: seg7=7'b1000000; 4'd1: seg7=7'b1111001; 4'd2: seg7=7'b0100100; 4'd3: seg7=7'b0110000;
      4'd4: seg7=7'b0011001; 4'd5: seg7=7'b0010010; 4'd6: seg7=7'b0000010; 4'd7: seg7=7'b1111000;
      4'd8: seg7=7'b0000000; 4'd9: seg7=7'b0010000; default: seg7=7'b1111111;
    endcase
  endfunction

  // mux digits: [3]=leftmost
  reg [6:0] seg_d; reg [3:0] an_d; reg dp_d;

  always @* begin
    dp_d = 1'b1; // off
    case(idx)
      2'd0: begin // rightmost
        an_d = 4'b1110;
        seg_d = (game_over && blink) ? 7'b1111111 : seg7(tm_ones);
      end
      2'd1: begin
        an_d = 4'b1101; seg_d = (game_over && blink) ? 7'b1111111 : seg7(tm_tens);
      end
      2'd2: begin
        an_d = 4'b1011; seg_d = seg7(sc_ones);
      end
      default: begin
        an_d = 4'b0111; seg_d = seg7(sc_tens);
      end
    endcase
  end

  always @(posedge clk100) begin
    an <= an_d; seg <= seg_d; dp <= dp_d;
  end
endmodule
