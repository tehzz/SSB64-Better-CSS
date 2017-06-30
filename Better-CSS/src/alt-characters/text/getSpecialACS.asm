//bass-n64
//===getSpecialACS===============================
// return the proper alt-char-state (acs) enum
// for a given character's special ACS (if there is one)
//--Inputs-----------------------------
// a0 : u32 char index
//--Output-----------------------------
// v0 : ACSenum variable
//--Register Map------------------
// t0 <- comparison character indexes
//-----------------------------------------------

scope getSpecialACS: {
  // check for Mario
            ori   t0, r0, 0x0000      // Mario index
            bne   a0, t0, DK_check
            ori   t0, r0, 0x0002      // DK index
            b     return
            ori   v0, r0, AltState.MM
  // check for DK
  DK_check:
            bne   a0, t0, none
            ori   v0, r0, AltState.GDK
            b     return
            nop
  // No special ACS; return NONE?
  none:
            ori   v0, r0, AltState.NONE
  return:
            jr    ra
            nop
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included getSpecialACS.asm \n"
}
