//bass-n64
// This file should be included in the DMA section of the hack loader.
// This expands the results screen to work with all characters

//grab current origin for DMA size calcs
evaluate assembledSize(origin())

//---.data------------------------
align(4)
scope data {
  include "data/char-info-array.bass"
}
//---end .data--------------------

//---.text------------------------
align(4)
scope text {
  // Load only the <=4 characters used in a battle
  include "text/load-chars.asm"
  // Have variable sized array for winning character logo
  include "text/more-char-logos.asm"
  // expand victory theme array for all characters
  include "text/victory-theme.asm"
  // announce character name for all characters
  include "text/announce-winner.asm"
  // expand zoom factor array for all characters
  include "text/model-zoom-floats.asm"
  // winning character string
  include "text/write-winner-str.asm"
  // victory and chapping animation
  include "text/model-animation.asm"
  // Fix player (p1, cp, etc) indicator arrow positions
  include "text/indicator-offsets.asm"
  // draw the generic stock icon for polygons to prevent console crash
  include "text/generic-stock-icon.asm"
  // don't save VS Record data for characters > 0xB
  include "text/limit-saved-data.asm"
  // utility routine to index data from CharInfoArray
  include "text/getCharInfoPtr.asm"
}
//---end .text--------------------

// Verbose Print info [-d v on cli]
evaluate assembledSize(origin() - {assembledSize})
if {defined v} {
  print "\nSuccessfully compiled results-more-chars.asm!\n"
  print "Compiled Size: 0x"; printHex({assembledSize})
  print " bytes\n\n"
}
