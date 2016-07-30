//bass-n64
//========================================
//-----Hack Info
//========================================

// requires
// "LIB/N64defs.inc", bass macros, ssbFuncs, cssFuncs

//grab size
variable SIZE(origin())

scope custom_pallets: {
  align(8)
  polygon:
    dw 0x0000, 0x1009, 0x3013, 0x501F
    dw 0x6025, 0x78EB, 0xFFFF, 0xFFFF
    align(8)
  polygon_cpu:
    dw 0x0000, 0x6B1B, 0x7B61, 0x8BA5
    dw 0x93E9, 0xA46D, 0xFFFF, 0xFFFF
    align(8)
  gdk:
    dw 0x0000, 0x3905, 0x4987, 0x7249
    dw 0x9B0D, 0xCCCD, 0xFFFF, 0xFFFF
    align(8)
  gdk_cpu:
    dw 0x0000, 0x6B17, 0x7B59, 0x941B
    dw 0xAC9F, 0xCDA1, 0xFFFF, 0xFFFF
    align(8)
  mm:
    dw 0x0000, 0x4211, 0x739D, 0xA529
    dw 0xC631, 0xEF7B, 0xFFFF, 0xFFFF
    align(8)
  mm_cpu:
    dw 0x0000, 0x94A5, 0xB5AD, 0xCE73
    dw 0xDEF7, 0xF7BD, 0xFFFF, 0xFFFF
    align(8)
  array:
    dd polygon, polygon_cpu, gdk, gdk_cpu, mm, mm_cpu
    align(4)
}

// the state for each player 0-3
// 1 byte each
alt_char_state: {
  db 0, 0, 0, 0
  align(4)
}
// enum of alt character values
scope AltState {
  constant NONE(0x0)
  constant POLYGON(0x1)
  constant GDK(0x2)
  constant MM(0x4)
}

// FGM Values for a0 for playFGM call
// Regular Character name will just use the built-in table
scope FGM {
  constant MM(0x1CE)
  constant GDK(0x1E9)
  constant FPT(0x1E2)
}

// Use D-PAD to change alt character state
scope dpad_alt_char_state: {
  // return a {StackSize} for stack size in bytes
  nonLeafStackSize(3)         //Standard MIPS Non-Leaf + 3 registers

  replacement:
  // replacement instructions from hooking into this routine
  sw    t8, 0x0024(sp)        // Save Pointer to Button State
  check_dpad_state:
  // if there are no d-pad presses, we don't need to do anything
  lhu   t0, 0x0002(t8)        // unique press button state
  andi  t0, t0, 0x0F00        // Check for any D-PAD button
  beq   t0, r0, return        // if no d-pad press, exit
  nop

  prologue:
  // save arguments b/c they might be important for actual code
  sw    a0, 0x0000(sp)
  sw    a1, 0x0004(sp)        // Note: This is player index
  sw    a2, 0x0008(sp)
  sw    a3, 0x000C(sp)
  ori   at, sp, 0             // save old sp in at to move to s8/fp

  subiu sp, sp, {StackSize}   // get new stack space
  sw    ra, 0x0014(sp)
  sw    s0, 0x0018(sp)
  sw    s1, 0x001C(sp)
  sw    s8, 0x0020(sp)
  or    fp, r0, at            // fp is s8

  check_char_selected:
  // start multiplying the player index by 0xBC
  ori   at, r0, 0xBC
  multu a1, at                // Player Index * BC
  lui   s0, 0x8013
  ori   s0, s0, 0xBA88
  mflo  at                    // Grab Player Index * 0xBC
  addu  s0, at, s0            // full player struct pointer
  lw    at, 0x0080(s0)        // character selected?
  beq   at, r0, epilogue      // if not selected, go to epilogue
  nop
  lw    s1, 0x0048(s0)        // grab character index

  // D-PAD Checks. D-PAD Left or Right
  dpad_rl:
  // return character to normal
  andi  at, t0, 0x0300
  beq   at, r0, dpad_up
  nop
  lui   a0, 0x8013
  ori   a0, a0, 0xB800        // load character name FGM base pointer
  sll   at, s1, 1             // character index * 2
  addu  a0, a0, at            // offset pointer by character
  jal   fn.ssb.playFGM
  lhu   a0, 0x0000(a0)        // load character name FGM value

  beq   r0, r0, update_state
  ori   t1, r0, AltState.NONE

  dpad_up:
  // polygon version
  andi  at, t0, 0x0800
  beq   at, r0, dpad_down     // if not UP, go check DOWN
  nop
  jal   fn.ssb.playFGM        // play "FIGTING POLYGON TEAM!" from 1p mode
  ori   a0, r0, FGM.FPT

  beq   r0, r0, update_state  // set alt-char-state to polygon
  ori   t1, r0, AltState.POLYGON

  // don't need to check against 0x0400, as it has to be this
  // set Metal Mario or Giant DK if applicable
  dpad_down: {
    MM_check:
    bne   s1, r0, DK_check    // if not Mario, check for DK
    ori   at, r0, 0x0002

    jal   fn.ssb.playFGM      // play "METAL MARIO!"
    ori   a0, r0, FGM.MM
    beq   r0, r0, update_state
    ori   t1, r0, AltState.MM

    DK_check:
    bne   s1, at, epilogue    // if not DK, don't change anything
    nop

    jal   fn.ssb.playFGM
    ori   a0, r0, FGM.GDK
    beq   r0, r0, update_state
    ori   t1, r0, AltState.GDK
  }

  update_state:
  lw   a1, 0x0004(fp)         // reload player index
  li   t2, alt_char_state     // load alt_char_state address
      //pseudo-instruction
  addu t2, t2, a1             // offset by player
  sb   t1, 0x0000(t2)         // set alt-char-state byte for this player
  // call pallet change routine?
  lw   a0, 0x0018(s0)
  jal  fn.css.updatePlayerPanelPallet
  ori  a2, r0, 0x1
  // a0 = 0x18(s0)
  // a1 = player index 0x4(fp)
  // a2 = Pallet Normal CPU or None (load)

  epilogue:
  lw    ra, 0x0014(sp)
  lw    s0, 0x0018(sp)
  lw    s1, 0x001C(sp)
  lw    s8, 0x0020(sp)
  addiu sp, sp, {StackSize}   // get new stack space

  lw    a0, 0x0000(sp)
  lw    a1, 0x0004(sp)
  lw    a2, 0x0008(sp)
  lw    a3, 0x000C(sp)
  lw    t8, 0x0024(sp)        // Restore t8 for original code

  return:
  jr    ra
  nop
}

//calc new size
variable SIZE(origin() - SIZE)

print "Included css_alt-chara.asm\n"
print "Compiled Size: "
print SIZE
print " bytes\n\n"
