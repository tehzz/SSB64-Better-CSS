//bass-n64

arch n64.cpu
endian msb

//---Rouintes, macros, defines, etc----
//---------------------------
// bass macros
include "LIB/macros.bass"
// N64 ASM defines/macros
include "LIB/N64defs.inc"
// On ROM SSB64 routines
scope fn {
  // libultra routines
  scope libultra {
    include "LIB/ssbLibUltra.inc"
  }
  // "universal" routines in SSB
  scope ssb {
    include "LIB/ssbFuncs.inc"
  }
  // routintes on the Character Select Screen
  scope css {
    include "LIB/cssFuncs.inc"
  }
}

// insert SSB U big-endian rom
origin 0x0
insert "ROM/Super Smash Bros. (U) [!].z64"
//---------------------------
//---End Routines, Defines, etc.-------


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
  // set initial ROM base
  origin 0x00F5F500

  //---Code for CSS Only-------
  scope CSS {
    // set RAM base for DMA'd CSS
    // and save ROM, RAM, and SIZE for DMA Loader
    base 0x80392A00   // <-- change away from frame buffers/steal from heap

    constant ROM(origin())
    constant RAM(pc())
    variable SIZE(0)

    print "Origin and Pc Location before DMA: \n"
    print "0x"; printHex(origin()); print "\n"
    print "0x"; printHex(pc()); print "\n"

    //---Code to be DMA'd:
    // Note: The ASM files include the DMA'd routine,
    // and the hook to that routine from the natural code flow
    include "src/color-cycle/css_color-cycle.asm"
    align(4)
    include "src/alt-characters/css_alt-characters.asm"
    align(4)
    //---End Code to Be DMA'd
    print "Origin and Pc Location after DMA: \n"
    print "0x"; printHex(origin()); print "\n"
    print "0x"; printHex(pc()); print "\n"

    // update our SIZE variable
    variable SIZE(origin()-ROM)
    // --- Print out info on DMA stuff
    // Verbose Print info [-d v on cli]
    if {defined v} {
      print "CSS DMA Parameters:\n"
      printDMAInfo(ROM, RAM, SIZE)
    }
  }
  scope Results {
    // for the results screen DMA'd code
  }
}

scope Replacement_Routines {
  // These codes are entirely contained within active rouintes. No part of
  // the routine is DMA'd. Normally, these are in-situ replacements of an
  // exisiting routine to better support the hack.

  scope CSS {
    // Verbose Print info [-d v on cli]
    if {defined v} {
      print "\nGenerating In-Place Replacement CSS Code: \n\n"
    }

    // big alteration of a built-in routine that changes the player bg image pallet
    include "src/alt-characters/reps/replace_cssPalletChange.asm"
  }
  scope Results {
    // Verbose Print info [-d v on cli]
    if {defined v} {
      print "\nGenerating In-Place Replacement Results Screen Code: \n\n"
    }

    // on results screen, replace an illegal character value with a legal one
    include "src/alt-characters/reps/replace_result-screen-char-change.asm"
  }
}

scope loader {
  // insert the hack file loader
  // this is in constantly loaded memory space
  // -> right now: inserted over old debug strings
  // Verbose Print info [-d v on cli]
  if {defined v} {
    print "\nGenerating DMA hack loader code: \n\n"
  }

  include "src/hack-loader/dma-loader.asm"
  scope hooks {
    include "src/hack-loader/css-hook.asm"
  }
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "\nBetter-CSS Compiled! \n\n"
}
