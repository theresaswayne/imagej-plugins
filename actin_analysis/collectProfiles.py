# @File(label = "Input directory", style = "directory") inputDir
# @File(label = "Output directory", style = "directory") outputDir

# Note: Do not change or remove the first two lines! They provide essential parameters.

# collectProfiles.py
# take data from profile plot in IJ
# input: none (user supplies an input directory that is not used)
# output: a saved file with the profile plot values

from ij import IJ, WindowManager
from ij.gui import Roi, PolygonRoi, FreehandRoi, Line, ProfilePlot
from ij.plugin.frame import RoiManager
import csv, os, sys, random

# most methods require directory names to be expressed as strings
input_ = str(inputDir) # underscore to avoid using the name of a function
output_ = str(outputDir)

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

# ---- create image for testing

imp = IJ.createImage("test", "16-bit ramp", 200, 200, 1)
imageName = imp.getTitle()
imp.show()

# ---- create a test ROI from a set of coordinates

xPoints = []
for i in range(10,100,10):
	xPoints.append(float(i))

yPoints = []

# for a straight line
#for i in range(10,100,10):
#	yPoints.append(float(i))

# for a crooked line
#random.seed(9)
for i in range(10):
	yPoints.append(random.randrange(10,100))
yPoints = sorted(yPoints)

# create ROI
testLine = PolygonRoi(xPoints, yPoints, Roi.FREELINE)

def get_roi_manager(new=False):
	""" flexible ROI mgr handling, from Particles_From_Mask.py template
	if new = True, a new blank mgr is returned
	if new = False (default) and the ROI manager is open, returns that mgr.
	if new = False and the ROI manager is NOT open, creates a new one without throwing an error
	"""
	rm = RoiManager.getInstance()
	if not rm:
		rm = RoiManager()
	if new:
		rm.runCommand("Reset")
	return rm

# get ROI into manager
rm = get_roi_manager(new=True)
rm.addRoi(testLine)
rm.select(0) # select the roi
rm.rename(0, "myROI")

# get the profile data
roiName = rm.getName(0)
roiPlot = ProfilePlot(imp)
#roiPlot.createWindow() # show the plot
#profileXVals = roiPlot.xValues
profileValues = roiPlot.getProfile() # a double array

# write the data to the file
# ['Filename','ROI Name','Position','Value']

for i in range(len(profileValues)):
	print("collecting row " + str(i))
	resultsRow = [imageName, roiName, i, profileValues[i]]
	csvWriter.writerow(resultsRow)

csvFile.close() # closes the output file so it can be used elsewhere
print("Finished.")



