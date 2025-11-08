`timescale 1ns / 1ps


module seven_seg_connect4(
`timescale 1ns / 1ps
    input  wire        clk,             
    input  wire        connect4_player,  
    output reg  [3:0]  an,               
    output reg  [7:0]  seg              
);

    localparam [7:0] SEG_P = 8'b10001100; // P
    localparam [7:0] SEG_1 = 8'b11111001; // 1
    localparam [7:0] SEG_2 = 8'b10100100; // 2
    localparam [7:0] SEG_OFF = 8'b11111111; // all off


    reg [15:0] refresh_counter = 0;
    always @(posedge clk) refresh_counter <= refresh_counter + 1;
    wire [1:0] active_digit = refresh_counter[15:14]; 

    always @(*) begin
        case (active_digit)
            2'b00: begin
                an  = 4'b1110;       
                seg = (connect4_player == 1'b0) ? SEG_1 : SEG_2;
            end
            2'b01: begin
                an  = 4'b1101;       
                seg = SEG_P;
            end
            default: begin
                an  = 4'b1111;      
                seg = SEG_OFF;
            end
        endcase
    end

endmodule

