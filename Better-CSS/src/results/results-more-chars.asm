//bass-n64
// This file should be included in the DMA section of our hack

//---.data------------------------
scope data {

}
//---end .data--------------------

//---.text------------------------
// Load only the <=4 characters used in a battle
include "dma/load-chars.asm"

//---end .text--------------------

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included results-more-chars.asm!\n\n"
}
