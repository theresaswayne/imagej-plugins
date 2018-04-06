# drawPerpendiculars.py
# ImageJ jython script by Theresa Swayne

# input: 
# output: 
# usage:

from ij import IJ, WindowManager
from ij.gui import Roi, PolygonRoi, FreehandRoi
from ij.plugin.frame import RoiManager
import random

random.seed(9)

# create image for testing
imp = IJ.createImage("test", "16-bit black", 200, 200, 1)
imp.show()

# create a set of coordinates to explicitly define ROI

xPoints = []
for i in range(10,100,10):
	xPoints.append(float(i))

# for a straight line
yPoints = []
for i in range(10,100,10):
	yPoints.append(float(i))

# for a crooked line
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

# add ROI to manager
rm = get_roi_manager(new=True)
rm.addRoi(testLine)
rm.select(0)

