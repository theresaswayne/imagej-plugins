# pointsInRoi.py
# demonstration of finding points in a multi-point ROI that are inside an area ROI

from ij import IJ, ImagePlus, ImageStack
import net.imagej.ops
from net.imglib2.view import Views
from net.imglib2.img.display.imagej import ImageJFunctions as IL
from ij.gui import Roi, PointRoi, WaitForUserDialog
from ij.plugin.frame import RoiManager
import os
from jarray import zeros

# setup
IJ.run("Close All", "")
rm = RoiManager.getInstance()
if not rm:
	rm = RoiManager()
rm.reset()

# create blank image
imp = IJ.createImage("Test", "8-bit ramp", 200, 200, 1)
ip = imp.getProcessor()
imp.show()

# create a rectangular area ROI
aroi = Roi(75,75,50,50)
rm.addRoi(aroi)
rm.runCommand(imp, "Show All")
imp.show()

# create a multi-point ROI

proi = PointRoi()
proi.addPoint(imp, 50, 50)
proi.addPoint(imp, 100, 100)
proi.addPoint(imp, 120, 120)
rm.addRoi(proi)
rm.runCommand(imp, "Show All")
imp.show()

# prompt to get a freehand ROI

IJ.setTool("freehand")
msg = WaitForUserDialog("Draw", "Draw a freehand ROI and add to ROI manager")
msg.show()
rm.runCommand(imp, "Show All")
imp.show()

# cycle through all ROIs to get the counts of points within each, storing in an array

totalPoints = proi.getCount(0)
insideCounts = zeros(rm.getCount(), "i")

for i in range(0, rm.getCount()):
	thisRoi = rm.getRoi(i)
	
	# skip point roi
	
	if thisRoi == proi:
		IJ.log("Skipping ROI #" + str(i))
		continue
	else:
		insidePoints = proi.containedPoints(thisRoi)
		pointsInRoi = insidePoints.getCount(0)
		IJ.log("There are " + str(pointsInRoi) + " points inside ROI #" + str(i)+ ", out of a total of " + str(totalPoints))
		insideCounts[i] = pointsInRoi

# show results
for j in range(0, len(insideCounts)):
	print(str(j) + "\t" + str(insideCounts[j]))
	
IJ.log("Done")
