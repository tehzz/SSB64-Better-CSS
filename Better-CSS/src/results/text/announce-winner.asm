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

// Register Map
// t0 : char_fgm.length
//      char_fgm base
// a0 : winning character
//      win char FGM

scope playWinningFGM: {
  nonLeafStackSize(0)
  prologue:
            subiu sp, sp, {StackSize}
            sw    ra, 0x0014(sp)
  check_length:
            ori   t0, r0, data.char_fgm.length
            sltu  at, a0, t0
            bnez  at, in_range
            nop
            b     play_name
            ori   a0, r0, data.char_fgm.default
  in_range:
            li    t0, data.char_fgm
            sll   at, a0, 1           // array is half-words
            addu  a0, t0, at
            lhu   a0, 0x0000(a0)      // a0 = char_fgm[char]
  play_name:
            jal   fn.ssb.playFGM
            nop
  epilogue:
            lw    ra, 0x0014(sp)
            jr    ra
            addiu sp, sp, {StackSize}
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included announce-winner.asm\n"
}
