import os, sys, time
from java.lang import Double, Integer
from ij import IJ, ImagePlus, ImageStack, Prefs
from ij.process import ImageProcessor, ImageConverter, LUT, ColorProcessor
from ij.io import FileSaver
from ij import WindowManager as WM
import ij.process
import ij.measure.Measurements
import ij.gui.Roi

def ColorBalance(imp):
	''' translation of BIOP Simple Color Balance bsh script'''
	# White Balance based on ROI
	
	# Get Current Image
	imp = IJ.getImage()
	
	# Make sure it is RGB
	if (imp.getType() != ImagePlus.COLOR_RGB):
		return

	#get ROI or make one if not available
	theRoi = imp.getRoi()
	if (theRoi == None):
		IJ.log("No ROI, making a square at (0,0) of width 65 px")
		imp.setRoi(0, 0, 65,65)

	#Remove ROI before duplication
	imp.killRoi()
	
	imp2 = imp.duplicate()
	imp2.setTitle("Color Balanced "+imp.getTitle())
	
	# Make a 3 slice stack
	ic = ImageConverter(imp2)
	ic.convertToRGBStack()
	imp2.setRoi(0, 0, 65,65)
	statOptions = Measurements.MEAN+Measurements.MEDIAN
	
	# Calculate mean/median of each color
	imp2.setPosition(1) #R
	isR = imp2.getStatistics(statOptions)
	imp2.setPosition(2) #G
	isG = imp2.getStatistics(statOptions)
	imp2.setPosition(3) #B
	isB = imp2.getStatistics(statOptions)
	
	#IJ.log("R:"+isR.mean+", G:"+isG.mean+", B:"+isB.mean)
	
	rgb = [isR.mean,isG.mean,isB.mean]
	
	# find largest value.
	maxVal = 0.0
	idx = -1

	for i in range(1,3):
		if (rgb[i] > maxVal):
			idx = i
			maxVal = rgb[i]
			scale = 255.0/maxVal
	
	# Remove ROI again to make sure we apply the multiplication to the whole image
	imp2.killRoi()
	
	for i in range (1,3):
		imp2.setPosition(i+1)
		ip = imp2.getProcessor()
		val = maxVal/rgb[i]*scale
		IJ.log(""+val+", "+rgb[i]+", "+maxVal)
		ip.multiply(maxVal/rgb[i]*scale) #Scaling the other channels to the largest one.
	
	# Convert it back
	ic = ImageConverter(imp2)
	ic.convertRGBStackToRGB()
	
	#Show the image
	imp2.show()
	
	return

imp = IJ.openImage("http://imagej.nih.gov/ij/images/leaf.jpg")
imp.show()
ColorBalance(imp)
