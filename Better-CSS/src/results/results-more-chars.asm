//bass-n64
// This file should be included in the DMA section of our hack

//---.data------------------------
scope data {
include "dma/char-logo-data.bass"
include "dma/char-bgm.bass"
include "dma/char-fgm.bass"
include "dma/char-zoom.bass"
include "dma/char-strings.bass"
}
//---end .data--------------------

//---.text------------------------
align(4)
scope text {
// Load only the <=4 characters used in a battle
include "dma/load-chars.asm"
// Have variable sized array for winning character logo
include "dma/more-char-logos.asm"
// expand victory theme array for all characters
include "dma/victory-theme.asm"
// expand victory theme array for all characters
include "dma/announce-winner.asm"
// expand zoom factor array for all characters
include "dma/model-zoom-floats.asm"
// winning character string
include "dma/write-winner-str.asm"

// victory and chapping animation

// player (p1, cp, etc) arrow positions?
}
//---end .text--------------------

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included results-more-chars.asm!\n\n"
}
