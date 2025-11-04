`timescale 1ns / 1ps
module collect_logic(
    input  clk100,
    input  enable,                   // run only when 1 (PLAY mode)
    input  btnU, btnD, btnL, btnR, btnC,
    output reg [6:0] player_x = 15,
    output reg [5:0] player_y = 25,
    output reg [6:0] coin_x   = 55,
    output reg [5:0] coin_y   = 25,
    output reg [7:0] score    = 0,   // 0..255 (shown on 7seg)
    output reg [6:0] time_s   = 15,  // 15-second timer
    output reg       game_over = 1'b0
);
    // --- constants ---
    localparam W=96, H=64, P_SIZE=10, C_SIZE=6, STEP=2;
    localparam PX_MAX=W-P_SIZE, PY_MAX=H-P_SIZE, CX_MAX=W-C_SIZE, CY_MAX=H-C_SIZE;

    // --- tick generators ---
    // ~60 Hz movement tick
    reg [19:0] div=0;  wire tick=(div==0);
    always @(posedge clk100) div <= div + 1;

    // ~1 Hz timer tick
    reg [26:0] secdiv=0; wire sec_tick=(secdiv==0);
    always @(posedge clk100) secdiv <= secdiv + 1;

    // --- LFSR for pseudo-random coin relocation ---
    reg [15:0] lfsr=16'hACE1;
    always @(posedge clk100)
        lfsr <= {lfsr[14:0], lfsr[15]^lfsr[13]^lfsr[12]^lfsr[10]};

    // --- helpers ---
     function automatic [6:0] clamp7;
         input integer v, lo, hi;
         begin
             // If below lower bound ¡ú clamp to minimum
             if (v < lo)
                 clamp7 = lo[6:0];
             // If above upper bound ¡ú clamp to maximum
             else if (v > hi)
                 clamp7 = hi[6:0];
             // Otherwise, keep original value
             else
                 clamp7 = v[6:0];
         end
     endfunction
     
    function automatic [5:0] clamp6;
           input integer v, lo, hi;
           begin
               // Clamp the Y coordinate to valid screen range
               if (v < lo)
                   clamp6 = lo[5:0];
               else if (v > hi)
                   clamp6 = hi[5:0];
               else
                   clamp6 = v[5:0];
           end
       endfunction
       
 function automatic integer snap;
              input integer base, lo, hi;
              integer range, offset;
              begin
                  // Compute range of allowed positions
                  range  = hi - lo + 1;
      
                  // Wrap the base value into this range (modulo)
                  offset = base % range;
      
                  // Snap down to nearest multiple of STEP
                  // Example: if STEP=2, 27 ¡ú 26
                  offset = offset - (offset % STEP);
      
                  // Shift back into valid range
                  snap = lo + offset;
              end
          endfunction

    // --- overlap detection ---
    wire hit_x = (coin_x + C_SIZE >= player_x) && (coin_x <= player_x + P_SIZE);
    wire hit_y = (coin_y + C_SIZE >= player_y) && (coin_y <= player_y + P_SIZE);
    wire caught = hit_x & hit_y;

    // --- game start flag ---
    reg started = 0;

    always @(posedge clk100) begin
        // reset always works
        if (btnC) begin
            player_x<=15; player_y<=25; coin_x<=55; coin_y<=25;
            score<=0; time_s<=15; game_over<=1'b0; started<=0;
        end
        else if (enable) begin
            // detect first movement press ¡ú start timer
            if (!started && (btnU | btnD | btnL | btnR))
                started <= 1'b1;

            // handle movement and scoring only when started
            if (tick && !game_over && started) begin
                if (btnL) player_x <= clamp7(player_x-STEP,0,PX_MAX);
                if (btnR) player_x <= clamp7(player_x+STEP,0,PX_MAX);
                if (btnU) player_y <= clamp6(player_y-STEP,0,PY_MAX);
                if (btnD) player_y <= clamp6(player_y+STEP,0,PY_MAX);

                if (caught) begin
                    score  <= score + 1;
                    coin_x <= clamp7(snap(lfsr[7:0],  0,CX_MAX),0,CX_MAX);
                    coin_y <= clamp6(snap(lfsr[15:8], 0,CY_MAX),0,CY_MAX);
                end
            end

            // countdown only if game started
            if (started && time_s!=0 && sec_tick && !game_over) begin
                if (time_s>0) time_s <= time_s - 1;
                if (time_s==1) game_over <= 1'b1;
            end
        end else begin
            // leaving PLAY mode
            started <= 0;
        end
    end
endmodule
