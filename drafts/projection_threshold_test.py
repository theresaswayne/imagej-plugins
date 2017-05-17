# --- draft -- need to figure out how to access the threshold determined by the auto method.

# goal -- test different threhosld methods on the max projection, 
# see if they reveal bud scars on the rotated projections

# want x and y axes (z is trivial)

from ij import IJ
import os 
import random
import math

imp = IJ.getImage()
#srcDir = imp.getDirectory()
# print("directory = "+srcDir)
#filename = od.getFileName()
# print("file = "+filename)
#path = os.path.join(srcDir, od.getFileName())
#basename = os.path.splitext(filename)[0]
# print("base = "+basename)
# print("path = "+path)

#path = imp.getDirectory()
#print(path)
# id = getImageID()
title = imp.getTitle()
#title = imp.getTitle()
basename = os.path.splitext(title)[0]
print(title, basename)
# print("title is",title);
#dotIndex = indexOf(title, ".")

cal = imp.getCalibration()
scaled = cal.scaled();
if scaled:
   units = cal.units
   depth = cal.pixelDepth


def tryThresh(imp, method):
	''' 
	generates a max projection, auto-thresholds the projection, returns a tuple of the method
	and the threshold used
	imp: ImagePlus
	method: string denoting one of the global thresholding methods
	'''	
	result = ()
	print("Using method",method)
	IJ.run(imp, "Z Project...", "projection=[Max Intensity]")
	IJ.setAutoThreshold(imp, method+" dark");
	# IJ.getThreshold(lower, upper)
	print("the thresholds are ",lower,upper)
	result = (method,lower)
	return result

tryThresh(imp, "Default")


#run("3D Project...", "projection=[Brightest Point] axis=Y-Axis slice="+depth+" initial=0 total=360 rotation=10 lower=1 upper=255 opacity=0 surface=0 interior=0 interpolate")
# selectWindow("Projections of "+title);
#saveAs("tiff", path+basename+"_Yproj");
#close();

#run("3D Project...", "projection=[Brightest Point] axis=X-Axis slice="+depth+" initial=0 total=360 rotation=10 lower=1 upper=255 opacity=0 surface=0 interior=0 interpolate")
# selectWindow("Projections of "+title);
#saveAs("tiff", path+basename+"_Xproj");
#close();


# get the threshold (set based on the original to avoid the black stuff, or ignore black
# intermodes, max entropy, renyi, yen on max
