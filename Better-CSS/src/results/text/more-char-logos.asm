//bass-n64
//=========================================================
//---Add "Winning Logos" for more than 12 Characters-------
//
// Replace the 12 member arrays with 27 (or any number)
// member arrays to have legal values for all on ROM
// characters. Also, this prevents 3 large arrays from
// being loaded on the stack by using references for the
// three new arrays
//=========================================================
//---Begin Hook------------------------
// All of this will be within the routine, so it's really one big hook..
//---Register Map------------
// t0 : *CharInfo for winning character
// t1 : *CharInfo.logo.dlPtr
//                    .colorPtr
//                    .zoomPtr
// t2 : 0x80000000 bitmask
// t3 : ram addr of resource-0035.bin
//---Stack Map---------------
// First Array  : 0x00A0 + sp
// Second Array : 0x0070 + sp
// Third Array  : 0x0040 + sp
//---------------------------
// Called from 0x80138DAC

pushvar pc
origin 0x151CC0
base 0x80132B20

scope char_logos_hooks: {
  // this loads a "color" array for teams, and then gets the winning
  // character on the stack at 0xD0
  // End 80132C58
  constant put_winner_on_stack(0x80132BC8)
  constant end_put_winner(0x80132C58)
  constant ram_resource35(0x8013A058)
  //  First, re-organize the beginning of the draw logo routine to just get
  // pointers to the displaylists, instead of putting large arrays on the stack

  //prologue:
            subiu sp, sp, 0x00E0      // original stack space
            sw    ra, 0x0024(sp)      // original ra stack offset
            sw    s0, 0x0020(sp)      // original s0 stack offset
  // After this, the routine would load 3 arrays on the stack.
  // Instead, jump ahead in the routine to get the winning character index on the stack
  grab_winning_char:
            b     put_winner_on_stack  // at sp + 0xD4
            nop
  get_CharInfo:
            jal   getCharInfoPtr
            lw    a0, 0x00D4(sp)      // grab winning character index
            or    t0, r0, v0          // put *CharInfo into t0
  init_offset_check:
      lwAddr(t3, ram_resource35, 0)
            lui   t2, 0x8000          // load the mask for non-offset logo pointers
  check_dlPtr:
            lw    t1, data.CharInfo.logo.dlPtr(t0)
            and   at, t2, t1          // if msb == 1, then don't add to file35 base
            beqzl at, store_dlPtr
            addu  t1, t1, t3          // abuse likely branching to only add when branched
  store_dlPtr:
            sw    t1, 0x00A0(sp)      // store logo DL offset at 0xA0(sp)
  check_colorPtr:
            lw    t1, data.CharInfo.logo.colorPtr(t0)
            and   at, t2, t1
            beqzl at, store_colorPtr
            addu  t1, t1, t3
  store_colorPtr:
            sw    t1, 0x00A4(sp)      // store logo color offset at 0xA4
  check_zoomPtr:
            lw    t1, data.CharInfo.logo.zoomPtr(t0)
            and   at, t2, t1
            beqzl at, store_zoomPtr
            addu  t1, t1, t3
  store_zoomPtr:
            sw    t1, 0x00AC(sp)      // store zoom offset at 0xAC

  end_custom_routine:
            or    a0, r0, r0          // replacement instruction from 80132C54
            or    a1, r0, r0          // replacement
            b     continue_routine
            addiu a2, r0, 0x0017      // replacement instruct

  nopUntilPC(put_winner_on_stack, "Character logo nop")
// End of mini-internal routine

origin 0x151DF8
base end_put_winner   //0x80132C58
            b     get_CharInfo
            nop
  continue_routine:

//--- First Array Load and Use -------------------
// 80132C94 addu  a1, t7, t0
//------------------------------------------------
origin 0x151E34
base 0x80132C94
load_char_logo_dl:
            lw    a1, 0x00A0(sp)    // use pre-calculated pointer

//--- Second Array Load and Use ------------------
// 80132CBC lui   t2, 0x8014
//       C0 lw    t2, 0xA058(t2)
//       C4 addu  t5, sp, t8
//       C8 lw    t5, 0x0070(t5)
//       CC addu  t5, sp, t8
//       D0 jal   0x8000F8F4
//       D4 addu  a1, t5, t2    #file base + character offset
//------------------------------------------------
origin 0x151E74
base 0x80132CD4
load_color_dl:
            lw    a1, 0x00A4(sp)    // use pre-calculated pointer to color dl

//--- Third Array Load and Use -------------------
// 80132CFC addu  a1, t3, t4
//------------------------------------------------
origin 0x151E9C
base 0x80132CFC
load_zoom_dl:
            lw    a1, 0x00AC(sp)    // use pre-calculated pointer to color dl
}

pullvar pc

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included more-char-logos.asm\n"
}
