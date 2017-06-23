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

scope playVictoryTheme: {
  get_CharInfo:
            jal   getCharInfoPtr
            or    a0, r0, v0
  play_theme:
            jal   fn.ssb.playBGM
            lbu   a0, data.CharInfo.theme_bgm(v0)
  return:
            b     0x80138820            // built-in epilogue
            nop

  // empty the built-in routine
  nopUntilPC(0x80138820, "victory themes replacement")
}

pullvar pc

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included victory-theme.asm\n"
}
