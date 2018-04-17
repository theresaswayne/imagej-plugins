#@File(label = "Input image", style = "file") inputImage
#@File(label = "Input ROIs", style = "file") ROIset


# profile_FWHM.py
# for testing curve fitting and fwhm calculation on actin cable profiles

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


# ---- SETUP

# make paths into strings
input_ = str(inputImage)
rois_ = str(ROIset)

# get image and ROI info
imp = IJ.openImage(input_)
imp.show() # required for profile plotting
imageWindow = WindowManager.getCurrentWindow()
imageName = imp.getTitle()
baseName = os.path.splitext(imageName)[0]

imageCalib = imp.getCalibration()
pixSize = imageCalib.pixelHeight # assuming in microns

rm = get_roi_manager(new=True) # reset the ROI mgr
rm.runCommand("Open",rois_)

# loop through ROIs in manager

numROIs = rm.getCount()

for roiIndex in range(0, numROIs): # TESTING: limited range  

	# only pick ones that contain a hyphen (the cross profiles)
	if "-"	in rm.getName(roiIndex):

		print("ROI number " + str(roiIndex) + " has a hyphen: " + rm.getName(roiIndex))

		WindowManager.setCurrentWindow(imageWindow)

		# get the profile data
		rm.select(roiIndex)
		roiPlot = ProfilePlot(imp)
		profileValues = roiPlot.getProfile() # a double array
		profileXVals = roiPlot.getPlot().getXValues()
		# plotName = baseName + "_" + rm.getName(roiIndex)
		plotName = baseName + "_" + rm.getName(roiIndex)
		print("now plotting " + plotName)
		roiPlot.createWindow()
		myPlot = WindowManager.getCurrentWindow()
		# POSSIBLE BUG -- sometimes misses renaming
		myPlot.setTitle(plotName)

		# do the fit
		# check if fit was successful (R2 or status?)
		# retrieve the r2, parameters
		# calculate fwhm (assuming gaussian)
		# report/save results

		rm.deselect()

	else:
		print("ROI number " + str(roiIndex) + " does NOT have a hyphen: " + rm.getName(roiIndex))




print("Done")


