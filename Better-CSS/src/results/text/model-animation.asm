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
// s0 : &animate.victory.char
//      &struct animate.victory.char[index]
// t0 : victory animation index array length
// t1 : length - 1
//--outputs-------
// v0 : animation index
//----------------

scope winningAnimation: {
  nonLeafStackSize(1)
  //prologue
            subiu sp, sp, {StackSize}
            sw    ra, 0x0014(sp)
            sw    s0, 0x0018(sp)
  // grab character's pointer to animation index struct
            sll   t0, a0, 0x2
      lwAddr(s0, data.animate.victory.char, t0)
  // check length, get randomInt if necessary
            lw    t0, 0x0000(s0)
            subiu t1, t0, 0x1
            beqz  t1, return_ani
            or    v0, r0, t1
  // get random int to select victory animation
            jal   fn.ssb.getRandomInt
            or    a0, r0, t0
  return_ani:
  // retun an animation index
            sll   t0, v0, 0x2         // v0 is either 0 or randomInt
            addu  s0, s0, t0
            lw    v0, 0x0004(s0)
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
            jr    ra
            nop
}

pullvar pc
//--End Hook----------------------

//=====expandClap======================
//---Inputs------------------
// a0 : char index
//---Register Map------------

scope expandClap: {
  // get value
            sll   t0, a0, 0x2
        lwAddr(v0, data.animate.clap, t0)
  // return:
            j     getClappingAnimation + 0x8
            nop
}


// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included model-animation.asm\n"
}
