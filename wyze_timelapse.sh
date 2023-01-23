#!/bin/bash

### Variables

# Where to save the timelapses
basedir=~/timelapses

# Which hour of the day to start recording (leave blank for 24 hour timelapses).
start_record=11

# Which hour of the day to stop recording (leave blank for 24 hour timelapses).
stop_record=5

# Take a frame every X minutes
interval=10

# dont edit below this line

if [ -z $1 ]; then
	read -p "Enter timelapse name: " timelapsename
else
	timelapsename=$1
fi
fulldir=$basedir/$timelapsename
mkdir -p $fulldir/images
mydate=$(date +%m-%d-%Y)

rm -f $fulldir/.newlist $fulldir/.newlist.tmp $fulldir/.newlist.tmp2
echo "[###] Generating File List"
sleep 1
#let count=1

for time in $(seq -w 0 $interval 59); do
	for i in $(find . -name ${time}.mp4); do
		echo "$i" >> $fulldir/.newlist.tmp
	done
done

# Exclude between the start and stop times (if set)
if ! [ -z $start_record ]; then
	start_record=$(expr $start_record - 1)
	for i in $(seq -w $stop_record $start_record); do
		grep -v \/$i\/ $fulldir/.newlist.tmp > $fulldir/.newlist.tmp2
		mv $fulldir/.newlist.tmp2 $fulldir/.newlist.tmp
	done
fi
		
sort $fulldir/.newlist.tmp > $fulldir/.newlist
echo "[###] Extracting Images from $(pwd)"
for i in $(cat $fulldir/.newlist); do
	date=$(echo $i | awk -F'/' '{ print $2 }')
	hour=$(echo $i | awk -F'/' '{ print $3 }')
	min=$(echo $i | awk -F'/' '{ print $4 }')
	combined="${date}-${hour}-${min}"
      	echo " [+] $combined --> images/$combined.jpeg"
      	ffmpeg -n -i "$i" -frames:v 1 $fulldir/images/$combined.jpeg &> /dev/null
done
echo "[###] Converting to .mp4"
cd $fulldir/images
ffmpeg -framerate 30 -pattern_type glob -i '*.jpeg' -c:v libx264 -pix_fmt yuv420p ${fulldir}/${timelapsename}-$mydate.mp4
echo Done

# Concatenate them all into one Timelapse

cd $fulldir
rm -f .concat-list
echo "file PRE_${timelapsename}.mp4" > .concat-list
echo "file ${timelapsename}-$mydate.mp4" >> .concat-list
#for i in $(ls -1 *.mp4 | grep -v FULL); do
#	echo "[+] $i"
#	echo "file $i" >> .concat-list
#done

echo Combining videos
ffmpeg -y -f concat -i .concat-list -c copy FULL_${timelapsename}_${mydate}.mp4 &> /dev/null && echo "[+] $fulldir/FULL_${timelapsename}_${mydate}.mp4" done
