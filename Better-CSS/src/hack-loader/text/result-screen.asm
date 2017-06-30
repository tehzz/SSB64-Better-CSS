//bass-n64
//===CSS DMA Hook and Wrapper====================

//---Hook------------------------------
// Call our wrapper routine for DMA'ing code
// on the results screen
//
//---Original Code-----------
// ROM 0x157DE4
// 0x80138C44   jal   0x800FD300
//              nop
//---------------------------

pushvar pc
{
  origin 0x157DE4
  base 0x80138C44

            jal   Results_load_wrapper
            nop
}
pullvar pc

//---End Hook--------------------------

//---Wrapper Routine-------------------
// This just wraps the call to hackLoader to call it with proper CSS
// enum and inits the global Alt-Char-State addresses

scope Results_load_wrapper: {
  nonLeafStackSize(0)
  // prologue
            subiu sp, sp, {StackSize}
            sw    ra, 0x0014(sp)
  // DMA Result Screen specific code and daat
            jal   hackLoader
            ori   a0, r0, data.hacks.enum.Results

  // Pseudo-epilogue
  // Jump to the original target, with the proper RA and stack
            lw    ra, 0x0014(sp)
            j     0x800FD300
            addiu sp, sp, {StackSize}
}


// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included result-screen.asm\n"
}
