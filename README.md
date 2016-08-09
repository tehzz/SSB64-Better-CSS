# SSB64: Better CSS
#### Adding the things Nintendo forgot

[![Video Demonstration of Better CSS hack](http://img.youtube.com/vi/9BsBzrTdR4s/0.jpg)](https://www.youtube.com/watch?v=9BsBzrTdR4s)

[The Hack in Action (Youtube Video)](https://www.youtube.com/watch?v=9BsBzrTdR4s)


### Features
* Use **Z** and **R** to cycle through *all* of that character's possible costumes/colors, just like in later Smash games.
* Use **L** to cycle through the three "Team Mode" shades: normal, light, and dark.
* Use **D-PAD UP** to switch to the Polygon version of a character
* Use **D-PAD DOWN** to use Metal Mario or Giant Donkey Kong
* **D-PAD LEFT/RIGHT** to switch back to the original character

### Build
Put a big endian SSB-U rom into a new folder called 'ROM'. (Or just change the included file in main.asm) Then, use [ARM9's fork of  the bass assembler with N64 support](https://github.com/ARM9/bass) to assemble `Better-CSS/better-css.asm` into the SSB64 rom. Change CRC, etc.

### Problems
This release seems to be bug free! Console and emulator play both seem to work well.

### Future Features?
* Change CPU characters to unselectable variants by "dropping" the CPU token with a D-PAD
