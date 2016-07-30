//bass-n64

// This file hooks into the button handler code on the CSS
// and redirects to the D-PAD handler that sets alt-char-state

// Original Lines
// 80138310 addu  t8, t6, t7      -> Button Pointer
// 80138314 sw    t8, 0x0024(sp)  -> Save on stack
// 80138318 lhu   t9, 0x0002(t8)  -> Get Unique Button Press
// ..310 and ..314 are replaced in custom code

origin 0x136590
base 0x80138310

jal   CSS.DMA.dpad_alt_char_state
addu  t8, t6, t7      // Original Line 1


//----------------------------------
print "Included hook_dpad-handler.asm"
