//bass-n64
//=========================================================
//---Model Victory and Clapping Animations-----------------
//
// Load different animations for victory and clapping so
// other characters don't crash the game
//=========================================================

//---Hook getWinningAnimation----------
// Original routine is from 0x8013345C to
// 0x801334C8. Returns one animation from a set of
// either 3 or 2 (kirby) animations
pushvar pc

origin 0x1525FC
base 0x8013345C

scope winAni_hook {
  nonLeafStackSize(0)

  // jump out to DMA'd code
            subiu sp, sp, {StackSize}
            sw    ra, 0x0014(sp)
            jal   winningAnimation
            nop
            lw    ra, 0x0014(sp)
            addiu sp, sp, {StackSize}
            jr    ra
            nop
  // nop the remainder of the on-ROM routine
  while pc() <= 0x801334C8 {
    nop
  }
}
pullvar pc
//---end hook--------------------------

//===getWinningAnimation func==========
//--inputs---------
// a0 : char index
//--reg map--------
// s0 : *Victory
// t0 : victory animation index array length
// t1 : length - 1
//--outputs-------
// v0 : animation index
//----------------

scope winningAnimation: {
  nonLeafStackSize(1)
  prologue:
            subiu sp, sp, {StackSize}
            sw    ra, 0x0014(sp)
            sw    s0, 0x0018(sp)
  get_CharInfo:
            jal   getCharInfoPtr
            nop
  get_Victory_struct:
            lw    s0, data.CharInfo.ani_wins(v0)
  get_random_offset:
  // get random offset if Victory.length > 1
            lw    t0, data.Victory.length(s0)
            subi  t1, t0, 0x1         // len = Victory.length - 1
            beqz  t1, return_animation  // if ( len - 1 < 1) return 0
            or    v0, r0, r0
  // else { getRandomInt(len) }
            jal   fn.ssb.getRandomInt
            or    a0, r0, t0
  return_animation:
            sll   v0, v0, 0x2
            addu  v0, s0, v0
            lw    v0, data.Victory.array(v0)   // Victory.array[ani_index]
  epilogue:
            lw    ra, 0x0014(sp)
            lw    s0, 0x0018(sp)
            jr    ra
            addiu sp, sp, {StackSize}
}
//---End getWinningAnimation code------

//---Hook getClappingAnimation----
// Original, "full" routine:
// 801334CC  lui   v0, 0x0001
//       D0  sw    a0, 0x0000(sp)
//       D4  jr    ra
//       D8  ori   v0, 0x0005
//----------------------------
pushvar pc

origin 0x15266C
base 0x801334CC

scope getClappingAnimation: {
  //just jump to where we have more space
            j     expandClap
            sw    a0, 0x0000(sp)    // original instruction, use unknown...
  return:
            jr    ra
            nop
}

pullvar pc
//--End Hook----------------------

//=====expandClap======================
//---Inputs------------------
// a0 : u32 char index
//---Outputs-----------------
// v0 : u32 losting animation index
//---Register Map------------

scope expandClap: {
  nonLeafStackSize(0)
  prologue:
            subiu sp, sp, {StackSize}
            sw    ra, 0x014(sp)
  get_CharInfo:
            jal   getCharInfoPtr
            nop
  deref_losing_animation:
            lw    ra, 0x014(sp)
            lw    v0, data.CharInfo.ani_clap(v0)
  return:
            j     getClappingAnimation.return
            addiu sp, sp, {StackSize}
}


// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included model-animation.asm\n"
}
