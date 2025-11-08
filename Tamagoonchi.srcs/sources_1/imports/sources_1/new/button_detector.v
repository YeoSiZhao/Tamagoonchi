`timescale 1ns / 1ps

module button_detector(
    input clk,
    input btnU, btnD, btnL, btnC, btnR,
    output reg pulseU, pulseD, pulseL, pulseC, pulseR,
    output btnU_active, btnD_active, btnL_active, btnC_active, btnR_active
);

    reg [2:0] btnU_sync = 3'b000;
    reg [2:0] btnD_sync = 3'b000;
    reg [2:0] btnL_sync = 3'b000;
    reg [2:0] btnC_sync = 3'b000;
    reg [2:0] btnR_sync = 3'b000;

    always @(posedge clk) begin
        btnU_sync <= {btnU_sync[1:0], btnU};
        btnD_sync <= {btnD_sync[1:0], btnD};
        btnL_sync <= {btnL_sync[1:0], btnL};
        btnC_sync <= {btnC_sync[1:0], btnC};
        btnR_sync <= {btnR_sync[1:0], btnR};
    end

    wire btnU_db = &btnU_sync; 
    wire btnD_db = &btnD_sync;
    wire btnL_db = &btnL_sync;
    wire btnC_db = &btnC_sync;
    wire btnR_db = &btnR_sync;

    reg btnU_prev = 0, btnD_prev = 0, btnL_prev = 0, btnC_prev = 0, btnR_prev = 0;

    always @(posedge clk) begin
        pulseU <= btnU_db & ~btnU_prev;
        pulseD <= btnD_db & ~btnD_prev;
        pulseL <= btnL_db & ~btnL_prev;
        pulseC <= btnC_db & ~btnC_prev;
        pulseR <= btnR_db & ~btnR_prev;

        btnU_prev <= btnU_db;
        btnD_prev <= btnD_db;
        btnL_prev <= btnL_db;
        btnC_prev <= btnC_db;
        btnR_prev <= btnR_db;
    end

    reg [23:0] cntU = 0, cntD = 0, cntL = 0, cntC = 0, cntR = 0;

    always @(posedge clk) begin
        // Up
        if (pulseU) cntU <= 24'd12_500_000;
        else if (cntU > 0) cntU <= cntU - 1;

        // Down
        if (pulseD) cntD <= 24'd12_500_000;
        else if (cntD > 0) cntD <= cntD - 1;

        // Left
        if (pulseL) cntL <= 24'd12_500_000;
        else if (cntL > 0) cntL <= cntL - 1;

        // Center
        if (pulseC) cntC <= 24'd12_500_000;
        else if (cntC > 0) cntC <= cntC - 1;

        // Right
        if (pulseR) cntR <= 24'd12_500_000;
        else if (cntR > 0) cntR <= cntR - 1;
    end

    assign btnU_active = (cntU > 0);
    assign btnD_active = (cntD > 0);
    assign btnL_active = (cntL > 0);
    assign btnC_active = (cntC > 0);
    assign btnR_active = (cntR > 0);

endmodule
