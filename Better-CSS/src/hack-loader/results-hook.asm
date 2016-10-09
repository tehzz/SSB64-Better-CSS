//bass-n64
//---Results Screen DMA Hook----------
// Call our wrapper routine for DMA'ing code
// on the results screen
//
//---Original Code-----------
// ROM 0x157DE4
// 0x80138C44   jal   0x800FD300
//              nop
//---------------------------

origin 0x157DE4
base 0x80138C44
{
  jal   loader.Results_load_wrapper
  nop
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included results-hook.asm for dma hack loader\n"
}
