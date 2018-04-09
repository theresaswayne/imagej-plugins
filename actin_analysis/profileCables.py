# @long(label = "Profile spacing, um", value=1.0) profileSpacing
# @long(label = "Profile length, um", value=1.0) profileLength
# @int(label = "Profile line width, pixels", value=1) profileWidth
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

# ---- Imports

from ij import IJ, WindowManager
from ij.gui import Roi, PolygonRoi, FreehandRoi, Line, ProfilePlot
from ij.plugin.frame import RoiManager
from ij.measure import Calibration
import csv, os, sys, random, math

# --- Helper functions

# helper function for ROI mgr
def get_roi_manager(new=False):
	""" flexible ROI mgr handling, copied from Particles_From_Mask.py template in Fiji
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

# helper function for quitting (thanks to Tiago Ferreira, IJ forum)
def exit(status=""):
    """Exits without displaying a stack trace if :status: is empty"""
    if not status:
        from java.lang import RuntimeException
        from ij import Macro
        raise RuntimeException(Macro.MACRO_CANCELED) #Ignored by IJ2's Console
    else:
        raise RuntimeError(status)


# helper function for finding perpendicular at a point
def findPerp(xa, ya, xb, yb, profileLength):
	"""returns a tuple containing the endpoints of a line segment
	perpendicular to the line defined by (xa,ya) and (xb,yb),
	passing through (xb,yb), of length profileLength
	all parameters = floats
	thanks to David Nehme on Stack Overflow for the equations
	"""
	# calculate endpoints (xc,yc) and (xd,yd) of new perpendicular line of length profileLength 
	# by finding points c and d on the perpendicular unit vector through point b

	abDist = math.sqrt((xb-xa)**2 + (yb-ya)**2)

	dx = (xb-xa)/abDist
	dy = (yb-ya)/abDist

	xc = xb + (profileLength/2)*dy
	yc = yb - (profileLength/2)*dx

	xd = xb - (profileLength/2)*dy
	yd = yb + (profileLength/2)*dx

	return xc, yc, xd, yd # a tuple

# ---- TESTING

# create image
imp = IJ.createImage("test", "16-bit ramp", 200, 200, 1)

# give it a test scale factor
myCal = Calibration()
myCal.setUnit("um")
myCal.pixelHeight = 0.06
myCal.pixelWidth = 0.06

imp.setCalibration(myCal)

# show the image
imp.show()

# create some roughly diagonal ROIs

rm = get_roi_manager(new=True) # reset the ROI mgr

#random.seed(9)

for n in range(4):
	xPoints = []
	for i in range(20):
		xPoints.append(random.randrange(10,150))
	xPoints = sorted(xPoints)
	
	yPoints = []
	for i in range(20):
		yPoints.append(random.randrange(10,150))
	yPoints = sorted(yPoints)
	
	# create ROI and add to manager
	testLine = PolygonRoi(xPoints, yPoints, Roi.FREELINE)
	rm.addRoi(testLine)
	RoiName = "Z" + str(n+1)
	RoiIndex = rm.getCount() - 1
	rm.rename(RoiIndex, RoiName)

# ---- SETUP

# get image info
imageName = imp.getTitle()
imageCalib = imp.getCalibration()
pixSize = imageCalib.pixelHeight # assuming in microns

# calibrate the profile spacing and intervals
profileSpacingPix = int(profileSpacing/pixSize)
profileLengthPix = int(profileLength/pixSize)
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
    headers = ['Filename','Cable Name','ROI Name','Position','Value']
    csvWriter.writerow(headers)
else:
    print("Appending to existing file.")


# ----- Collect original ROIs

# check for ROIs in manager
# The IJ.error function produces a dialog with "OK" button.
# The exit() helper function terminates using an IJ1 function

numCables = rm.getCount()
if (numCables == 0):
	IJ.error("There are no ROIs saved. Draw ROIs around cells and press T to add each one to the Manager. Then run the script.");
	exit()

# Rename ROIs C1, C2, ... for Cable 1, 2, ...
for i in range(numCables):
	CableName = "C" + str(i+1)
	rm.rename(i, CableName)

# Loop through ROIs (assuming perps are added at end of list)

for cableIndex in range(numCables):
	
	cable = rm.getRoi(cableIndex)
	cableName = cable.getName()

	# sample the line evenly
	sampLine = cable.getInterpolatedPolygon(1,False) # a FloatPolygon with evenly spaced points, no smoothing
	sampX = sampLine.xpoints # float array
	sampY = sampLine.ypoints # float array

	profileCount = 0

	# go along the resampled line and make perpendicular lines at desired intervals
	for i in range(slopeCalcSpacing, len(sampX)-1, profileSpacingPix): 

		profileCount += 1
		
		# define the points used to calculate the slope
		xa = sampX[i-slopeCalcSpacing]
		ya = sampY[i-slopeCalcSpacing]
		xb = sampX[i]
		yb = sampY[i]
	
		print("sample "+str(i)+" points are ("+str(xa)+","+str(ya)+"), ("+str(xb)+","+str(yb)+")")
	
		# get the endpoints of the perpendicular line
		profCoords = findPerp(xa, ya, xb, yb, profileLengthPix)
		xc = profCoords[0]
		yc = profCoords[1]
		xd = profCoords[2]
		yd = profCoords[3]
	
		# make the perp line ROI
		perpLine = Line(xc, yc, xd, yd)
		perpLine.setWidth(profileWidth)
		rm.addRoi(perpLine)

		# rename to associate with the cable
		perpName = cable.getName() + "-" + str(profileCount)
		lastROI = rm.getCount() - 1
		rm.rename(lastROI, perpName)

		# get the profile data
		rm.select(lastROI)
		roiPlot = ProfilePlot(imp)
		profileValues = roiPlot.getProfile() # a double array
		profileXVals = roiPlot.getPlot().getXValues()
		rm.deselect()

		# TODO: Save the plot
		# TODO: (?) subpixel resolution option

		for j in range(len(profileValues)):
			print("collecting row " + str(j))
			resultsRow = [imageName, cableName, perpName, profileXVals[j], profileValues[j]]
			csvWriter.writerow(resultsRow)
	
# Save final ROIset
rm.runCommand("Show All")
rm.deselect()
rm.runCommand("Save", output_ + os.sep + imageName + "_ROIs.zip");

csvFile.close() # closes the output file so it can be used elsewhere

print("Finished.")

 