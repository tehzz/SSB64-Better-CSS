//bass-n64
//=========================================================
//---Limited Saved VS Record Data--------------------------
//
// The routine to save the KOs/TKOs/etc for the VS Record
// screen has no checks or provisions for characters
// beyond the standard 12. Add limits to prevent unwanted
// writes into RAM
//=========================================================

//--Hook saveBattleStats---------------
// Only add character checks, so most registers will be used as in original code

pushvar pc
scope hook_sbs {
  // This begins a loop that moves each players KO/TKOs
  // into the saved VS Record struct.
  constant loop_inc(0x80131DD4)
  constant inner_loop_inc(0x80131DC4)

//--Outer Loop Character Check----
  origin 0x150DCC
  base 0x80131C2C
  // Load and check for character
            lw    t7, 0x0018(s3)      // battle frame count
            addiu at, r0, 0x003C
            lbu   s4, 0x0023(v0)      // get player character byte
            divu  t7, at              // convert frames to seconds
            sltiu at, s4, 0x000C
            beqz  at, loop_inc        // if (char > 12) continue
            ori   at, r0, 0x005C
  // generate pointer to character in VS Record struct
            mflo  t0                  // battle seconds
            multu s4, at              // char * 0x5C
            mflo  t5
            addu  s0, a0, t5          // pointer to VSRec.char
            lw    t6, 0x0018(s0)      // VSRec.char.totalSeconds
  //
  nopUntilPC(0x80131C5C, "hook_sbs outer loop")

//--Inner Loop Character Check----
  origin 0x150EC4
  base 0x80131D24
  // Get base character pointer
            multu s1, s8              // inner player (s1) * 0x74 (s8)
  // Calc outer char (s4) * 0x2E and add to base VS Record addr
            sll   t2, s4, 0x2
            subu  t2, t2, s4
            sll   t2, t2, 0x3
            subu  t2, t2, s4
            sll   t2, t2, 0x2
            addu  t3, a0, t2          // point to outer char's VS Record struct
  // Check if inner player is in-game
            mflo  t8
            addu  v1, s3, t8          // global player struct for inner player
            lbu   t1, 0x0022(v1)
            multu s2, s8              // outer player (s2) * 0x74
  // if( player.in-game == not-in-game) continue
            beq   t1, s5, inner_loop_inc
            lbu   v0, 0x0023(v1)
            mflo  t5
  // if ( inner-char > 0xB ) continue
            sltiu at, v0, 0xC
            beqz  at, inner_loop_inc
            addu  t7, s3, t5          // global player struct for outer player
  // finish setting up pointer as per original game code
            sll   t6, s1, 0x2
            addu  t0, t6, t7

  nopUntilPC(0x80131D74, "hook_sbs inner loop")

}
pullvar pc

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included limit-saved-data.asm\n"
}
