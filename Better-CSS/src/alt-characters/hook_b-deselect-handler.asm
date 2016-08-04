origin 0x136278
base 0x80137FF8
scope hook_b_button_deselect {
  nonLeafStackSize(0)

  subiu sp, sp, {StackSize}
  sw    ra, 0x0014(sp)
  jal   CSS.DMA.bbutton_reset_state
  nop
  lw    ra, 0x0014(sp)
  addiu sp, sp, {StackSize}

  // oversize warning
  if ( origin() >  0x136294) {
    evaluate overBy(origin() - 0x136294)
    print "Routine needs to end at 0x1315F4, \nbut instead ended at 0x"
    printHex(origin()); print "\nOver-sized by {overBy} bytes\n"
    error "Replacement fn.css.updatePlayerPanelPallet is too large!\n"
  } else {
    // nop the rest of the original routine
    while (origin() <= 0x136294) {
      dd 0x00000000
    }
  }
}

print "Included hook_b-deselect-handler.asm\n\n"
