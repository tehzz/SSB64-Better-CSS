//bass-n64
//=== Reset ACS when Closing the Character Display Panel ==
// When a player panel at the bottom of the screen is closed,
// reset the alt-char-state
//
//---Begin Hook------------------------
// Original Code:
// jal    ssb.playFGM
// addiu  a0, r0, 0x00A7
//---------------------------
// Hook that JAL to our replacment routine that can reset the alt-char-state,
// and then play that soundfx

pushvar pc
origin 0x1349BC
base 0x8013673C

scope hook_close_panel {
  jal   closePanelResetState
  or    a0, r0, s1            // move player index to a0, since a0 is free
}
pullvar pc

//---End Hook--------------------------

// void closePanelResetState( uint player-index )
// a0 : player index
//-------------------
// Register Map
//-------------------
// a0 : player index [input]
//      -> soundfx for playFGM
scope closePanelResetState: {
  nonLeafStackSize(0)

  // prologue
            subiu sp, sp, {StackSize}
            sw    ra, 0x0014(sp)
  // Set alt-state to NONE
            jal   resetACS
            nop                     // a0 is already player index
  // Hooked Code Replacement
            jal   fn.ssb.playFGM       // replacement for hook-in code
            ori   a0, r0, 0x00A7
  // epilogue
            lw    ra, 0x0014(sp)
            jr    ra
            addiu sp, sp, {StackSize}
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included close-panel-reset.asm\n"
}
