//bass-n64

// This hooks into the beginning of the b-button routine to pick-up a
// character token. It just resets the alt-char-state

//---Begin Hook----------------------------------
// include description here!
// include original code!!
pushvar pc

origin 0x136278
base 0x80137FF8
scope hook_b_button_deselect {
  nonLeafStackSize(0)

  subiu sp, sp, {StackSize}
  sw    ra, 0x0014(sp)
  jal   b_reset_state
  nop
  lw    ra, 0x0014(sp)
  addiu sp, sp, {StackSize}

  // oversize warning
  if ( origin() >  0x136294) {
    evaluate overBy(origin() - 0x136294)
    print "Routine needs to end at 0x1315F4, \nbut instead ended at 0x"
    printHex(origin()); print "\nOver-sized by {overBy} bytes\n"
    error "B-Button Deselect Hook is too large!\n"
  } else {
    // nop the rest of the original routine
    while (origin() <= 0x136294) {
      dw 0x00000000
    }
  }
}

pullvar pc
//---End Hook------------------------------------

scope b_reset_state: {
  nonLeafStackSize(1)         // Grab space for 0 saved reg on stack

  prologue:
  ori   at, r0, 0xBC
  multu a0, at
  sw    a0, 0x0000(sp)
  subiu sp, sp, {StackSize}
  sw    ra, 0x0014(sp)
  //replacement insructions to generate *Player_Struct
  li    t0, 0x8013BA88
  mflo  at
  addu  t0, at, t0

  reset_state:
  jal   DMA.CSS.resetAltState   // a0 is already player index
  sw    t0, 0x0018(sp)      // store pointer now; grab in epilogue

  epilogue:
  lw    v0, 0x0018(sp)      // put *Player_Struct in v0, as it's expected there
  lw    ra, 0x0014(sp)
  addiu sp, sp, {StackSize}
  jr    ra
  lw    a0, 0x0000(sp)      // a0 is expected to be unchanged
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included b-pick-up-handler.asm\n"
}
