import os
import re

def secondsToFfmpegTime(time) :
	seconds = time % 60
	time = (time - seconds) // 60
	minutes = time % 60
	time = (time - minutes) // 60
	hours = time % 24
	return "%02d:%02d:%02d" % (hours, minutes, seconds)

def ffmpegTimeToSeconds(time) :
	parts = time.split(':')
	hours = 0
	if len(parts) == 3 :
		hours = int(parts[0])
	minutes = int(parts[-2])
	seconds = int(parts[-1].split('.')[0])
	return hours * 60 * 60 + minutes * 60 + seconds

def isFfmpegTime(text) :
	return re.match(r'(\d{1,2}:){1,2}\d{1,2}(\.\d+)?', text) is not None

class SplitVideoApp :
	def __init__(self, timePointFileName, inputFileName, outputPath):
		self._timePointFileName = timePointFileName
		self._inputFileName = inputFileName
		self._outputPath = outputPath
		self._timePointList = []
		self._fileExtension = os.path.splitext(self._inputFileName)[1]

	def run(self) :
		self._loadTimePoints()
		self._convert()

	def _loadTimePoints(self) :
		with open(self._timePointFileName) as f:
			textLineList = f.readlines()
		index = 0
		for textLine in textLineList :
			timePoint = self._parseTimePointLine(textLine)
			if timePoint is not None :
				timePoint['index'] = index
				index += 1
				self._timePointList.append(timePoint)
		if len(self._timePointList) == 0 :
			return
		for i in range(len(self._timePointList) - 1) :
			if self._timePointList[i]['end'] is None :
				self._timePointList[i]['end'] = self._timePointList[i + 1]['start']
		if self._timePointList[-1]['end'] is None :
			self._timePointList[-1]['end'] = self._timePointList[-1]['start'] + 12 * 60 * 60

	def _convert(self) :
		for timePoint in self._timePointList :
			outputFileName = self._makeOutputFileName(timePoint)
			command = self._makeFfmpegCommand(timePoint['start'], timePoint['end'] - timePoint['start'], outputFileName)
			print(command)
			os.system(command)

	def _parseTimePointLine(self, textLine) :
		textLine = textLine.strip()
		parts = re.split(r'(\s+)', textLine)
		if len(parts) == 0 :
			return None
		if not isFfmpegTime(parts[0]) :
			return None
		startTime = ffmpegTimeToSeconds(parts[0])
		endTime = None
		text = None
		nextIndex = None
		if len(parts) > 2 :
			nextIndex = 2
			if isFfmpegTime(parts[2]) :
				endTime = ffmpegTimeToSeconds(parts[2])
				nextIndex = 4
		if len(parts) >= nextIndex :
			parts = parts[nextIndex : ]
			text = str.join('', parts)
		if text is not None :
			text = text.strip()
			text = re.sub(r'^[\:\-_#\$%]', '', text)
			text = text.strip()
		return {
			'start' : startTime,
			'end' : endTime,
			'text' : text
		}

	def _makeFullOutputFileName(self, fileName) :
		return os.path.join(self._outputPath, fileName)
	
	def _normalizeFileName(self, fileName) :
		fileName = re.sub(r'[^\w\s\-_]', '', fileName)
		fileName = re.sub(r'[\s+]', ' ', fileName)
		fileName = re.sub(r' ', '_', fileName)
		return fileName

	def _makeOutputFileName(self, timePoint) :
		text = timePoint['text']
		if text is None or len(text) == 0 :
			return 'part' + str(timePoint['index'] + 1)
		return self._normalizeFileName(text)

	def _makeFfmpegCommand(self, startTime, duration, outputFileName) :
		commandTemplate = 'ffmpeg -ss {startTime} -t {duration} -i "{inputFileName}" -acodec copy -vcodec copy "{outputFileName}"'
		return commandTemplate.format(
			startTime = secondsToFfmpegTime(startTime),
			duration = secondsToFfmpegTime(duration),
			inputFileName = self._inputFileName,
			outputFileName = self._makeFullOutputFileName(outputFileName) + self._fileExtension
		)

SplitVideoApp('/t.txt', '/t.mp4', '/temp/test').run()
