#@ File (label = "Input directory", style = "directory") srcFile
#@ File (label = "Output directory", style = "directory") dstFile
#@ String (label = "File ex)ension", value=".tif") ext
#@ String (label = "File name contains", value = "") containString
#@ boolean (label = "Keep directory structure when saving", value = true) keepDirectories

# Based on https://imagej.net/scripting/jython/examples
# adapted by Theresa Swayne, Columbia University, 2025
# Saves results, log, and ROI manager point selections

# uses https://imagej.net/plugins/trackmate/detectors/difference-of-gaussian 
# KNOWN ISSUES: An erroneous point may be added to the ROI and counts at (0,0) due to the initialization of the PointROI
# TODO: Option for background subtraction, subpixel localization, merge results files

from fiji.plugin.trackmate.detection import DogDetector
from ij.gui import PointRoi
from ij.plugin.frame import RoiManager
import os
from ij import IJ, ImagePlus, ImageStack
from ij.plugin.filter import RankFilters
import net.imagej.ops
from net.imglib2.view import Views
from net.imglib2.img.display.imagej import ImageJFunctions as IL
from net.imglib2.algorithm.dog import DogDetection
from ij.gui import GenericDialog
from loci.plugins import BF

def getOptions():
	gd = GenericDialog("Options")
	gd.addStringField("Name of channel: ", "Live")
	gd.addNumericField("Channel number", 1, 0)
	gd.addNumericField("Radius", 4, 1)
	gd.addNumericField("Quality threshold", 1, 0)
	gd.showDialog()
	chName = gd.getNextString()
	Channel_Num = gd.getNextNumber()
	radius = gd.getNextNumber()
	qualityThresh = gd.getNextNumber()
	
	return chName, int(Channel_Num), radius, qualityThresh

def extract_channel(imp_, chName, Channel_Num):
	
	stack = imp_.getImageStack()
	channel = ImageStack(imp_.width, imp_.height)
	channel.addSlice(str(Channel_Num), stack.getProcessor(Channel_Num))
	
	chan = ImagePlus(chName + str(Channel_Num), channel)
	
	chan1 = chan.duplicate()
	
	ip = chan1.getProcessor().convertToFloat()
	
	return ip


def find_peaks(imp, Channel_Num, radius, qualityThresh):
	
	# Set the parameters for DogDetector
	img = IL.wrap(imp)
	interval = img
	cal = imp.getCalibration()
	calibration = [cal.pixelWidth, cal.pixelHeight, cal.pixelDepth]
	#print(calibration)
	#radius = 6
	threshold = qualityThresh
	doSubpixel = False
	doMedian = False
	
	# Setup spot detector
	# (see http://javadoc.imagej.net/Fiji/fiji/plugin/trackmate/detection/DogDetector.html)
	detector = DogDetector(img, interval, calibration, radius, threshold, doSubpixel, doMedian)
	
	# Start processing and display the results
	if detector.process():
		# Get the list of peaks found
		peaks = detector.getResult()
		IJ.log(str(len(peaks)) + " peaks were found.")
	
		# Add points to ROI manager
		rm = RoiManager.getInstance()
		if not rm:
			rm = RoiManager()
		
		rm.reset()
		
		# Loop through all the peaks that were found
		for peak in peaks:
			roiIndex = 0
			# Print the current coordinates
			IJ.log(str(peak.getDoublePosition(0)) + "," + str(peak.getDoublePosition(1)) + "," +  str(peak.getDoublePosition(2)) + "\n")
			# Add the current peak to the Roi manager
			proi = PointRoi(peak.getDoublePosition(0) / cal.pixelWidth, peak.getDoublePosition(1) / cal.pixelHeight)
			rm.addRoi(proi)
			rm.select(roiIndex)
			# position is c, z, t
			roiSlice = int(peak.getDoublePosition(2) / cal.pixelDepth)
			rm.setPosition(Channel_Num, roiSlice, 1)
			rm.deselect()
			roiIndex += 1
		# Show all ROIs on the image
		#rm.runCommand(imp, "Show All")	
		
	else:
		print "The detector could not process the data."
	return peaks, rm


def process(srcDir, dstDir, currentDir, fileName, keepDirectories, chName, Channel_Num, radius, qualityThresh):
	IJ.run("Close All", "")
	
	# Opening the image
	IJ.log("Opening image file: " + currentDir + "/" + fileName)
	imp = IJ.openImage(os.path.join(currentDir, fileName))
	#imp = IJ.getImage()
	#imp = BF.openImagePlus(os.path.join(currentDir, fileName))
	#imp = imp[0]
	
	IJ.log("Extracting channel")
	ip1 = extract_channel(imp, chName, Channel_Num)
	
	#imp1, imp2 = back_subtraction(ip1, ip2, radius_background)
	imp1 = ImagePlus(chName, ip1)
	
	saveDir = currentDir.replace(srcDir, dstDir) if keepDirectories else dstDir
	if not os.path.exists(saveDir):
		os.makedirs(saveDir)
	IJ.log("Saving to" + saveDir)
	
	IJ.log("Finding peaks")
	peaks, rm = find_peaks(imp1, Channel_Num, radius, qualityThresh)


	#rm = RoiManager.getInstance()
	rm.runCommand("Deselect")
	roiName = fileName + "_" + chName + "_ROIs.zip"
	rm.save(os.path.join(saveDir, roiName))
	rm.reset()
	
	IJ.selectWindow("Log")
	logName = fileName + "_" + chName + "_Log.txt"
	IJ.saveAs("Text", os.path.join(saveDir, logName))

def run():
	srcDir = srcFile.getAbsolutePath()
	dstDir = dstFile.getAbsolutePath()
	chName, Channel_Num, radius, qualityThresh = getOptions()

	IJ.log("\\Clear")
	IJ.log("Processing batch")
	IJ.log("options used:" \
		+ "\n" + "channel:" + chName + ", " + str(Channel_Num) \
		+ "\n" + "Radius in um:"+ str(radius) \
		+ "\n" + "Quality threshold:"+str(qualityThresh))
		
	for root, directories, filenames in os.walk(srcDir):
		filenames.sort()
	for filename in filenames:
		# Check for file extension
		if not filename.endswith(ext):
			continue
		# Check for file name pattern
		if containString not in filename:
			continue
		process(srcDir, dstDir, root, filename, keepDirectories, chName, Channel_Num, radius, qualityThresh)
	IJ.log("Finished.")

run()


