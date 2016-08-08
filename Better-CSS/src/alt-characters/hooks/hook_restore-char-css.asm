//bass-n64
//---------------------------
// This simples to jumps to another routine that
// has can hanlde illegal (>0xB) character values before
// the game crashes with them
//---------------------------
// Original Code
// At 8013ACC4
// sw   r0, 0x001C(v0)
// sw   r0, 0x0020(v0)
//-----------------
// Replace the first sw with a j

origin 0x138F44
base 0x8013ACC4
scope restore_char_CSS: {
  jump:
  j   CSS.DMA.restore_legal_char_CSS
}

//---------------------------
// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included hook_restore-char-css.asm\n"
}
