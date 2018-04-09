# @int(label = "Profile spacing, um") profileSpacing
# @int(label = "Profile length, pixels") profileLength
# @int(label = "Profile line width, pixels") profileWidth
# @File(label = "Output directory", style = "directory") outputDir

# Note: Do not change or remove the first few lines! They provide essential parameters.

# profileCables.py
# IJ Jython script by Theresa Swayne, 2018
# Designed for actin cable analysis
# Given a set of lines in the ROI Manager, 
#   collects and saves a series of profiles perpendicular to each, at a specified interval

# Input: An image and a set of line or freehand ROIs in the ROI manager
# Output: 
#	A CSV file containing the profile data of all the perpendiculars of all the lines
#	An ROIset containing all the original lines and the perpendiculars

# TODO: Output a CSV file containing the profile along each original line
# TODO: Output a snapshot of the image with the original lines, and perpendiculars in a contrasting color, zoomed up for easy viewing
# TODO: Put all parameters in terms of um

# Usage: Open an image and draw lines along each cable you want to analyze. 
#	Press T after each one to add to the ROI Manager.
#	Run the script.

from ij import IJ, WindowManager
from ij.gui import Roi, PolygonRoi, FreehandRoi, Line, ProfilePlot
from ij.plugin.frame import RoiManager
from ij.measure import Calibration
import csv, os, sys, random, math

# ---- TESTING

# create image
imp = IJ.createImage("test", "16-bit ramp", 200, 200, 1)

# give it a test scale factor
myCal = Calibration()
myCal.setUnit("um")
myCal.pixelHeight = 10
myCal.pixelWidth = 10

imp.setCalibration(myCal)

# finally show the image
imp.show()

# ---- SETUP

slopeCalcSpacing = 1 # int, how far away we look along the line to calculate the slope (in pixels)

# most methods require directory names to be expressed as strings
output_ = str(outputDir) # underscore to avoid using the name of a function

# setup output file
csvPath = output_ + os.sep + "Profile.csv"
csvExists = os.path.exists(csvPath)
csvFile = open(csvPath, 'ab') # creates the file. a for append, b for binary (avoiding potential problems with ascii)
csvWriter = csv.writer(csvFile) # this object is able to write to the output file

# add headers to output file
if not csvExists: # avoids appending multiple headers
    headers = ['Filename','ROI Name','Position','Value']
    csvWriter.writerow(headers)
else:
    print("Appending to existing file.")

# get image scale
pixSize = imp.getCalibration().pixelHeight # assuming in microns
print("Pixel size is "+str(pixSize))


# ----- Collect original ROIs
# check for ROIs in manager (else display message and quit)
# Rename ROIs C1, C2, ...
# Loop through ROIs
# 	Draw profiles and add each to mgr
#	Append data to CSV file
# Save final ROIset
 