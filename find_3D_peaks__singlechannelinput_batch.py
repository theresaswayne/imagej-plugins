#@ File (label = "Input directory", style = "directory") srcFile
#@ File (label = "Output directory", style = "directory") dstFile
#@ String (label = "File extension", value=".tif") ext
#@ String (label = "File name contains", value = "") containString
#@ boolean (label = "Keep directory structure when saving", value = true) keepDirectories

# Based on https://imagej.net/scripting/jython/examples
# adapted by Theresa Swayne, Columbia University, 2025
# Saves results, log, and ROI manager point selections

# uses https://imagej.net/plugins/trackmate/detectors/difference-of-gaussian 
# KNOWN ISSUES: There is no ROIset saved if there is only 1 peak
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
from loci.plugins.in import ImporterOptions
from ij.measure import ResultsTable
from ij.plugin import Duplicator

def getOptions():
	gd = GenericDialog("Peak Options")
	gd.addNumericField("Radius", 10, 1)
	gd.addNumericField("Quality threshold", 100, 0)
	gd.showDialog()
	radius = gd.getNextNumber()
	qualityThresh = gd.getNextNumber()
	
	return radius, qualityThresh

def find_peaks(imp, radius, qualityThresh):
	
	# Set the parameters for DogDetector
	
	img = IL.wrap(imp)
	interval = img
	cal = imp.getCalibration()
	calibration = [cal.pixelWidth, cal.pixelHeight, cal.pixelDepth]
	#IJ.log("Calibration:" + str(calibration))
	#print(calibration)
	#radius = 6
	threshold = qualityThresh
	doSubpixel = False
	doMedian = False
	
	# Setup spot detector
	# (see http://javadoc.imagej.net/Fiji/fiji/plugin/trackmate/detection/DogDetector.html)
	detector = DogDetector(img, interval, calibration, radius, threshold, doSubpixel, doMedian)
	
	# set up a table for coordinates
	peaksTable = ResultsTable()
	
	# Start processing and display the results
	if detector.process():
		# Get the list of peaks found
		peaks = detector.getResult()
		
		# Add points to ROI manager
		rm = RoiManager.getInstance()
		if not rm:
			rm = RoiManager()
		
		rm.reset()
		
		# Loop through all the peaks that were found
		roiIndex = 0
		for peak in peaks:
			
			# Store the coordinates
			peaksTable.incrementCounter()
	  		peaksTable.addValue("X microns",peak.getDoublePosition(0))
	 		peaksTable.addValue("Y microns",peak.getDoublePosition(1))
	 		peaksTable.addValue("Z microns",peak.getDoublePosition(2))
	 		
			# Print the coordinates
			#IJ.log("absolute peak position " + str(peak.getDoublePosition(0)) + "," + str(peak.getDoublePosition(1)) + "," +  str(peak.getDoublePosition(2)) + "\n")
			
			calX = int(peak.getDoublePosition(0) / cal.pixelWidth)
			calY = int(peak.getDoublePosition(1) / cal.pixelHeight)
			calZ = int(peak.getDoublePosition(2) / cal.pixelDepth)
			
			peaksTable.addValue("X pixels",calX)
	 		peaksTable.addValue("Y pixels",calY)
	 		peaksTable.addValue("Z slice",calZ)
	 		
			#IJ.log("calibrated peak position " + str(calX) + "," + str(calY) + "," +  str(calZ) + "\n")
			
			# Add the current peak to the Roi manager and link it to the relevant slice
			proi = PointRoi(calX, calY)
			proi.setPosition(calZ)
			imp.setSlice(calZ)
			imp.show() # slow but may be needed
			rm.addRoi(proi)
			
			rm.select(roiIndex)
			# this requires a single channel image
			#print("Setting position of ROI",str(roiIndex), " at ", str(calZ))
			rm.setPosition(calZ)
			rm.runCommand(imp,"Update")
			rm.deselect()
			roiIndex = roiIndex + 1
			
		# Show all ROIs on the image
		#rm.runCommand(imp, "Show All")	
		
	else:
		print "The detector could not process the data."
	return peaks, rm, peaksTable


def process(srcDir, dstDir, currentDir, fileName, keepDirectories, radius, qualityThresh):
	IJ.run("Close All", "")
	
	# Opening the image
	#IJ.log("Opening image file: " + currentDir + "/" + fileName)
	imp = IJ.openImage(os.path.join(currentDir, fileName))

	saveDir = currentDir.replace(srcDir, dstDir) if keepDirectories else dstDir
	if not os.path.exists(saveDir):
		os.makedirs(saveDir)
	#IJ.log("Saving to" + saveDir)
	
	#IJ.log("Finding peaks")
	peaks, rm, peaksTable = find_peaks(imp, radius, qualityThresh)

	if rm.getCount() != 0:
		rm.runCommand("Deselect")
		roiName = fileName + "_ROIs.zip"
		rm.save(os.path.join(saveDir, roiName))
		rm.reset()

	tableName = fileName + "_coordinates.txt"
	peaksTable.save(os.path.join(saveDir, tableName))
	
	IJ.log(fileName + "\t" + str(len(peaks)))


def run():
	srcDir = srcFile.getAbsolutePath()
	dstDir = dstFile.getAbsolutePath()
	radius, qualityThresh = getOptions()

	IJ.log("\\Clear")
	IJ.log("Processing batch in" + srcDir)
	IJ.log("Options used:" \
		+ "\n" + "Radius in um:"+ str(radius) \
		+ "\n" + "Quality threshold:"+str(qualityThresh))
	IJ.log("Peak totals:")
		
	for root, directories, filenames in os.walk(srcDir):
		filenames.sort()
	for filename in filenames:
		# Check for file extension
		if not filename.endswith(ext):
			continue
		# Check for file name pattern
		if containString not in filename:
			continue
		# Check for dotfile on Mac
		if filename.startswith("."):
			continue
		process(srcDir, dstDir, root, filename, keepDirectories, radius, qualityThresh)
		
	IJ.log("Finished.")
	
	# save log
	IJ.selectWindow("Log")
	IJ.saveAs("Text", os.path.join(dstDir, "Log.txt"))
	
	# clean up
	IJ.run("Close All", "")

run()


