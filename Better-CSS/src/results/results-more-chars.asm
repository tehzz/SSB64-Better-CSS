//bass-n64
// This file should be included in the DMA section of our hack

//---.data------------------------
scope data {
include "dma/char-logo-data.bass"
include "dma/char-bgm.bass"
}
//---end .data--------------------

//---.text------------------------
scope text {
  align(4)
// Load only the <=4 characters used in a battle
include "dma/load-chars.asm"
// Have variable sized array for winning character logo
include "dma/more-char-logos.asm"
// victory theme
include "dma/victory-theme.asm"

// winning character FGM

// character model zoom

// winning character string

// victory and chapping animation
}
//---end .text--------------------

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included results-more-chars.asm!\n\n"
}
