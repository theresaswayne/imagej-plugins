# @File(label = "Input image") sourceImage

# Note: DO NOT DELETE OR MOVE THE FIRST LINE -- it supplies essential parameters

# threshold_Comparison.py
# ImageJ jython script testing equivalence of autothreshold implementations
# expanding on AutoThresholdingDemo.txt example macro

import os, csv, math, sys


# setup
# most methods require directory names to be expressed as strings
# sourceImage_ = str(sourceImage) # underscore to avoid using the name of a function

srcDir = IJ.getDirectory(sourceImage)
#id = getImageID()
#title = getTitle()
#dotIndex = indexOf(title, ".")
#basename = substring(title, 0, dotIndex)
#resultName = basename+"_thresh.csv"

# TODO: find directory using file.getAbsolutePath()

# set up output file
csvPath = srcDir + os.sep + "thresh.csv"
csvExists = os.path.exists(csvPath)
csvFile = open(csvPath, 'ab') # creates the file. a for append, b for binary (avoiding potential problems with ascii)
csvWriter = csv.writer(csvFile) # this object is able to write to the output file

# add headers to output file
# 0 image, 1 method, 2 manual threshold value, 3 manual area, 
# 4 setAutoThreshold value, 5 setAutoThreshold area, 6 run Auto Threshold value, 7 run Auto Threhold area

if not csvExists: # avoids appending multiple headers
    headers = "Label,Method,Manual value,Manual area,setAuto value,setAuto area,run Auto value,run Auto area"
    csvWriter.writerow(headers)
else:
    print("Appending to existing file.")

run("Input/Output...", "file=.csv copy_row save_column save_row") # saves data as csv, preserves headers, preserves row number for copy/paste 
run("Set Measurements...", "area limit display redirect=None decimal=2")
run("Clear Results")
roiManager("reset")

MAXVAL = 255 # change if using a 12-bit image

# methods:

# explicit setting what i got in the manual method
#setAutoThreshold("Mean dark")
#run("Auto Threshold", "method=Default white") # white objects


# getInfo("threshold.method")
# getThreshold(lower, upper)
#setThreshold(lower, upper)

methods = getList("threshold.methods")
manualThreshVals = (33,21,135,38,33,30,143,29,28,246,52,43,26,130,98,16,162) # obtained from dialog

for (i=0 i<methods.length i++) {

	showProgress(i, methods.length)
	showStatus((i+1)+"/"+methods.length+": "+methods[i])

	results = ""
	# manual method
	setThreshold(manualThreshVals[i], MAXVAL)
	getStatistics(area, mean) # trailing arguments can be omitted... these values include scaling
		
	
	
setAutoThreshold(methods[i]+" dark")
getThreshold(lower, upper)
rename(methods[i]+": "+lower+"-"+upper)
wait(2000)
  }
  rename(title)
  
# loop over all methods
	
	# do the method
	# set measurements to area, limit
	# measure area
	# log data
	# reset threshold



#setAutoThreshold()
#Uses the "Default" method to determine the threshold.  -- but macro recorder gives this when you set a fifferent method like:
#setAutoThreshold("Mean dark")

