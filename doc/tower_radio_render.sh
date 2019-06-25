#!/bin/bash
openscad -o tower_radio.png --camera=370,1000,2500,70,0,-20,18000 --colorscheme=Nature --imgsize=2000,15000 tower_radio.scad
openscad -o tower_radio_all.png 					--colorscheme=Nature --imgsize=1500,15000 tower_radio.scad
openscad -o tower_radio_mount-clamp.png --camera=0,0,6000,45,0,-45,300 --colorscheme=Nature --imgsize=3000,3000 tower_radio.scad
openscad -o tower_radio_mount-block.png --camera=0,0,5100,30,0,-70,300 --colorscheme=Nature --imgsize=3000,3000 tower_radio.scad
openscad -o tower_radio_mount-all.png --camera=0,0,5700,60,0,-45,3000 --colorscheme=Nature --imgsize=2000,3000 tower_radio.scad
openscad -o tower_radio_base.png --camera=0,0,-100,40,0,-45,3000 --colorscheme=Nature --imgsize=3000,3000 tower_radio.scad

for f in tower_radio_*.png; do
  mogrify -trim -bordercolor none -border 30 +repage -resize 50% $f
done
