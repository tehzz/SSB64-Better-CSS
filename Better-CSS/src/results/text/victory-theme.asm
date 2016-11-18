//bass-n64
//=========================================================
//---Victory Themes for All Characters---------------------
//
// Replace the jump table with an array for the
// victory themes for the characters
//=========================================================

// Info
// Routine starts at 0x80138714. 0x14 in stack space.
// At 8013872C, the winning character is loaded into v0
// 80138820 is the epilogue (reload RA, sp++ etc.)

// Register Map
// t0 : char_bmg.length
//      char_bmg base
// a0 : 0x0
// a1 : BGM index


pushvar pc
origin 0x1578CC
base 0x8013872C

scope victoryThemes {
  // make sure that the character is in the array
  range_check:
            ori   t0, r0, data.char_bgm.length
            sltu  at, v0, t0
            bnez  at, in_range
            nop
            b     play_theme
            ori   a1, r0, data.char_bgm.default
  in_range:
            li    t0, data.char_bgm
            addu  a1, t0, v0
            lbu   a1, 0x0000(a1)        // char_bgm[character]
  play_theme:
            jal   fn.ssb.playBGM
            or    a0, r0, r0
            b     0x80138820            // built-in epilogue
            nop

  while pc() < 0x80138820 {
    // empty the built-in routine
    nop
  }
}

pullvar pc

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included victory-theme.asm\n"
}
