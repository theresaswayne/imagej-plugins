# drawPerpendiculars.py
# ImageJ jython script by Theresa Swayne

# input: none
# output: image with line ROI
# usage: Adjust seed and straight/crooked as desired by commenting out lines. Run.

from ij import IJ, WindowManager
from ij.gui import Roi, PolygonRoi, FreehandRoi
from ij.plugin.frame import RoiManager
import random

# ---- parameters

profileSpacing = 10.0 # how far apart profiles should be along the cable (in scaled units)
slopeCalcSpacing = 2 # int, how far away we look along the line to calculate the slope (in pixels)
profileLength = 20.0 # total length of profile line (in pixels for now)
profileWidth = 1.0 # width of profile line (in pixels for now)

# ---- create image for testing

imp = IJ.createImage("test", "16-bit black", 200, 200, 1)
imp.show()

# ---- TODO: calculate scaled parameters

imageCalib = imp.getCalibration()
pixSize = imageCalib.pixelHeight # assuming in microns
profileSpacingPix = profileSpacing/pixSize # float

# ---- create a test ROI from a set of coordinates

xPoints = []
for i in range(10,100,10):
	xPoints.append(float(i))

yPoints = []

# for a straight line
for i in range(10,100,10):
	yPoints.append(float(i))

# for a crooked line
#random.seed(9)
#for i in range(10):
#	yPoints.append(random.randrange(10,100))
#yPoints = sorted(yPoints)

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

# myRoi = rm.getRoi(0)

# ---- sample the line evenly

sampInt = 2 # pixel units
sampLine = testLine.getInterpolatedPolygon(sampInt,False) # a FloatPolygon with evenly spaced points

sampLength = sampLine.getLength(True) # True means it's a line

sampX = sampLine.xpoints # float array
sampY = sampLine.ypoints # float array

# note the supposed length of the straight line comes out between 113 and 99 depending on the sampInt value, 1 to 100
# note for a crooked line, the number of samples is consistently half the length for sampInt = 2
print("The line is " + str(sampLength) + " pixels long and there are " + str(len(sampX)) + " samples.")


# ---- helper function for finding perpendicular at a point

def findPerp(xa, ya, xb, yb, perpLength):
	"""returns a tuple containing the endpoints of a line segment
	perpendicular to the line defined by (xa,ya) and (xb,yb),
	passing through (xb,yb), of length perpLength
	all parameters = floats
	"""
	# get equations for the line and perpendicular, checking for boundary conditions
	# Line ab: y = m * x + b
	# Perpendicular line: y = mp * x + bp
	# calculate endpoints of new perpendicular line of length r: (xc,yc) and (xd,yd)
	 
	if (xa-xb == 0.0): # vertical line, slope and intercept are undefined
	
		print("the original line is vertical")
		# slope m is undefined, slope of perp mp = 0
		mp = 0.0
		# intercept b is undefined, intercept of perp bp = yb
		bp = yb
	
		# find points c and d on the horizontal line
		xc = xb + profileLength/2.0
		yc = yb
	
		xd = xb - profileLength/2.0
		yd = yb
		
		
	elif (ya - yb == 0.0): # horizontal line, slope and intercept of perp are undefined
	
		print("the original line is horizontal")
		# slope m is 0, slope of perp mp = undefined
		m = 0.0
		# intercept b is yb, intercept of perp bp is undefined
		b = yb
	
		# find points c and d on the vertical line
		xc = xb
		yc = yb + profileLength/2.0
	
		xd = xb
		yd = yb - profileLength/2.0
	
		
	else: # calculate slopes and intercepts in the normal way
	
		# slope m is change in y over change in x
		m = (yb-ya)/(xa-xb)
		# intercept b is obtained by solving the equation
		b = yb - (m*xb)
		print("original line slope = "+str(m)+", intercept = "+str(b))
	
		mp = -1/m
		bp = xb * ((m**2+1.0)/m) + b # must use ## not ^!
		print("perpendicular line slope = "+str(mp)+", intercept = "+str(bp))
	
		# find points c and d on the perpendicular unit vector through point b
		# thanks to David Nehme on Stack Overflow
	
		abDist = math.sqrt((xb-xa)**2 + (yb-ya)**2)
	
		dx = (xb-xa)/abDist
		dy = (yb-ya)/abDist
	
		xc = xb + (profileLength/2)*dy
		yc = yb - (profileLength/2)*dx
	
		xd = xb - (profileLength/2)*dy
		yd = yb + (profileLength/2)*dx

	return xc, yc, xd, yd # a tuple

# --- step along the line
# at intervals defined by profileSpacing, calculate the perpendicular line using slopeCalcSpacing

profSpacingPix = int(profileSpacingPix)

for i in range(1, len(sampX)-1, profSpacingPix): 

	# TODO: slope calc should be ints
	# define the points used to calculate the slope
	xa = sampX[i-slopeCalcSpacing]
	ya = sampX[i-slopeCalcSpacing]
	xb = sampX[i]
	yb = sampY[i]

	# calculate the endpoints of the perp
	profCoords = findPerp(xa, ya, xb, yb, perpLength)
	xc = profCoords[0]
	yc = profCoords[1]
	xd = profCoords[2]
	yd = profCoords[3]

	# make the perp line ROI
	perpLine = Line(xc, yc, xd, yd)
	perpLine.setWidth(profileWidth)
	rm.addRoi(perpLine)
