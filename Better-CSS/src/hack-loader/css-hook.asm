//bass-n64

// hook into the init routine of the CSS to go
// Original Code at ROM 0x139420
// 0x8013B1A0: JAL  0x8013A2A4
// so, we're just replacing that JAL with our own JAL
origin 0x139420
base 0x8013B1A0
scope load_hook: {
  jal loader.CSS_load_wrapper
  nop
}

print "Included css-hook.asm!\n\n"
