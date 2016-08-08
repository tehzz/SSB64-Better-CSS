//bass-n64
//---------------------------
// When starting a game/going to the SSS
// change a player's character based on the alt-char-state

// Original Code:
// At 0x8013AAB0:
// jal   0x8013A8B8
// sw    t7, 0xBDA4(at)
//---------------------------
// Hook that JAL to our replacement routine
// No inputs into that routine, or into our own

origin 0x138D30
base 0x8013AAB0
scope change_character {
  jal   CSS.DMA.changeCharIndex
}

//---------------------------
// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included hook_update-character.asm\n"
}
