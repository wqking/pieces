# A simple tool to split video files by time points

This is a simple script written in Python to split video by time points, by executing external ffmpeg. To use it, you need to have ffmpeg installed and executable from the command (add it to the environment path), and you need to modify the script to pass necessary variables.  

## Use the tool

Edit the script, modify the last line with your parameters.  

```
SplitVideoApp('/t.txt', '/t.mp4', '/temp/test').run()
```

The first parameter (here is '/t.txt') is the file name of the time point file.  
The second parameter (here is '/t.mp4') is the file name of the input video.  
The third parameter (here is '/temp/test') is the path to output the split files.  

## The time point file format

The time point file is a plain text file. Each line represents a time point. A line contains at least 1 column and can contain up to 3 columns (optional). The first and second columns (optional) must be time points, and the third column (optional) can be any text.  
The format of the time point is mm:ss or hh:mm::ss. hh indicates hours, mm indicates minutes, and ss indicates seconds. All parts can be 2 or 1 digit. The first column indicates the start time point. If there is no second column, the time point in the next line indicates the end time point. If there is no next line, the end time point indicates the end of the video file. If there is a second column, the second column indicates the end time point.  
If there is a third column (not a single column, it can contain spaces, and anything after the second column to the end of the line is the third column), the text in that column is the split file name. If there is no third column, the split file names are arranged in file order.  

Examples,  

```
00:05
01:18 2:25
3:8 9:5 This is another section
```

## Motivation

They each contain several exercises. I would like to watch each exercise as a separate video, so I wrote this script to do it.
