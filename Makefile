
snips_txt := $(wildcard ./snips/*.toki-pona.txt)
snips_musicxml := $(wildcard ./snips/*.musicxml) $(snips_txt:%.toki-pona.txt=%.chords-in-C.musicxml)
snips_png := $(wildcard ./snips/*.png) $(snips_musicxml:%.musicxml=%-1.png)
snips_mp3 := $(wildcard ./snips/*.mp3) $(snips_musicxml:%.musicxml=%.mp3)
snips_mp4 := $(snips_musicxml:%.musicxml=%.mp4)

.PHONY: most all musicxml png mp3 mp4

most: musicxml png mp3

all: most mp4

musicxml: $(snips_musicxml)

# NOTE:
# - `$<` in the command means first prereq, in this case `%.toki-pona.txt`
%.chords-in-C.musicxml : %.toki-pona.txt
	racket -l toki-pi-kalama-musi/diatonic/inversion/musicxml.rkt -- -f $<

png: $(snips_png)

# NOTE:
# - `$<` in the command means first prereq, in this case `%.musicxml`
# - `$(<:%.musicxml=%.png)` in the command expresses `%.png`
%-1.png : %.musicxml
	mscore -T 15 -o $(<:%.musicxml=%.png) $<

mp3: $(snips_mp3)

# NOTE:
# - `$<` in the command means first prereq, in this case `%.musicxml`
# - `$@` in the command means target, in this case `%.mp3`
%.mp3 : %.musicxml
	mscore -o $@ $<

mp4: $(snips_mp4)

# NOTE:
# - `$<` in the command means first prereq, in this case `%.mp3`
# - `$@` in the command means target, in this case `%.mp4`
# - `$(<:%.mp3=%-1.png)` in the command expresses `%-1.png`
%.mp4 : %.mp3 %-1.png
	ffmpeg -y -loop 1 -i $(<:%.mp3=%-1.png) -i $< -shortest -framerate 1 -tune stillimage -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2:color=white" -pix_fmt yuv420p $@
