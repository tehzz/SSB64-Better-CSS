//bass-n64

arch n64.cpu
endian msb

//---Rouintes, macros, defines, etc----
//---------------------------
// bass macros
include "LIB/macros.bass"
// N64 ASM defines/macros
include "LIB/N64defs.inc"
// Callable, On-ROM SSB64 routines
include "LIB/ssb/routines.inc"
//---------------------------
//---End Routines, Defines, etc.-------

// insert SSB U big-endian rom
origin 0x0
insert "ROM/Super Smash Bros. (U) [!].z64"

// Unlock Everything  [bit]
origin 0x042B3B
base 0x8000A3DE8
dl 0x7F0C90

//---DMA'd Routines------------------------------
//- These routines need to be moved into
// active RAM. The files have both the
// code to be DMA'd and hooks from active
// routines to that code
//---------------------------

scope DMA {
  // set initial ROM base for free space
  origin 0x00F5F500

  //---Code DMA'd into RAM on CSS-------
  scope CSS {
    // set RAM base for DMA'd CSS
    // and save ROM, RAM, and SIZE for DMA Loader
    base 0x80392A00   // <-- change away from frame buffers/steal from heap

    constant ROM(origin())
    constant RAM(pc())
    variable SIZE(0)

    //---Code to be DMA'd:
    // Note: The ASM files include the DMA'd routine,
    // and the hook to that routine from the natural code flow
    include "src/color-cycle/css_color-cycle.asm"
    align(4)
    include "src/alt-characters/css_alt-characters.asm"
    align(4)
    //---End Code to Be DMA'd

    // update SIZE variable
    variable SIZE(origin()-ROM)
    // --- Print out info on DMA stuff
    // Verbose Print info [-d v on cli]
    if {defined v} {
      print "CSS DMA Parameters:\n"
      printDMAInfo(ROM, RAM, SIZE)
    }
  }

  //---Code DMA'd into RAM on Results Screen-------
  scope Results {
    // set base for DMA routine for Results Screen
    // and save ROM, RAM, and SIZE for DMA Loader
    base 0x8038F000

    constant ROM(origin())
    constant RAM(pc())
    variable SIZE(0)

    //--Code to be DMA'd----------
    align(4)
    include "src/results/results-more-chars.asm"
    //--End DMA'd Code------------

    // update SIZE variable
    variable SIZE(origin()-ROM)

    // Error if PC reachs 0x80392A00
    // Warn if PC is within 0x200
    errorOnAddr(pc(), 0x80392A00, "Results DMA Size", 0x200)

    // Verbose Print info [-d v on cli]
    if {defined v} {
      print "Reults Screen DMA Parameters:\n"
      printDMAInfo(ROM, RAM, SIZE)
    }
  }
}

scope loader {
  // insert the hack file loader in constantly loaded memory space
  // -> right now: inserted over old debug strings
  // Verbose Print info [-d v on cli]
  if {defined v} {
    print "\nGenerating DMA hack loader code: \n\n"
  }

  include "src/hack-loader/dma-loader.asm"
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "\nBetter-CSS Compiled! \n\n"
}
