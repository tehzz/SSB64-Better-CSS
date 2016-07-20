# SSB64: Cycle Colors on CSS
### Features
On the CSS with a character chosen, use **Z** and **R** to cycle through all of that character's possible costumes/colors, just like in later Smash games. Use **L** to cycle through the three "Team Mode" shades: normal, light, and dark.

### Build
Put a big endian SSB-U rom into a new folder called 'ROM'. (Or just change the included file in main.asm) Then, use [ARM9's fork of  the bass assembler with N64 support](https://github.com/ARM9/bass) to assemble `main.asm` into the SSB64 rom.

### Problems
While the hack works as expected in Nemu and MupenPlus/Libretro, it currently soft-locks on console when Z, R, or L are pressed when a character is selected, i.e when the character's preview in the boxes at the bottom of the screen are to be updated/re-drawn.

The problem seems to be in the `css.updateCharacterModel` (`0x800E9248` on the character select screen) routine. If the `JAL css.updateCharacterModel` in `css_colorChange.asm` is commented out, the routine works fine on console. Of course, you can't see the changed colors until you start the match, or if you go to the SSS then come back to the CSS.

As far as I can tell, nothing is being passed on the stack to `css.updateCharacterModel`. There are some DIV divide-by-zero and overflow checks within the routine, but those are not the problem either...
