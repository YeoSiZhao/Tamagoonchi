`timescale 1ns / 1ps

module Top_Student(
    input         clk,
    input         btnU, btnD, btnL, btnC, btnR,
    input  [15:0] sw,
    inout PS2_CLK,
    inout PS2_DATA,
    output [7:0]  JB,
    output [7:0]  JA,
    output [15:0] led,
    output [7:0]  seg,
    output [3:0]  an

);
    wire dead;
    
    // Clock divider
    wire clk6p25;
    clock_6_25 clkgen (.clk(clk), .clk_out(clk6p25));

    // Button detector
    wire pulseU, pulseD, pulseL, pulseC, pulseR;
    wire btnU_active, btnD_active, btnL_active, btnC_active, btnR_active;

    button_detector btn_det (
        .clk(clk),
        .btnU(btnU), .btnD(btnD), .btnL(btnL), .btnC(btnC), .btnR(btnR),
        .pulseU(pulseU), .pulseD(pulseD),
        .pulseL(pulseL), .pulseC(pulseC), .pulseR(pulseR),
        .btnU_active(btnU_active), .btnD_active(btnD_active),
        .btnL_active(btnL_active), .btnC_active(btnC_active), .btnR_active(btnR_active)
    );

    // Mode selection
    wire feed_mode_raw  = sw[0];
    wire game_mode_raw  = sw[1];
    wire [2:0] game_sel = sw[15:13];

    wire game_mode = game_mode_raw & ~dead;
    
    wire coin_game_selected   = (game_sel == 3'b001);
    wire flappy_game_selected = (game_sel == 3'b010);
    wire connect4_selected    = (game_sel == 3'b100);

    wire enable_coin     = game_mode && coin_game_selected;
    wire enable_flappy   = game_mode && flappy_game_selected;
    wire enable_connect4 = game_mode && connect4_selected;

    wire in_game = enable_coin | enable_flappy | enable_connect4;
    
    // ============================================================
    // PIXEL INDEX AND COORDINATES - MUST BE DECLARED EARLY
    // ============================================================
    wire [12:0] pix_idx_game;
    wire [6:0]  x_game = pix_idx_game % 96;
    wire [5:0]  y_game = pix_idx_game / 96;
    
    // ============================================================
    // MOUSE MODULE INTEGRATION
    // ============================================================
    wire [11:0] mouse_xpos, mouse_ypos;
    wire mouse_left, mouse_middle, mouse_right;
    wire mouse_event;

    MouseCtl u_mouse (
        .clk(clk),
        .rst(1'b0),
        .xpos(mouse_xpos),
        .ypos(mouse_ypos),
        .zpos(),
        .left(mouse_left),
        .middle(mouse_middle),
        .right(mouse_right),
        .new_event(mouse_event),
        .value(12'b0),
        .setx(1'b0),
        .sety(1'b0),
        .setmax_x(1'b0),
        .setmax_y(1'b0),
        .ps2_clk(PS2_CLK),
        .ps2_data(PS2_DATA)
    );

    // ============================================================
    // MOUSE CURSOR RENDERING
    // ============================================================
    wire is_cursor;
    mouse_cursor u_cursor (
        .x(x_game),
        .y(y_game),
        .mouse_x(mouse_xpos),
        .mouse_y(mouse_ypos),
        .is_cursor(is_cursor)
    );
    
    // ============================================================
    // PET JUMP CONTROLLER
    // ============================================================
    wire [5:0] pet_jump_offset;
    wire pet_is_jumping;
    wire happiness_boost_pulse;
    
    // Get scaled cursor position for hit detection
    wire [6:0] cursor_x_scaled;
    wire [5:0] cursor_y_scaled;
    
    // Instantiate cursor position calculator (reuse from mouse_cursor logic)
    wire [11:0] temp_x_calc = mouse_xpos >> 3;
    wire [11:0] temp_y_calc = mouse_ypos >> 3;
    assign cursor_x_scaled = (temp_x_calc >= 12'd96) ? 7'd95 : temp_x_calc[6:0];
    assign cursor_y_scaled = (temp_y_calc >= 12'd64) ? 6'd63 : temp_y_calc[5:0];
    
    pet_jump_controller u_pet_jump (
        .clk(clk),
        .mouse_left(mouse_left),
        .mouse_x(cursor_x_scaled),
        .mouse_y(cursor_y_scaled),
        .dead(dead),
        .jump_offset(pet_jump_offset),
        .is_jumping(pet_is_jumping),
        .happiness_boost_pulse(happiness_boost_pulse)
    );    
    
    // Button routing
    wire pulseU_coin = enable_coin ? pulseU : 1'b0;
    wire pulseD_coin = enable_coin ? pulseD : 1'b0;
    wire pulseL_coin = enable_coin ? pulseL : 1'b0;
    wire pulseR_coin = enable_coin ? pulseR : 1'b0;
    wire pulseC_coin = enable_coin ? pulseC : 1'b0;
    
    wire pulseU_flappy = enable_flappy ? pulseU : 1'b0;
    wire pulseD_flappy = enable_flappy ? pulseD : 1'b0;
    wire pulseC_flappy = enable_flappy ? pulseC : 1'b0;
    
    wire pulseL_connect4 = enable_connect4 ? pulseL : 1'b0;
    wire pulseR_connect4 = enable_connect4 ? pulseR : 1'b0;
    wire pulseC_connect4 = enable_connect4 ? pulseC : 1'b0;
    
    wire pulseL_pet = (!in_game) ? pulseL : 1'b0;
    wire pulseC_pet = (!in_game) ? pulseC : 1'b0;
    wire pulseR_pet = (!in_game) ? pulseR : 1'b0;

    // Game exit detection
    reg prev_coin_enable = 0;
    reg prev_flappy_enable = 0;
    reg prev_connect4_enable = 0;
    reg [7:0] captured_coin_xp = 0;
    reg [7:0] captured_flappy_xp = 0;
    reg [7:0] captured_connect4_xp = 0;
    
    always @(posedge clk) begin
        prev_coin_enable     <= enable_coin;
        prev_flappy_enable   <= enable_flappy;
        prev_connect4_enable <= enable_connect4;
        
        // Capture XP values when games are active
        if (enable_coin)
            captured_coin_xp <= game_xp_coin;
        if (enable_flappy)
            captured_flappy_xp <= game_xp_flappy;
        if (enable_connect4)
            captured_connect4_xp <= connect4_exp;
    end
    
    wire exit_coin     = prev_coin_enable & ~enable_coin;
    wire exit_flappy   = prev_flappy_enable & ~enable_flappy;
    wire exit_connect4 = prev_connect4_enable & ~enable_connect4;
    
    wire reset_coin     = exit_coin;
    wire reset_flappy   = exit_flappy;
    wire reset_connect4 = exit_connect4;
    
    wire game_exited = exit_coin | exit_flappy | exit_connect4;
    
    // Select which XP to award
    wire [7:0] selected_xp = exit_coin     ? captured_coin_xp :
                             exit_flappy   ? captured_flappy_xp :
                             exit_connect4 ? captured_connect4_xp :
                                             8'd0;

    // Pet system
    wire [7:0] hunger, xp, happiness;
    wire [7:0] hunger_bar_length, xp_bar_length, happiness_bar_length;
    wire [1:0] food_select_wire;
    wire xp_wrap_pulse, pet_reset_pulse, xp_add_done;

    PetStatsSystem petStats(
        .clk(clk),
        .feed_mode(feed_mode_raw & ~dead),
        .game_mode(in_game),
        .pulseL(pulseL_pet),
        .pulseC(pulseC_pet),
        .pulseR(pulseR_pet),
        .food_select(food_select_wire),
        .happiness_boost_pulse(happiness_boost_pulse),
        .level(level),
        .exit_coin(exit_coin),
        .exit_flappy(exit_flappy),
        .exit_connect4(exit_connect4),
        .game_xp(selected_xp),
        .sw(sw),
        .hunger(hunger),
        .xp(xp),
        .happiness(happiness),
        .hunger_bar_length(hunger_bar_length),
        .xp_bar_length(xp_bar_length),
        .happiness_bar_length(happiness_bar_length),
        .dead(dead),
        .xp_wrap_pulse(xp_wrap_pulse),
        .pet_reset_pulse(pet_reset_pulse),
        .xp_add_done(xp_add_done)    
    );

    // Game 1: Coin collect
    wire [6:0] player_x, coin_x;
    wire [5:0] player_y, coin_y;
    wire [7:0] score;
    wire [6:0] time_s;
    wire       game_over_snake;

    collect_logic u_collect (
        .clk100(clk),
        .enable(enable_coin),
        .btnU(btnU_active), .btnD(btnD_active),
        .btnL(btnL_active), .btnR(btnR_active), .btnC(btnC_active),
        .player_x(player_x), .player_y(player_y),
        .coin_x(coin_x), .coin_y(coin_y),
        .score(score), .time_s(time_s),
        .game_over(game_over_snake)
    );

    // Game 2: Flappy bird
    wire flapU_pulse, flapD_pulse, flapC_pulse;
    wire flapU_hold, flapD_hold, flapC_hold;

    flappy_button_debouncer flap_btns (
        .clk(clk),
        .btnU_raw(btnU),
        .btnD_raw(btnD),
        .btnC_raw(btnC),
        .btnU_pulse(flapU_pulse),
        .btnD_pulse(flapD_pulse),
        .btnC_pulse(flapC_pulse),
        .btnU_hold(flapU_hold),
        .btnD_hold(flapD_hold),
        .btnC_hold(flapC_hold)
    );
    
    wire [6:0] bird_y;
    wire [7:0] pipe_x;
    wire [5:0] gap_y;
    wire [7:0] flap_score;
    wire flap_game_over;

    flappy_logic u_flappy (
        .clk(clk),
        .enable(enable_flappy),
        .btnU(flapU_pulse),
        .btnC(flapC_pulse),
        .bird_y(bird_y),
        .pipe_x(pipe_x),
        .gap_y(gap_y),
        .score(flap_score),
        .game_over(flap_game_over)
    );

    // Game 3: Connect 4
    wire connectL_pulse_raw, connectR_pulse_raw, connectC_pulse_raw;
    connect_button_debouncer connect_btns (
        .clk(clk),
        .btnL_raw(btnL),
        .btnR_raw(btnR),
        .btnC_raw(btnC),
        .btnL_pulse(connectL_pulse_raw),
        .btnR_pulse(connectR_pulse_raw),
        .btnC_pulse(connectC_pulse_raw)
    );
     
    wire connectL_pulse = enable_connect4 ? connectL_pulse_raw : 1'b0;
    wire connectR_pulse = enable_connect4 ? connectR_pulse_raw : 1'b0;
    wire connectC_pulse = enable_connect4 ? connectC_pulse_raw : 1'b0;
    
    wire [15:0] pix_connect4;
    wire [7:0]  connect4_exp;
    wire        connect4_player;
 
    connect4 u_connect4 (
        .clk(clk),
        .pulseL(connectL_pulse),
        .pulseR(connectR_pulse),
        .pulseC(connectC_pulse),
        .reset(reset_connect4),
        .x(x_game),
        .y(y_game),
        .oled_data(pix_connect4),
        .current_player(connect4_player),
        .exp(connect4_exp)
    );
     
    wire [3:0] an_game_connect4;
    wire [7:0] seg_game_connect4;
     
    seven_seg_connect4 u_player_display (
        .clk(clk),
        .connect4_player(connect4_player),
        .an(an_game_connect4),
        .seg(seg_game_connect4)
    );

    // XP calculation
    wire [7:0] game_xp_coin, game_xp_flappy;
    coin_xp xp_calc_coin (.score(score), .exp(game_xp_coin));
    coin_xp xp_calc_flappy (.score(flap_score), .exp(game_xp_flappy));

    // Level system
    wire [3:0] level;
    wire level_up_pulse;

    exp_controller #(.MAX_LEVEL(3), .START_LEVEL(1)) u_exp (
        .clk(clk),
        .dead(dead),
        .xp_wrap_pulse(xp_wrap_pulse),
        .pet_reset_pulse(pet_reset_pulse),
        .level(level),
        .level_up_pulse(level_up_pulse)
    );

    // LED warning
    wire [15:0] led_normal;
    led_warning u_led_warn (
        .clk(clk),
        .hunger(hunger),
        .happiness(happiness),
        .dead(dead),
        .level(level),
        .level_up_pulse(level_up_pulse),
        .led(led_normal)
    );

    // Segment displays
    wire [7:0] seg_normal;
    wire [3:0] an_normal;
    segment_display u_seg (
        .clk(clk),
        .dead(dead),
        .level(level),
        .seg(seg_normal),
        .an(an_normal)
    );

    wire [7:0] seg_game_coin;
    wire [3:0] an_game_coin;
    
    sevenseg_game u_game7seg (
        .clk100(clk),
        .score(score),
        .time_s(time_s),
        .game_over(game_over_snake),
        .an(an_game_coin),
        .seg(seg_game_coin)
    );

    wire [7:0] seg_game_flappy;
    wire [3:0] an_game_flappy;
    
    sevenseg_flappy u_flap7seg (
        .clk100(clk),
        .score(flap_score),
        .game_over(flap_game_over),
        .an(an_game_flappy),
        .seg(seg_game_flappy)
    );

    // OLED JB - Game display
    wire fb_game, send_game, samp_game;
    wire [15:0] pix_idle, pix_menu, pix_collect, pix_flappy, pix_game_mux;

    // Pass jump_offset to idle_scene
    idle_scene u_idle (
        .clk(clk),
        .dead(dead),
        .x(x_game),
        .y(y_game),
        .jump_offset(pet_jump_offset),
        .pixel(pix_idle)
    );
    
    game_menu u_menu (
        .x(x_game),
        .y(y_game),
        .pixel(pix_menu)
    );
    
    collect_render render_collect (
        .clk(clk),
        .pixel_index(pix_idx_game),
        .player_x(player_x),
        .player_y(player_y),
        .coin_x(coin_x),
        .coin_y(coin_y),
        .game_over(game_over_snake),
        .pixel_rgb(pix_collect)
    );

    flappy_render render_flap (
        .pixel_index(pix_idx_game),
        .bird_y(bird_y), 
        .pipe_x(pipe_x),
        .gap_y(gap_y), 
        .game_over(flap_game_over),
        .pixel_rgb(pix_flappy)
    );

    // Base scene selection (without cursor)
    wire [15:0] pix_base_scene;
    assign pix_base_scene =
        (!game_mode)                       ? pix_idle :
        (game_mode && game_sel == 3'b000)  ? pix_menu :
        (enable_coin)                      ? pix_collect :
        (enable_flappy)                    ? pix_flappy :
        (enable_connect4)                  ? pix_connect4 :
                                             16'h0000;
    
    // Overlay cursor on top of base scene (WHITE cursor)
    assign pix_game_mux = is_cursor ? 16'h8410 : pix_base_scene;

    Oled_Display oled_game (
        .clk(clk6p25),
        .reset(1'b0),
        .frame_begin(fb_game),
        .sending_pixels(send_game),
        .sample_pixel(samp_game),
        .pixel_index(pix_idx_game),
        .pixel_data(pix_game_mux),
        .cs(JB[0]), .sdin(JB[1]), .sclk(JB[3]),
        .d_cn(JB[4]), .resn(JB[5]),
        .vccen(JB[6]), .pmoden(JB[7])
    );

    // OLED JA - Pet status
    wire fb_pet, send_pet, samp_pet;
    wire [12:0] pix_idx_pet;
    wire [15:0] pix_pet;

    oled_renderer render_pet (
        .clk(clk),
        .game_mode(in_game),
        .feed_mode(feed_mode_raw & ~dead),
        .x(95 - pix_idx_pet % 96),
        .y(63 - pix_idx_pet / 96),
        .hunger(hunger),
        .xp(xp),
        .happiness(happiness),
        .food_select_out(food_select_wire),
        .hunger_bar_length(hunger_bar_length),
        .xp_bar_length(xp_bar_length),
        .happiness_bar_length(happiness_bar_length),
        .btnL_active(btnL_active),
        .btnC_active(btnC_active),
        .btnR_active(btnR_active),
        .dead(dead),
        .oled_data(pix_pet)
    );

    Oled_Display oled_pet (
        .clk(clk6p25),
        .reset(1'b0),
        .frame_begin(fb_pet),
        .sending_pixels(send_pet),
        .sample_pixel(samp_pet),
        .pixel_index(pix_idx_pet),
        .pixel_data(pix_pet),
        .cs(JA[0]), .sdin(JA[1]), .sclk(JA[3]), .d_cn(JA[4]),
        .resn(JA[5]), .vccen(JA[6]), .pmoden(JA[7])
    );

    // Output multiplexers
    assign led = in_game ? 16'h0000 : led_normal;
    
    assign seg = (enable_coin)     ? seg_game_coin     :
                 (enable_flappy)   ? seg_game_flappy   :
                 (enable_connect4) ? seg_game_connect4 :
                                     seg_normal;
    
    assign an  = (enable_coin)     ? an_game_coin     :
                 (enable_flappy)   ? an_game_flappy   :
                 (enable_connect4) ? an_game_connect4 :
                                     an_normal;
                                   
endmodule