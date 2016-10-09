//bass-n64
//==========================
//---Hacks Loader Code
//==========================

// requires:
// "LIB/N64defs.inc", libultra routines, ssbFuncs

// any hacks you want to copy
//  -> Hacks need to expose a .RAM, .ROM, and .SIZE bass values

origin 0x00042F10
base 0x800A41C0
// alt
// origin 0x0003BB20
// base 0x8003AF20

Hacks_Table:
include "dma-hacks-table.bass"

// Inputs
// a0: Hack Index to be DMA'd
scope hacks_loader: {
  nonLeafStackSize(1)       // Grab space for 1 word on stack

  subiu sp, sp, {StackSize}
  sw    ra, 0x0014(sp)
  sw    s0, 0x0018(sp)

  // convert hack index into array offset
  // i*3*4
  sll   at, a0, 2           // hack index * 4
  sll   a0, a0, 3           // hack index * 8
  addu  a0, at, a0          // 4i + 8i = 12i

  // set up aurguments to call ssb.managedDMA
  li    at, Hacks_Table     // get base offset of hacks file info table
  add   s0, at, a0          // base + hack offset
  lw    a0, 0x0000(s0)      // load ROM src into a0
  lw    a1, 0x0004(s0)      // load RAM dest into a1
  jal   fn.ssb.managedDMA
  lw    a2, 0x0008(s0)      // load size into a2

  // invalidate instruction cache
  lw    a0, 0x0004(s0)      // load RAM addr
  jal   fn.libultra.osInvalICache
  lw    a1, 0x0008(s0)      // load size

  // epilogue
  lw    ra, 0x0014(sp)
  lw    s0, 0x0018(sp)
  jr    ra
  addiu sp, sp, {StackSize}
}

//make into it's own file, and include the table, loader, etc.
// Original Code at ROM 0x139420
// 0x8013B1A0: JAL  0x8013A2A4
scope CSS_load_wrapper: {
  nonLeafStackSize(0)

  subiu sp, sp, {StackSize}
  sw    ra, 0x0014(sp)
  jal   hacks_loader      // DMA our code for the CSS
  ori   a0, r0, 0x0       // index for CSS codes is 0x0

  //initialize the altstate array for holding the players' AltState enum
  jal   DMA.CSS.initAltState
  nop

  // just jump to the original target, with the proper RA  and stack
  lw    ra, 0x0014(sp)
  j     0x8013A2A4
  addiu sp, sp, {StackSize}
}

scope Results_load_wrapper: {
  nonLeafStackSize(0)

  subiu sp, sp, {StackSize}
  sw    ra, 0x0014(sp)
  jal   hacks_loader
  ori   a0, r0, 0x1       // Results Screen = 0x1

  // jump to original target of "hooked" code
  lw    ra, 0x0014(sp)
  j     0x800FD300
  addiu sp, sp, {StackSize}
}

// Add size warning checks!
if pc() >= 0x800A43B0 {
  print "DMA Loader Overflow!\n"
  print "Current PC: 0x"; printHex(pc()); print "\n"
  print "Max PC 0x800A43B0\n"
  error "Aborting assembly ): !!"
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included dma-loader.asm\n\n"
}
