//bass-n64
//===CSS DMA Hook and Wrapper====================

//---Hook------------------------------
// hook into the init routine of the CSS to go
// Original Code at ROM 0x139420:
//    0x8013B1A0: JAL  0x8013A2A4
// Replace original JAL target with CSS_load_wrapper

pushvar pc

{
  origin 0x139420
  base 0x8013B1A0

            jal CSS_load_wrapper
            nop
}

pullvar pc

//---End Hook--------------------------

//---Wrapper Routine-------------------
// This just wraps the call to hackLoader to call it with proper CSS
// enum and inits the global Alt-Char-State addresses

scope CSS_load_wrapper: {
  nonLeafStackSize(0)
  // prologue
            subiu sp, sp, {StackSize}
            sw    ra, 0x0014(sp)
  // DMA CSS specific code and data
            jal   hackLoader
            ori   a0, r0, data.hacks.enum.CSS
  // initialize the altstate array for holding the players' AltState enum
            jal   DMA.CSS.text.initAltState
            nop

  // Pseudo-epilogue
  // Jump to the original target, with the proper RA and stack
            lw    ra, 0x0014(sp)
            j     0x8013A2A4
            addiu sp, sp, {StackSize}
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included css.asm\n"
}
