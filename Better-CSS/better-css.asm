//bass-n64

arch n64.cpu
endian msb

// bass macros
include "LIB/macros.bass"

// N64 ASM helpers
include "LIB/N64defs.inc"

// built-in routines
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

// Unlock Everything  [bit]
origin 0x042B3B
base 0x8000A3DE8
dl 0x7F0C90

// Hacks "based at" the CSS
scope CSS {
  // code that needs to be DMA'd
  scope DMA {
    // Set beginning origin and base
    origin 0x00F5F500
    base 0x80392A00
    // other pc addresses:
    // 0x8038F000
    // 0x80392A00

    // Save begining offset/base for DMA-ing the code once on the css
    constant ROM(origin())
    constant RAM(pc())
    // size is calculated after all includes
    variable SIZE(0)

    // --- Code to be DMA'd
    include "src/color-cycle/css_color-cycle.asm"
    align(4)
    include "src/alt-characters/css_alt-characters.asm"
    align(4)
    // --- End Code to be DMA'd

    // get total size of DMA in bytes
    variable SIZE(origin()-ROM)

    // --- Print out info on DMA stuff
    // Verbose Print info [-d v on cli]
    if {defined v} {
      print "CSS DMA Parameters:\n"
      printDMAInfo(ROM, RAM, SIZE)
    }
  }

  // hooks into our code
  scope hooks {
    // Verbose Print info [-d v on cli]
    if {defined v} {
      print "Generating CSS hooks: \n\n"
    }

    // color cycle hook
    include "src/color-cycle/cc-hook.asm"
    // d-pad handler hook (combine to big hooks file once all other hooks are done)
    include "src/alt-characters/hooks/hook_dpad-handler.asm"
    // b-button deselect character handler: resets alt-state when deselecting
    include "src/alt-characters/hooks/hook_b-deselect-handler.asm"
    // close panel to reset alt-char state hook
    include "src/alt-characters/hooks/hook_close-panel-reset.asm"
    // when a player's token is picked up, reset that player's alt-char state
    include "src/alt-characters/hooks/hook_pick-up-token.asm"
    // change character index based on alt-state when going to SSS
    include "src/alt-characters/hooks/hook_update-character.asm"
    // Going from SSS back to CSS, restore legal character and perserve alt-state
    include "src/alt-characters/hooks/hook_restore-char-css.asm"
  }

  //replacements for built-in routines or simple, "built-in" hacks
  scope replacements {
    // Verbose Print info [-d v on cli]
    if {defined v} {
      print "\nGenerating In-Place Replacement CSS Code: \n\n"
    }

    // big alteration of a built-in routine
    include "src/alt-characters/reps/replace_cssPalletChange.asm"
    // on results screen, replace an illegal character value with a legal one
    include "src/alt-characters/reps/replace_result-screen-char-change.asm"
  }
}

// insert the hack file loader
// this is in constantly loaded memory space
// -> right now: inserted over old debug strings
scope loader {
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
