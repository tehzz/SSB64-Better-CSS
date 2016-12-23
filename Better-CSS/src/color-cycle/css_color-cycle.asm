//bass-n64
// Include under the CSS DMA section in main file.
// This allows for Z/R cycling of colors and L cycling of shade
//---DMA'd Data and Routine------------
evaluate assembledSize(origin())

//=--.data-----------------------------
align(4)
scope data {
  include "data/color-max.bass"
}
//--end .data section-------------

//---.text-----------------------------
align(4)
scope text {
  // Hooks button handler to cycle on Z/R and L
  include "text/cycle-colors.asm"
}
//---end .text-------------------------

// Verbose Print info [-d v on cli]
evaluate assembledSize(origin() - {assembledSize})
if {defined v} {
  print "\nSuccessfully compiled css_color-cycle.asm\n"
  print "Compiled Size: 0x"; printHex({assembledSize}); print " bytes\n\n"
}
