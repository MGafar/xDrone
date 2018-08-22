shopt -s nullglob
for i in WebRoot/videos/*.h264;
do
	y=${i%.h264}

	if [ -f WebRoot/processed_videos/${y##*/}.mp4 ]; then
		rm WebRoot/processed_videos/${y##*/}.mp4;
	fi

	ffmpeg -i "$i" "WebRoot/processed_videos/${y##*/}.mp4";
	
	rm $i;
done
