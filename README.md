# wyze_timelapse.sh
This is a script that will build a timelapse from your Wyze V2 using the files already stored on your Wyze SD Card. I decided to write this because the built-in timelapse function is pretty much a coin toss and can't be trusted. On a few occasions I lost 1 or 2 weeks worth of timelapses because the camera would simply decide not to save it. This will generate one for you using the playback footage, which seems to work fine. 


# Dependencies 
- Linux (Tested on Ubuntu but should work with RHEL and other distros too, but I did not test.)
- ffmpeg (apt install ffmpeg on Ubuntu, yum install ffmpeg on RHEL)

# Configuration 
- Save script to /usr/local/bin
- Update the variables at the top of the script to suit your needs
- sudo chmod +x /usr/local/bin/wyze_timelapse.sh

# How to use
- Plug SD Card into your computer
- Open Terminal and cd into /path/to/sdcard/record directory
- Run the script (sudo wyze_timelapse.sh or sudo /usr/local/bin/wyze_timelapse.sh).
- Choose your timelapse name.

Note: You can re-use the same timelapse name and the script will keep adding to the overall timelapse. 

# SD Card Size vs Playback history
This is how many days of playback the Wyze will save to the SDCard. 

Make sure to run the script before the Wyze starts overwriting older days and putting gaps in your timelapse. 

- 64GB = 6 days
- 128GB = 11 days

# Size estimates
Each image is ~195KB.

The script stores the .jpeg files stored in the images folder within the timelapse directory, be aware of the sizes:

- 24h @ 10min interval = 24MB/day (~720MB/month) 
- 18h @ 10min interval = 18MB/day (~540MB/month)
- 12h @ 10min interval = 12MB/day (360MB/month)

- 24h @ 20min interval = 12MB/day(360MB/month)
- 18h @ 20min interval = 9MB/day(270MB/month)
- 12h @ 20min interval = 6MB/day(180MB/month)
