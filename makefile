OUTPUT=bettercss.z64
SOURCE=./Better-CSS/better-css.asm
AS=bass
ASFLAGS=-create
verbose=-d v
CRC=rn64crc
CRCFLAGS=-u

all: build

build:
	$(AS) $(ASFLAGS) -o $(OUTPUT) $(SOURCE)
	-$(CRC) $(CRCFLAGS) $(OUTPUT)

verbose:
	$(AS) $(ASFLAGS) $(verbose) -o $(OUTPUT) $(SOURCE)

symbols:
	$(AS) $(ASFLAGS) -sym $(subst .z64,-sym.txt,$(OUTPUT)) -o $(OUTPUT) $(SOURCE)

vsym:
	$(AS) $(ASFLAGS) $(verbose) -sym $(subst .z64,-sym.txt,$(OUTPUT)) -o $(OUTPUT) $(SOURCE)
	sym2nbm $(subst .z64,-sym.txt,$(OUTPUT)) -o $(subst .z64,.nbm,$(OUTPUT))

# Moving built roms to the everdrive
loadED: build
		loader64 $(OUTPUT)

.PHONY : clean
clean:
	-rm $(OUTPUT) $(subst .z64,-sym.txt,$(OUTPUT)) $(subst .z64,.nbm,$(OUTPUT))
