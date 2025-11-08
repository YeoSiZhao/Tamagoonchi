`timescale 1ns / 1ps

module sevenseg_flappy(
    input clk100,
    input [7:0] score,
    input game_over,
    output reg [3:0] an,
    output reg [7:0] seg
);

    reg [19:0] refresh_counter = 0;
    wire [1:0] digit_select = refresh_counter[19:18];
    
    always @(posedge clk100) begin
        refresh_counter <= refresh_counter + 1;
    end

    wire [3:0] digit0 = score % 10;           // Ones
    wire [3:0] digit1 = (score / 10) % 10;    // Tens
    wire [3:0] digit2 = (score / 100) % 10;   // Hundreds
    
    reg [3:0] current_digit;

    always @(*) begin
        case (digit_select)
            2'b00: begin
                an = 4'b1110;  // Rightmost digit (ones)
                current_digit = digit0;
            end
            2'b01: begin
                an = 4'b1101;  // Second from right (tens)
                current_digit = digit1;
            end
            2'b10: begin
                an = 4'b1111;  // Second from left (hundreds)
                current_digit = digit2;
            end
            2'b11: begin
                an = 4'b1111;  // Leftmost digit (show "F" for Flappy or blank)
                current_digit = 4'hF;  // Display "F"
            end
            default: begin
                an = 4'b1111;
                current_digit = 4'h0;
            end
        endcase
    end
    
    // 7-segment decoder
    always @(*) begin
        if (game_over && digit_select == 2'b11) begin
            seg = 8'b00000110;
        end else begin
            case (current_digit)
                4'h0: seg = 8'b11000000; // 0
                4'h1: seg = 8'b11111001; // 1
                4'h2: seg = 8'b10100100; // 2
                4'h3: seg = 8'b10110000; // 3
                4'h4: seg = 8'b10011001; // 4
                4'h5: seg = 8'b10010010; // 5
                4'h6: seg = 8'b10000010; // 6
                4'h7: seg = 8'b11111000; // 7
                4'h8: seg = 8'b10000000; // 8
                4'h9: seg = 8'b10010000; // 9
                4'hF: seg = 8'b10001110; // F (for Flappy)
                default: seg = 8'b11111111; // Blank
            endcase
        end
    end

endmodule