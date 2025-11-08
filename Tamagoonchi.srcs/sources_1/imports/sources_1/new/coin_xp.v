module coin_xp(
    input  wire [7:0] score,   // total coins collected
    output reg  [7:0] exp      // experience output
);

        reg [9:0] calc;

    always @(*) begin
        // exp = 10 + 3 * score, saturated to 255 (8-bit)
        // (score*3 fits in 10 bits; add 10 then clamp)
        calc = (score * 10'd3) + 10'd10;
        exp  = (calc > 10'd255) ? 8'd255 : calc[7:0];
    end
endmodule
