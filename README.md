# SSB64: Cycle Colors on CSS
### Features
On the CSS with a character chosen, use **Z** and **R** to cycle through all of that character's possible costumes/colors, just like in later Smash games. Use **L** to cycle through the three "Team Mode" shades: normal, light, and dark.

### Build
Put a big endian SSB-U rom into a new folder called 'ROM'. (Or just change the included file in main.asm) Then, use [ARM9's fork of  the bass assembler with N64 support](https://github.com/ARM9/bass) to assemble `main.asm` into the SSB64 rom.

### Problems
While the hack works as expected in Nemu and MupenPlus/Libretro, it currently soft-locks on console when Z, R, or L are pressed when a character is selected, i.e when the character's preview in the boxes at the bottom of the screen are to be updated/re-drawn.

Adjusting the stack size to be double-word aligned (divisble by 0x8) makes the code work on console. Thanks to bit for the fix!
