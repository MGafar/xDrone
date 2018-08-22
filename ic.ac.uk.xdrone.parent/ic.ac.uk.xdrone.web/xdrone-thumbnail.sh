shopt -s nullglob
rm -f WebRoot/thumbnails/*;

for x in WebRoot/processed_videos/*.mp4;
do
	y=${x%.mp4}
	echo ${y##*/}

	ffmpeg -ss 0.5 -i $x -t 1 -s 480x360 -f image2 WebRoot/thumbnails/${y##*/}.png -frames:v 1
done
