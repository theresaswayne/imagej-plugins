# collectProfiles.py
# take data from profile plot in IJ

# output: a saved file with the profile plot values


from ij import IJ, WindowManager
from ij.gui import Roi, PolygonRoi, FreehandRoi, Line, ProfilePlot
from ij.plugin.frame import RoiManager
import csv, os, sys, random

# ---- create image for testing

imp = IJ.createImage("test", "16-bit ramp", 200, 200, 1)
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


# get the profile plot on the active image
roiPlot = ProfilePlot(imp)
#roiPlot.createWindow() # show the plot
profileData = roiPlot.getProfile() # a double array




