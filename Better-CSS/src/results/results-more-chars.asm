//bass-n64
// This file should be included in the DMA section of our hack

//---.data------------------------
scope data {
include "data/char-logo-data.bass"
include "data/char-bgm.bass"
include "data/char-fgm.bass"
include "data/char-zoom.bass"
include "data/char-strings.bass"
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
// expand victory theme array for all characters
include "text/announce-winner.asm"
// expand zoom factor array for all characters
include "text/model-zoom-floats.asm"
// winning character string
include "text/write-winner-str.asm"

// victory and chapping animation

// player (p1, cp, etc) arrow positions?
}
//---end .text--------------------

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included results-more-chars.asm!\n\n"
}
