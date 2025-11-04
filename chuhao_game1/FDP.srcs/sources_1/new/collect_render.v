// collect_render.v
`timescale 1ns / 1ps
module collect_render(
    input      [12:0] pixel_index,
    input      [6:0]  player_x,
    input      [5:0]  player_y,
    input      [6:0]  coin_x,
    input      [5:0]  coin_y,
    input             game_over,
    output reg [15:0] pixel_rgb
);
    localparam W=96,H=64,P_SIZE=10,C_SIZE=6;
    localparam [15:0] BLACK=16'h0000, WHITE=16'hFFFF, YEL=16'hFFE0, RED=16'hF800;

    wire [6:0] x = pixel_index % W;
    wire [5:0] y = pixel_index / W;

    wire on_p = (x>=player_x && x<player_x+P_SIZE) && (y>=player_y && y<player_y+P_SIZE);
    wire on_c = (x>=coin_x   && x<coin_x+C_SIZE)   && (y>=coin_y   && y<coin_y+C_SIZE);

    always @* begin
      if      (on_p)          pixel_rgb = WHITE;
      else if (on_c)          pixel_rgb = YEL;
      else if (game_over)     pixel_rgb = RED;      // red background when time up
      else                    pixel_rgb = BLACK;
    end
endmodule
