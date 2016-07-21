//bass-n64

//Hacks Loader Code

// arch n64.cpu
// endian msb
// requires (from main file; put in otherwise)
// "LIB/N64defs.inc"
// libultra routines
// ssbFuncs
// any hacks you want to copy
//  -> Hacks need to expose a .RAM, .ROM, and .SIZE bass values

// alt
origin 0x00042F10
base 0x800A41C0
//original, does this cause the crash?
// origin 0x0003BB20
// base 0x8003AF20
// make this its own include?
Hacks_Table:
// Color_Toggle Data: 0x0
dd color_cycle.ROM, color_cycle.RAM, color_cycle.SIZE
align(4)

// Inputs
// a0: Hack Index to be DMA'd
scope hacks_loader: {
   // ssb.managedDMA uses two more words than it should
   // 2 reg + 0x8 = 0x10; start at 0x8
  subiu sp, sp, 0x10
  sw    ra, 0x0008(sp)
  sw    s0, 0x000C(sp)
  // convert hack index into array offset
  // i*3*4
  sll   at, a0, 2           // hack index * 4
  sll   a0, a0, 3           // hack index * 8
  addu  a0, at, a0          // 4i + 8i = 12i
  // set up aurguments to call ssb.managedDMA
  li    at, Hacks_Table     // get base offset of table for hacks file info
  //pseudo-instruction
  add   s0, at, a0          // base + hack offset
  lw    a0, 0x0000(s0)      // load ROM src into a0
  lw    a1, 0x0004(s0)      // load RAM dest into a1
  jal   ssb.managedDMA
  lw    a2, 0x0008(s0)      // load size into a2
  // invalidate instruction cache
  lw    a0, 0x0004(s0)      // load RAM addr
  jal   libultra.osInvalICache
  lw    a1, 0x0008(s0)      // load size
  // return
  lw    ra, 0x0008(sp)
  jr    ra
  addiu sp, sp, 0x10
}

//make into it's own file, and include the table, loader, etc.
// ROM 0x139420
// 0x8013B1A0: JAL  0x8013A2A4
scope CT_load_wrapper: {
  subiu sp, sp, 0x0008
  sw    ra, 0x0000(sp)
  jal   hacks_loader
  ori   a0, r0, 0x0
  lw    ra, 0x0000(sp)
  j     0x8013A2A4
  addiu sp, sp, 0x0008
  // just jump to the original target, with the proper RA  and stack
}

print "Included ssb_hack-loader.asm\n\n"
