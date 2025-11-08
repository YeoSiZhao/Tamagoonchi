# Tamagoonchi – Interactive FPGA Virtual Pet  

## Overview  
**Tamagoonchi** is an interactive digital pet system designed for the **Basys-3 FPGA board**, developed under **NUS EE2026 (Digital Design)**.  
It combines real-time state management, sprite animation, and interactive feedback through dual OLED displays, buttons, LEDs, and the 7-segment display.  
Players maintain their pet’s **Hunger**, **Happiness**, and **Experience** levels by feeding it and playing built-in mini-games.

---

## System Architecture  

| Component | Function |
|------------|-----------|
| **Left OLED (JA)** | Displays the pet’s current status (Idle, Feed, or Dead). Shows animated icons, stat bars, and hunger/happiness feedback. |
| **Right OLED (JB)** | Hosts interactive mini-games such as *Flappy Mushroom*, *Mushroom Mania*, and *Connect 4*. Also detects wired USB mouse input for in-game interactions. |
| **7-Segment Display** | Continuously shows the pet’s current **Level**. Displays **“DEAD”** when the pet dies. |
| **LED Array [15:0]** | Provides visual warnings and level-up effects. |
| **Switches (SW)** | Select modes and mini-games. |
| **Buttons (btnL, btnC, btnR, btnU, btnD)** | Used for feeding, navigation, and game control. |

---

## Visual and Interactive Feedback  

### 7-Segment Display  
- Displays **Level** in both Idle and Feed modes.  
- Displays **“DEAD”** when Hunger or Happiness reaches zero.  

### LED Indicators `[15:0]`  
- Blink at **2 Hz** when either Hunger or Happiness ≤ 20%.  
- Blink at **5 Hz** when either Hunger or Happiness ≤ 10%.  
- Perform a **level-up animation** when XP bar fills completely.  

### Mouse Input (Right OLED)  
- Mouse coordinates (0–4095) are mapped to OLED coordinates (x: 0–95, y: 0–63) with clamping.  
- When the cursor nears the pet and the left button is clicked, the pet performs a **jump animation** and **Happiness increases**.  

---

## Game and Mode Selection  

| Mode | Switch | Description |
|-------|---------|-------------|
| **Feed Mode** | `SW[0] = 1` | Scroll foods using `btnL` / `btnR`, feed using `btnC`. |
| **Game Mode** | `SW[1] = 1` | Select mini-game via upper switches: `SW[15]` – Connect 4, `SW[14]` – Flappy Bird, `SW[13]` – Mushroom Mania. |
| **Idle Mode** | `SW[1] = 0` | Default state where the pet wanders and displays status bars. |

---

## Core Pet Mechanics  

### Hunger / Happiness / XP Bars  
Displayed on the **left OLED** with icons:  
- 🍖 Ham-shank → Hunger  
- ✨ XP → Experience  
- 🙂 Smiley → Happiness  

Each bar changes color dynamically:  
- **Green** > 66%  
- **Yellow** 33–66%  
- **Red** < 33%  

---

### Feeding System (Feed Mode)  
Use `btnL` / `btnR` to scroll through foods and `btnC` to feed the pet.  

| Food | Hunger Restored |
|-------|------------------|
| 🍕 Pizza | +40 |
| 🍔 Burger | +25 |
| 🍎 Apple | +10 |

The selected food is shown on the OLED via sprite icons.  

---

### Hunger Logic  
Each time a mini-game is exited, **10 points** are deducted from Hunger regardless of time spent or score achieved.  

---

### XP System  
When returning from a game to idle or select mode, XP is awarded as follows:  

| Game | XP Gain |
|-------|---------|
| **Connect 4** | 40 XP (win), 10 XP (draw/loss), none if incomplete |
| **Flappy Bird / Mushroom Mania** | 10 base + 3 XP per point scored |

When XP bar reaches max value:  
- XP resets to 0 (plus rollover if applicable).  
- Pet **levels up** on the 7-segment display.  
- LEDs trigger a **level-up animation**.  

---

### Dead State  
If **Hunger = 0** or **Happiness = 0**, all three bars turn red and movement stops.  
To revive: set all switches off (`SW[15:0] = 0`) and press `btnC` to return to **Level 1**.  

---

## Mini-Games  

### 1. Connect 4  
Two-player turn-based FSM:  
- `btnC`: start game.  
- Player 1 = Red, Player 2 = Yellow.  
- `btnL` / `btnR`: move selector.  
- `btnC`: drop token.  
- 7-segment alternates “P1” / “P2” to indicate turns.  
- “YOU WIN” / “YOU LOSE” displayed on OLED when finished.  

---

### 2. Mushroom Mania (Simplified Snake)  
- FSM: Idle → Game → End.  
- `btnC`: global reset.  
- From idle, press any other button to start.  
- Movement: direction buttons (debounced).  
- 7-segment displays **score** and **15-second timer**.  
- Game ends when timer expires or player hits border.  
- “GAME OVER” shown on OLED; 7-seg blinks ≈ 3 Hz.  
- Final score contributes to XP bar.  

---

### 3. Flappy-Mushroom  
FSM: Idle → Game → End.  
- `btnU`: jump (debounced pulse).  
- `btnC`: global reset.  
- 7-segment shows score.  
- Collision triggers End state; score is added to XP.  

---

## Idle and Death Animations  
- **Idle Mode:** Pet moves horizontally, flipping direction when reaching screen edges.  
- **Dead Mode:** Pet stops moving; all bars remain red until revived.  

---

## LED and Display Synchronization  

| Event | Feedback |
|--------|-----------|
| Hunger/Happiness ≤ 20 % | LEDs blink 2 Hz |
| Hunger/Happiness ≤ 10 % | LEDs blink 5 Hz |
| Level-up | Sequential LED wave animation |
| Death | LEDs solid red |

---

## Revival Sequence  
When the pet dies:  
1. Set all switches **off** (`SW[15:0] = 0`).  
2. Press `btnC`.  
3. Pet revives at **Level 1** with reset stats.  

---

## Development Notes  
- Implemented in **Verilog HDL** using **Xilinx Vivado** for the **Basys-3 FPGA**.  
- Clock dividers reduce 100 MHz input to 6.25 MHz for OLED timing.  
- All buttons are **debounced** using edge detectors.  
- OLEDs communicate via **SPI** interface.  
- FSMs and sprite renderers handle transitions and animations.  

---

## License  
Developed for **educational use** under the **NUS EE2026** course.  
All sprites and logic are original student creations. Redistribution allowed for non-commercial academic purposes with credit to the authors.  

---

## Credits  

**Team S1-07**  
- Wang Chuhao – Game and Happiness Logic Engineer  
- Zhang Yize – Graphics and Animation Engineer  
- Rishabh Ramprasad Shenoy – System Integration and Display Logic  
- Yeo Si Zhao – Hardware Testing and LED/7-Segment Control  

---

## Demonstration  
*(Add screenshots or demo video links here when available)*  

---

**Tamagoonchi** – Because every FPGA deserves a friend.
