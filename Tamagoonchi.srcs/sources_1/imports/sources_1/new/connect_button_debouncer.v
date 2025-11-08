`timescale 1ns / 1ps

module connect_button_debouncer(
    input  clk,            
    input  btnL_raw,        
    input  btnR_raw,        
    input  btnC_raw,        
    output reg btnL_pulse,  
    output reg btnR_pulse,  
    output reg btnC_pulse   
);
    localparam integer DEBOUNCE_MAX = 250_000;   
    localparam integer PULSE_HOLD   = 1_000_000; 

    reg [19:0] cntL = 0, cntR = 0, cntC = 0;
    reg btnL_sync = 0, btnL_prev = 0;
    reg btnR_sync = 0, btnR_prev = 0;
    reg btnC_sync = 0, btnC_prev = 0;
    reg [19:0] pulseL_cnt = 0, pulseR_cnt = 0, pulseC_cnt = 0;

    always @(posedge clk) begin
        if (btnL_raw == btnL_prev) begin
            if (cntL < DEBOUNCE_MAX) cntL <= cntL + 1;
        end else begin
            cntL <= 0;
        end
        if (cntL == DEBOUNCE_MAX)
            btnL_sync <= btnL_raw;

        // Rising-edge detect
        if (btnL_sync && !btnL_prev) 
            pulseL_cnt <= PULSE_HOLD;
        else if (pulseL_cnt > 0) 
            pulseL_cnt <= pulseL_cnt - 1;

        btnL_pulse <= (pulseL_cnt > 0);
        btnL_prev <= btnL_sync;

        if (btnR_raw == btnR_prev) begin
            if (cntR < DEBOUNCE_MAX) cntR <= cntR + 1;
        end else begin
            cntR <= 0;
        end
        if (cntR == DEBOUNCE_MAX)
            btnR_sync <= btnR_raw;

        if (btnR_sync && !btnR_prev) 
            pulseR_cnt <= PULSE_HOLD;
        else if (pulseR_cnt > 0) 
            pulseR_cnt <= pulseR_cnt - 1;

        btnR_pulse <= (pulseR_cnt > 0);
        btnR_prev <= btnR_sync;

        if (btnC_raw == btnC_prev) begin
            if (cntC < DEBOUNCE_MAX) cntC <= cntC + 1;
        end else begin
            cntC <= 0;
        end
        if (cntC == DEBOUNCE_MAX)
            btnC_sync <= btnC_raw;

        if (btnC_sync && !btnC_prev) 
            pulseC_cnt <= PULSE_HOLD;
        else if (pulseC_cnt > 0) 
            pulseC_cnt <= pulseC_cnt - 1;

        btnC_pulse <= (pulseC_cnt > 0);
        btnC_prev <= btnC_sync;
    end
endmodule
