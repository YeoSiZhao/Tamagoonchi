`timescale 1ns / 1ps

module flappy_button_debouncer(
    input  clk,             
    input  btnU_raw,      
    input  btnD_raw,        
    input  btnC_raw,        
    output reg btnU_pulse,  
    output reg btnD_pulse, 
    output reg btnC_pulse,  
    output reg btnU_hold,   
    output reg btnD_hold,   
    output reg btnC_hold    
);

    localparam integer DEBOUNCE_MAX = 500_000;   // 5ms debounce at 100 MHz
    reg [19:0] cntU = 0, cntD = 0, cntC = 0;
    reg btnU_sync = 0, btnU_sync_prev = 0;
    reg btnD_sync = 0, btnD_sync_prev = 0;
    reg btnC_sync = 0, btnC_sync_prev = 0;
    reg btnU_raw_prev = 0;
    reg btnD_raw_prev = 0;
    reg btnC_raw_prev = 0;

    always @(posedge clk) begin
        if (btnU_raw == btnU_raw_prev) begin
            if (cntU < DEBOUNCE_MAX) 
                cntU <= cntU + 1;
            else
                btnU_sync <= btnU_raw;
        end else begin
            cntU <= 0;
        end
        btnU_raw_prev <= btnU_raw;

        btnU_sync_prev <= btnU_sync;
        btnU_pulse <= btnU_sync && !btnU_sync_prev;
        btnU_hold <= btnU_sync;

        if (btnD_raw == btnD_raw_prev) begin
            if (cntD < DEBOUNCE_MAX) 
                cntD <= cntD + 1;
            else
                btnD_sync <= btnD_raw;
        end else begin
            cntD <= 0;
        end
        btnD_raw_prev <= btnD_raw;

        btnD_sync_prev <= btnD_sync;
        btnD_pulse <= btnD_sync && !btnD_sync_prev;
        btnD_hold <= btnD_sync;

        if (btnC_raw == btnC_raw_prev) begin
            if (cntC < DEBOUNCE_MAX) 
                cntC <= cntC + 1;
            else
                btnC_sync <= btnC_raw;
        end else begin
            cntC <= 0;
        end
        btnC_raw_prev <= btnC_raw;

        btnC_sync_prev <= btnC_sync;
        btnC_pulse <= btnC_sync && !btnC_sync_prev;
        btnC_hold <= btnC_sync;
    end
endmodule
