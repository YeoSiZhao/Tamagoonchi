`timescale 1ns / 1ps

module button_detector(
    input clk,
    input btnL, btnC, btnR,
    output reg pulseL, pulseC, pulseR,
    output btnL_active, btnC_active, btnR_active
);

    reg btnL_prev = 0, btnC_prev = 0, btnR_prev = 0;
    
    // Simple edge detection
    always @(posedge clk) begin
        pulseL <= btnL & ~btnL_prev;
        pulseC <= btnC & ~btnC_prev;
        pulseR <= btnR & ~btnR_prev;
        
        btnL_prev <= btnL;
        btnC_prev <= btnC;
        btnR_prev <= btnR;
    end

    // Button press indicators (flash for 0.125s)
    reg [23:0] btnL_counter = 0, btnC_counter = 0, btnR_counter = 0;
    
    always @(posedge clk) begin
        // Left button
        if (pulseL) btnL_counter <= 24'd12_500_000;
        else if (btnL_counter > 0) btnL_counter <= btnL_counter - 1;
        
        // Center button
        if (pulseC) btnC_counter <= 24'd12_500_000;
        else if (btnC_counter > 0) btnC_counter <= btnC_counter - 1;
        
        // Right button
        if (pulseR) btnR_counter <= 24'd12_500_000;
        else if (btnR_counter > 0) btnR_counter <= btnR_counter - 1;
    end

    assign btnL_active = (btnL_counter > 0);
    assign btnC_active = (btnC_counter > 0);
    assign btnR_active = (btnR_counter > 0);

endmodule