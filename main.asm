//bass-n64

arch n64.cpu
endian msb

// N64 ASM helpers
include "LIB/N64defs.inc"
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

// insert SSB U big-endian rom
// can this be done with CLI?
origin 0x0
insert "ROM/Super Smash Bros. (U) [!].z64"

// Unlock Everything  [bit]
origin 0x042B3B
base 0x8000A3DE8
dl 0x7F0C90

// include the big routine for cycling colors
scope color_cycle {
  include "src/css_colorChange.asm"
}

// insert the hack file loader
// this also has the wrapper for loading color toggle
scope loader {
  include "src/ssb_hack-loader.asm"
}


//------hooks
// loader hook into the init routine of the CSS
origin 0x139420
base 0x8013B1A0
scope load_hook: {
  jal loader.CT_load_wrapper
  nop
}
// color toggle hook
scope CT_hook: {
  // grab space to allow for a JAL
  // during the FFA c-button handler
  origin 0x136890
  base 0x80138610
  beql  t7, r0, ct_jump

  origin 0x1368B0
  base 0x80138630
  beql  t8, r0, ct_jump

  // the jump to our loaded cycle colors routine
  origin 0x001368C0
  base 0x80138640
  ct_jump:
  jal   color_cycle.cycleColors
  nop
}

// wrappers should probably be in css_colorChange.asm..
// hook needs to go after loader...
