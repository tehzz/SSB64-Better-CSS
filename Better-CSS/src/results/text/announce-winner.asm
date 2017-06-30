//bass-n64
//=========================================================
//---Announce Winning Character in FFA---------------------
//
// Extend the array to include all characters
//=========================================================

//---Hook--------------------
// Have 4 instructions starting at 80131FC4
// winning character is in v0
pushvar pc

origin 0x151164
base 0x80131FC4
{
            jal   playWinningFGM
            or    a0, r0, v0
            nop
            nop
}

pullvar pc
//--end hook-----------------

//--- void playWinningFGM(character) -------------------------------------------
// input
//  a0 = u32 character_index
//------------------------------------------------
// Register Map
// t0 : u32 *CharInfo input character
// a0 : u32 winning character
//      u16 character name FGM index

scope playWinningFGM: {
  nonLeafStackSize(0)
  prologue:
            subiu sp, sp, {StackSize}
            sw    ra, 0x0014(sp)
  get_CharInfo:
            jal   getCharInfoPtr
            nop
  play_name:
            jal   fn.ssb.playFGM
            lhu   a0, data.CharInfo.name_fgm(v0)
  epilogue:
            lw    ra, 0x0014(sp)
            jr    ra
            addiu sp, sp, {StackSize}
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included announce-winner.asm\n"
}
