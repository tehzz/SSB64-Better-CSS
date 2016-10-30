//bass-n64
// This file should be included in the DMA section of our hack

//---.data------------------------
scope data {
include "dma/char-logo-data.bass"
}
//---end .data--------------------

//---.text------------------------
scope text {
// Load only the <=4 characters used in a battle
include "dma/load-chars.asm"
// Have variable sized array for winning character logo
include "dma/more-char-logos.asm"

// victory theme

// winning character FGM

// winning character string

// victory and chapping animation
}
//---end .text--------------------

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included results-more-chars.asm!\n\n"
}
