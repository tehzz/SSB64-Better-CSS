//bass-n64
//===hackLoader Routine==========================
// This DMA's the code described by the input
// hackEnum
//
//--Input Params-----------------------
// a0 : hackEnum
//--Return Values----------------------
// void
//--Register Map-----------------------
// s0 <- &hackstruct
//--Stack Map--------------------------
// + 0x14 : ra
// + 0x18 : input s0
//-------------------------------------

scope hackLoader: {
  nonLeafStackSize(1)

  // prologue
            subiu sp, sp, {StackSize}
            sw    ra, 0x0014(sp)
            sw    s0, 0x0018(sp)

  // convert hackEnum into array offset (i*4 + i*8 + base)
  // maybe replace with "mult" of struct.sizeof ?
  //    Same number of instructions, more flexible but slower...
            sll   at, a0, 2           // hack index * 4
            sll   a0, a0, 3           // hack index * 8
            addu  a0, at, a0          // 4i + 8i = 12i
            la    at, data.hacks.array
            add   s0, at, a0          // base + hack offset
  // update top of heap to prevent custom data from being overwritten
            jal   heapStealer
            lw    a0, data.hacks.struct.RAMaddr(s0)
  // DMA data from ROM into RAM
            lw    a0, data.hacks.struct.ROMaddr(s0)
            lw    a1, data.hacks.struct.RAMaddr(s0)
            jal   fn.ssb.managedDMA
            lw    a2, data.hacks.struct.Size(s0)
  // invalidate instruction cache
            lw    a0, data.hacks.struct.RAMaddr(s0)
            jal   fn.libultra.osInvalICache
            lw    a1, data.hacks.struct.Size(s0)

  // epilogue
            lw    ra, 0x0014(sp)
            lw    s0, 0x0018(sp)
            jr    ra
            addiu sp, sp, {StackSize}
}

//===heapStealer Routine=========================
// Check if the input RAM address is within the "heap" area.
// If so, reduce the top of the heap to the input RAM address to prevent
// allocation and writing-over of DMA'd code.
//
//--Input Params-----------------------
// a0 : u32 RAMaddr
//--Return Values----------------------
// v0 : bool heapChanged
//--Register Map-----------------------
// t0 : pointer to heap info RAM addresses
// t1 : u32 heap upper limit
// t2 : u32 heap current lower limit
//-------------------------------------

scope heapStealer: {
  // "Heap" means the area of RAM where SSB can dynamically
  // allocate resource files or build structures.
  // State info is in these RAM addresses:
  constant heapInfo(0x800465E8)
  // +0: unknown;  +4: initial heap floor
  // +8: heap top; +C: current heap floor

  // get upper limit and current lower limit of heap
            la    t0, heapInfo
            lw    t1, 0x0008(t0)      // upper limit
            lw    t2, 0x000C(t0)      // lower limit
  // check if a0 is within heap
            slt   v0, a0, t1          // a = RAMaddr < heap.top
            slt   v1, t2, a0          // b = RAMaddr >= heap.bottom
            and   v0, v0, v1          // if( a && b ) heap.top = RAMaddr
            bnezl v0, return
  // update top of heap (only if v0 != false)
            sw    a0, 0x0008(t0)
  return:
            jr    ra
            nop
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included hack-loader.asm\n"
}
