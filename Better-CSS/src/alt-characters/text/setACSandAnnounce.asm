//bass-n64
//=== setACSandAnnounce =========================
// Routine sets player a0's alt-char-state to a1,
// updates the player panel pallet, and announces
// the character's name (taking the ACS into account)
//--Inputs-----------------------------
// a0 : u32 player
// a1 : u8  ACSenum
// a2 : u32 character
//--Output-----------------------------
// v0 : bool ACS updated?
//---Register Map-----------------
//
//--------------------------------

scope setACSandAnnounce: {
  nonLeafStackSize(0)

  // prologue
            subiu sp, sp, {StackSize}
            sw    ra, 0x0014(sp)
  // store input arguments on caller's stack
            sw    a0, {StackSize} + 0 (sp)
            sw    a1, {StackSize} + 4 (sp)
  // get player a0's current ACS [getACS(player)]
            jal   getACS
            sw    a2, {StackSize} + 8 (sp)
  // Compare to the input ACS; if same, do nothing and return FALSE
            lw    a1, {StackSize} + 4 (sp)
            beql  a1, v0, epilogue
            or    v0, r0, r0          // return FALSE

  // call setACS(player, ACSenum)
            jal   setACS
            lw    a0, {StackSize} + 0 (sp)
  // wrapUpdatePallet(player)
            jal   wrapUpdatePallet
            lw    a0, {StackSize} + 0 (sp)
  // getCharFGM(player, character) and play the returned FGM index
            lw    a0, {StackSize} + 0 (sp)
            jal   getCharFGM
            lw    a1, {StackSize} + 8 (sp)

            jal   fn.ssb.playFGM
            or    a0, r0, v0

            ori   v0, r0, 0x1         // return TRUE
  epilogue:
            lw    ra, 0x0014(sp)
            jr    ra
            addiu sp, sp, {StackSize}
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included setACSandAnnounce.asm\n"
}
