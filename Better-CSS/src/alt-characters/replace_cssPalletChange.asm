//bass-n64

// Replace the original fn.css.PalletChange routine with our code

// MAN Pallet Offset Array Base: 0x8013B66C
// CPU...                      : 0x8013B67C


// register map
// a0 : pointer to find pallet location
//      + *0x74(a0)
// a1 : player index
// a2 : MAN or CPU
//--------------
// v0 : pointer to pallet active image data
//      + 0x30 from *0x74(a0) for pallet pointer
//--------------
// t0 : player's alt-char-state
// t3 : *pallet
// if alt-state == NONE
//    t1 : MAN or CPU Pallet Offset Array Base Addr
//          -> Appropriate Player/MAN|CPU Pallet Offset
//    t2 : Pallet File Base Addr
// else
//    t1 : custom_pallets.array Base Addr

// include alt-state enums
include "alt-char-state-enum.inc"

origin 0x13152C
base 0x801332AC
scope replacement_player_pallet_update {
  li    t0, CSS.DMA.alt_char_state    // Psuedo-I; load alt_char_state address
  addu  t0, t0, a1                // offset by player
  lbu   t0, 0x0000(t0)            // current_state = alt_char_state
  check_NONE:
  ori   at, r0, AltState.NONE
  beq   t0, at, else_normal_pallet
                                  // if(current_state != NONE) {
  offset_alt_array:
  li    t1, CSS.DMA.custom_pallets.array  // BD; *pallet = &custom_pallets.array
  subiu at, t0, 0x0001            //  Alt.State--
  sll   at, at, 3                 //
  addu  t1, t1, at                //  i = alt_pallet.array + AltState * 8
  sll   at, a2, 2                 //
  addu  t1, t1, at                //  i += Man|CPU*4
  b     store_pallet_addr         //
  lw    t3, 0x0000(t1)            //  *pallet = alt_pallet.array[i]
                                // } else {
  else_normal_pallet:
  lui   t1, 0x8013
  beq   a2, r0, man             // if (!man){
  ori   at, r0, 0xB66C          //
  addiu at, at, 0x0010          // t1 = CPU pallet offset array base

  man:                          // } else { t1 = MAN offset array base}
  or    t1, at, t1              //
  sll   at, a1, 0x2
  addu  t1, at, t1              // t1 = base + player index*4
  lw    t1, 0x000(t1)           // t1 = *pallet for playerindx/Man|CPU
  lui   t2, 0x8014
  lw    t2, 0xC4A0(t2)          // t2 = pallet file RAM addr base
  addu  t3, t2, t1              // t3 = file base + offset to pallet

  store_pallet_addr:
  lw    v0, 0x0074(a0)
  jr    ra
  sw    t3, 0x0030(v0)          // store our *pallet in the active img data for the panel

  // ADD TEAM MODE CHECK / LOGIC....

  // oversize warning
  if ( origin() >  0x1315F4 ) {
    evaluate overBy(origin() - 0x1315F4)
    print "Routine needs to end at 0x1315F4, \nbut instead ended at 0x"
    printHex(origin()); print "\nOver-sized by {overBy} bytes\n"
    error "Replacement fn.css.updatePlayerPanelPallet is too large!\n"
  } else {
    // nop the rest of the original routine
    while (origin() <= 0x1315F4) {
      dd 0x00000000
    }
  }
}

print "Included replace_cssPalletChange.asm\n\n"
