//bass-n64

// This hooks into the button handler and checks for D-PAD inputs
// to allow us to switch characters

//---Hook----------------------------------------
// Original Lines
// 80138310 addu  t8, t6, t7      -> Button Pointer
// 80138314 sw    t8, 0x0024(sp)  -> Save on stack
// 80138318 lhu   t9, 0x0002(t8)  -> Get Unique Button Press
// ..310 and ..314 are replaced in custom code

pushvar pc

{
  origin 0x136590
  base 0x80138310
            jal   dpad_alt_char_state
            addu  t8, t6, t7      // Original Line 1
}

pullvar pc

//---End Hook------------------------------------

scope dpad_alt_char_state: {
  nonLeafStackSize(4)

  replacement:
  // replacement instructions from hooking into this routine
            sw    t8, 0x0024(sp)      // Save Pointer to Button State
  check_dpad_state:
  // if there are no d-pad presses, we don't need to do anything
            lhu   t0, 0x0002(t8)        // unique press button state
            andi  t0, t0, 0x0F00        // Check for any D-PAD button
            beq   t0, r0, return        // if no d-pad press, exit
            nop

  prologue:
  // save arguments b/c they might be important for actual code
            sw    a0, 0x0000(sp)
            sw    a1, 0x0004(sp)      // Note: a1 = player index
            sw    a2, 0x0008(sp)
            sw    a3, 0x000C(sp)
            ori   at, sp, 0           // save old sp in at to move to s8/fp

            subiu sp, sp, {StackSize}   // get new stack
            sw    ra, 0x0014(sp)
            sw    s0, 0x0018(sp)
            sw    s1, 0x001C(sp)
            sw    s8, 0x0020(sp)
            sw    s2, 0x0024(sp)
            or    fp, r0, at          // fp is s8
  check_char_selected:
  // start multiplying the player index by 0xBC
            ori   at, r0, 0xBC
            multu a1, at              // Player Index * BC
            lui   s0, 0x8013
            ori   s0, s0, 0xBA88
            mflo  at                  // Grab Player Index * 0xBC
            addu  s0, at, s0          // full player struct pointer
            lw    at, 0x0080(s0)      // character selected?
            beq   at, r0, epilogue    // if not selected, go to epilogue
            lw    s1, 0x0048(s0)      // BD; grab character index

  // D-PAD Checks. D-PAD Left or Right
  dpad_rl:
  // return character to normal
            andi  at, t0, 0x0300      // Left | Right 0x200 | 0x100
            beq   at, r0, dpad_up     // if (l or r) continue

            lui   a0, 0x8013          // branch delay
            ori   a0, a0, 0xB800      // load character name FGM base pointer
            sll   at, s1, 1           // character index * 2
            addu  a0, a0, at          // offset pointer by character
            lhu   a0, 0x0000(a0)      // load character name FGM value
            beq   r0, r0, update_state
            ori   t1, r0, AltState.NONE
  dpad_up:
  // polygon version
            andi  at, t0, 0x0800
            beq   at, r0, dpad_down   // if not UP, d-pad value must be DOWN

            ori   a0, r0, FGM.FPT     // FGM = "FIGHT POLYGON TEAM"
            beq   r0, r0, update_state
            ori   t1, r0, AltState.POLYGON

  // don't need to check against 0x0400, as it has to be this
  // set Metal Mario or Giant DK if applicable
  dpad_down: {
    MM_check:
            bne   s1, r0, DK_check      // if not Mario, check for DK

            ori   a0, r0, FGM.MM        // BD; set FGM to  "METAL MARIO!"
            beq   r0, r0, update_state
            ori   t1, r0, AltState.MM

    DK_check:
            ori   at, r0, 0x0002
            bne   s1, at, epilogue      // if not DK, don't change anything

            ori   a0, r0, FGM.GDK       // BD; set FGM to "Giant Donkey Kong"
            beq   r0, r0, update_state
            ori   t1, r0, AltState.GDK
  }
  update_state:
  // First, check if we need to update state...
            la    s2, acs.baseAddr    // load alt_char_state address
            addu  s2, s2, a1          // offset by player
            lbu   t2, 0x0000(s2)      // current alt_char_state
            beq   t1, t2, epilogue    // if current state = state to set
            nop                       // do nothing, else
  // play FGM to announce char state
            jal   fn.ssb.playFGM
            sb    t1, 0x0000(s2)      // set alt-char-state byte for this player
  // Prepare to call css.updatePlayerPanelPallet
            lw    a0, 0x0018(s0)      // needed, unknown pointer from player struct
  // check for team mode
  // if it is team mode, don't use player index for a1
  // use a "specialized" team index for a1 [00: red team; 01: blue; 03 green]
  if_teams:
            lui   t1, 0x8014
            lw    t1, 0xBDA8(t1)      // team mode int (0 Off | 1 On)
            beqz  t1, endif_teams_else  // if (team mode){ ...
            la    t1, 0x8013B7D8      // teams_pallet_indicies.array
            lw    at, 0x0040(s0)      // current_team
            sll   at, at, 0x2         // current_team * 4
            addu  t1, at, t1          // a1 = t_p_i[current_team]
            b     end_else            //
            lw    a1, 0x0000(t1)      // } else {
  endif_teams_else:                   //
            lw    a1, 0x0004(fp)      //    reload player index
  end_else:                           // }
            jal   fn.css.updatePlayerPanelPallet
            lw    a2, 0x0084(s0)        // MAN | CPU | Closed: lw a2, 0x84(s0)

  epilogue:
          lw    ra, 0x0014(sp)
          lw    s0, 0x0018(sp)
          lw    s1, 0x001C(sp)
          lw    s8, 0x0020(sp)
          lw    s2, 0x0024(sp)
          addiu sp, sp, {StackSize}   // free our stack
          lw    a0, 0x0000(sp)        // reload a0-3
          lw    a1, 0x0004(sp)
          lw    a2, 0x0008(sp)
          lw    a3, 0x000C(sp)
  return:
          jr    ra
          lw    t8, 0x0024(sp)        // Restore t8 for original code
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included dpad-handler.asm\n"
}
