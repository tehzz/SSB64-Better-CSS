//bass-n64
//===getCharFGM===============================
// return the FGM index that corresponds to a
// character's name (if applicable)
//--Inputs-----------------------------
// a0 : u32 player index
// a1 : u32 char index
//--Output-----------------------------
// v0 : u16 FGM index

//---Pseudo-code-----------------------
// u16 FGM
// switch( ACSenum ) {
//    case acs.NONE    : FGM = standardCharFGMs[charIndex]; break
//    case acs.POLYGON : FGM = FGM.FPT; break
//    case acs.MM      : FGM = FGM.MM; break
//    default          : FGM = FGM.GDK
// }
// return FGM

scope getCharFGM: {
  // For standard 12, there is already a built in u16 array
  constant standardCharFGMs(0x8013B800)
  nonLeafStackSize(0)

  // prologue
            subiu sp, sp, {StackSize}
            sw    ra, 0x0014(sp)
  // grab the ACS for player a0
            jal   getACS
            sw    a1, {StackSize} + 4(sp)   // save char index
  // Begin Switch
  // CASE acs.NONE
            ori   t0, r0, AltState.NONE
            bne   v0, t0, Polygon_check
  // NONE : Statement
            lw    a1, {StackSize} + 4(sp)   // restore char index
            la    v0, standardCharFGMs
            sll   t0, a1, 1
            addu  v0, t0, v0
            b     return
            lhu   v0, 0x0000(v0)
  Polygon_check:
  // CASE acs.POLYGON
            ori   t0, r0, AltState.POLYGON
            bne   v0, t0, MetalMario_check
            ori   t0, r0, AltState.MM
  // POLYGON : Statement
            b     return
            ori   v0, r0, FGM.FPT
  MetalMario_check:
  // CASE acs.MM
            bne   v0, t0, GiantDK_check
            ori   t0, r0, AltState.GDK
  // MM : Statement
            b     return
            ori   v0, r0, FGM.MM
  GiantDK_check:
  // CASE DEFAULT : Statement
  // Right now, no real check since it's the last character
            ori   v0, r0, FGM.GDK
  return:
            lw    ra, 0x0014(sp)
            jr    ra
            addiu sp, sp, {StackSize}
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included getCharFGM.asm \n"
}
