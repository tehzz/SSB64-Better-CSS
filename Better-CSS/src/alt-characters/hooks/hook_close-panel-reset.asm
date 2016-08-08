//bass-n64
//---------------------------
// When a player panel at the bottom of the screen is closed,
// reset the alt-char-state

// Original Code:
// jal    ssb.playFGM
// addiu  a0, r0, 0x00A7
//---------------------------
// Hook that JAL to our replacment routine that can reset the alt-char-state,
// and then play that soundfx

origin 0x1349BC
base 0x8013673C

scope hook_close_panel {
  jal   CSS.DMA.closePanelResetState
  or    a0, r0, s1            // move player index to a0, since a0 is free
}

//---------------------------
// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included hook_close-panel-reset.asm\n"
}
