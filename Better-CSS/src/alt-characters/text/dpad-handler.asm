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

// General Map
// Check for DPAD input
// Check for selectingCharacter
  // if true -> goto button checks
  // if false -> check for active character
    // if( !character selected ) goto return

//--Register Map------------------
// s0 : u16 button newly pressed (& 0x0F00; mask for dpad)
// s1 : u32 pointer to player CSS struct
// s2 : u32 player index (of player to have acs set)
// s3 : s32 held token of player (-1 == No Held Token )
//      u32 character index
//--Stack Map---------------------

scope dpad_alt_char_state: {
  nonLeafStackSize(4)
  constant CSS_playerData(0x8013BA88)

  replacement:
  // replacement instructions from hooking into this routine
            sw    t8, 0x0024(sp)      // Save Pointer to Button State
  check_dpad_state:
  // if there are no d-pad presses, we don't need to do anything
            lhu   t0, 0x0002(t8)      // unique press button state
            andi  t0, t0, 0x0F00      // Check for any D-PAD button
            beq   t0, r0, return      // if no d-pad press, exit
            nop

  prologue:
  // save arguments b/c they might be important for actual code
            sw    a0, 0x0000(sp)
            sw    a1, 0x0004(sp)      // Note: a1 = player index
            sw    a2, 0x0008(sp)
            sw    a3, 0x000C(sp)
            subiu sp, sp, {StackSize}   // get new stack
            sw    ra, 0x0014(sp)
            sw    s0, 0x0018(sp)
            sw    s1, 0x001C(sp)
            sw    s2, 0x0020(sp)
            sw    s3, 0x0024(sp)

  // Save button state and generate pointer current player css data struct
            ori   at, r0, 0xBC
            multu a1, at              // Player Index * 0xBC
            or    s0, r0, t0          // save DPAD button state
            or    s2, a1, r0          // save player index (for whose controller is being handled)
            la    s1, CSS_playerData
            mflo  at
            addu  s1, at, s1          // pointer to current player's css data struct
  // Save held token value
            lw    s3, 0x0080(s1)
  // Select Characer with DPAD if possible
            lw    a0, 0x0000(s1)      // Needed pointer
            or    a1, r0, s2          // player index
            or    a2, r0, s3          // player token held by current player
            jal   fn.css.selectCharConditional
            ori   a3, r0, 0x4         // use first available color

  // Branch based on return
  // If a character was selected by the routine, it could be for any player
  // If not, the dpad input can only be used for the button-pressing player
            beqz  v0, char_cant_select
            nop
  char_selected:
  // generate new CSS_playerData pointer for held token player
            or    s2, r0, s3          // update player index to refer to held token's player
            ori   at, r0, 0xBC
            multu at, s2
            la    s1, CSS_playerData  // update pointer to CSS_playerData[player]
            mflo  at
            addu  s1, at, s1
            b     dpad_rl_check
            lw    s3, 0x0048(s1)      // char index for held token's player

  char_cant_select:
  // ensure that the player pressing the DPad has a selected character
            lw    at, 0x0088(s1)      // bool charSelected (second of its kind in struct..?)
            beqz  at, epilogue        // if (!selected) exit
            lw    s3, 0x0048(s1)      // char index for button-handled player

  // D-PAD Checks. D-PAD Left or Right
  dpad_rl_check:
  // return character to normal
            andi  at, s0, 0x0300      // (Left | Right) (0x200 | 0x100)
            beqz  at, dpad_up         // if (l or r)
            nop

            jal   getNoneACS
            nop
            b     update_state
            or    a1, v0, r0          // setup for call to setACS
  dpad_up:
  // polygon version
            andi  at, s0, 0x0800
            beqz  at, dpad_down       // if not UP, d-pad value must be DOWN
            nop

            jal   getPolygonACS
            or    a0, r0, s3
            b     update_state
            or    a1, v0, r0          // setup for call to setACS
  dpad_down:
  // special, alternative version
  // don't need to check against 0x0400, as all other options are accounted for
            jal   getSpecialACS
            or    a0, r0, s3
            or    a1, v0, r0

  update_state:
            or    a0, r0, s2
            jal   setACSandAnnounce
            or    a2, r0, s3

  epilogue:
          lw    ra, 0x0014(sp)
          lw    s0, 0x0018(sp)
          lw    s1, 0x001C(sp)
          lw    s2, 0x0020(sp)
          lw    s3, 0x0024(sp)
          addiu sp, sp, {StackSize}   // free stack
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
