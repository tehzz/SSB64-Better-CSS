//bass-n64
//---Super Smash Bros NTSC-U Routines------------

scope fn {
  // libultra / OS routines
  scope libultra {
    include "ssbLibUltra.inc"
  }
  // Universal, always in RAM routines
  scope ssb {
    include "ssbUniversal.inc"
  }
  // Routines only in RAM on Character Select Screen
  scope css {
    include "CSS.inc"
  }
  // Routines only in RAM on Battle Result Screen
  scope results {
    include "resultScreen.inc"
  }

}
