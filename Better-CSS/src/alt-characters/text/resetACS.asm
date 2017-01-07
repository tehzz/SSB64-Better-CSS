//bass-n64
//=== resetACS ==================================
// One-stop routine to set a player's ACS to NONE
// and update that player's character display BG pallet
//--Inputs-----------------------------
// a0 : u32 player
//--Output-----------------------------
// void
//---Register Map-----------------
//
//--------------------------------

scope resetACS: {
  nonLeafStackSize(0)

  // prologue
            subiu sp, sp, {StackSize}
            sw    ra, 0x0014(sp)
            sw    a0, {StackSize} + 0 (sp)
  // get ACS.NONE
            jal   getNoneACS
            nop
  // set player a0's ACS to NONE
            lw    a0, {StackSize} + 0 (sp)
            jal   setACS
            or    a1, r0, v0
  // reset character diplay background
            jal   wrapUpdatePallet
            lw    a0, {StackSize} + 0 (sp)
  // epilogue
            lw    ra, 0x0014(sp)
            jr    ra
            addiu sp, sp, {StackSize}
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included resetACS.asm \n"
}
