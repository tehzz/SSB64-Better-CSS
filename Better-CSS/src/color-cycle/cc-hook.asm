//bass-n64
// Color Cycle Hooks

scope CC_hook: {
  // grab space to allow for a JAL
  // during the FFA c-button handler
  origin 0x136890
  base 0x80138610
  beql  t7, r0, cc_jump

  origin 0x1368B0
  base 0x80138630
  beql  t8, r0, cc_jump

  // the jump to our DMA'd cycle colors routine
  origin 0x001368C0
  base 0x80138640
  cc_jump:
  jal   CSS.DMA.cycle_colors
  nop
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included cc-hook.asm for color change hack\n"
}
