`timescale 1ns / 1ps

module segment_display(
    input        clk,
    input        dead,
    input  [1:0] level,
    output reg [7:0] seg,   // {dp, A,B,C,D,E,F,G}
    output reg [3:0] an
);
    reg [19:0] refresh_counter = 0;
    reg [1:0]  digit = 0;

    // ~1 kHz digit scan (kept exactly)
    always @(posedge clk) begin
        refresh_counter <= refresh_counter + 1;
        if (refresh_counter == 20'd100_000) begin
            refresh_counter <= 0;
            digit <= digit + 2'd1;
        end
    end

    always @(*) begin
        if (dead) begin
            // --- DEAD ---
            case (digit)
                2'd0: begin seg = 8'b10100001; an = 4'b0111; end // D
                2'd1: begin seg = 8'b10000110; an = 4'b1011; end // E
                2'd2: begin seg = 8'b10001000; an = 4'b1101; end // A
                2'd3: begin seg = 8'b10100001; an = 4'b1110; end // D
            endcase
        end else begin
            // --- L U L <level> ---
            case (digit)
                2'd0: begin seg = 8'b11000111; an = 4'b0111; end // L
                2'd1: begin seg = 8'b11000001; an = 4'b1011; end // U
                2'd2: begin seg = 8'b11000111; an = 4'b1101; end // L
                2'd3: begin
                    case (level)
                        2'd1: seg = 8'b11111001; // 1
                        2'd2: seg = 8'b10100100; // 2
                        2'd3: seg = 8'b10110000; // 3
                        default: seg = 8'b11111111; // blank
                    endcase
                    an = 4'b1110;
                end
            endcase
        end
    end
endmodule
