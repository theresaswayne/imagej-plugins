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
	gd.addStringField("Name of first channel: ", "Live")
	gd.addStringField("Name of second channel: ", "Dead")
	gd.addNumericField("Channel number for first channel", 1, 0)
	gd.addNumericField("Channel number for second channel", 2, 0)
	gd.addNumericField("Radius", 4, 1)
	gd.addNumericField("Threshold for first channel", 10, 0)
	gd.addNumericField("Threshold for second channel", 10, 0)
	gd.showDialog()
	ch1Name = gd.getNextString()
	ch2Name = gd.getNextString()
	Channel_1 = gd.getNextNumber()
	Channel_2 = gd.getNextNumber()
	radius = gd.getNextNumber()
	minPeakValueCh1 = gd.getNextNumber()
	minPeakValueCh2 = gd.getNextNumber()
	
	return ch1Name, ch2Name, int(Channel_1), int(Channel_2), radius, minPeakValueCh1, minPeakValueCh2

def extract_channel(imp_max, ch1Name, ch2Name, Channel_1, Channel_2):
	
	stack = imp_max.getImageStack()
	ch_1 = ImageStack(imp_max.width, imp_max.height)
	ch_1.addSlice(str(Channel_1), stack.getProcessor(Channel_1))
	
	ch_2 = ImageStack(imp_max.width, imp_max.height)
	ch_2.addSlice(str(Channel_2), stack.getProcessor(Channel_2))
	
	ch1 = ImagePlus(ch1Name + str(Channel_1), ch_1)
	ch2 = ImagePlus(ch2Name + str(Channel_2), ch_2)
	
	ch1_1 = ch1.duplicate()
	ch2_1 = ch2.duplicate()
	
	ip1 = ch1_1.getProcessor().convertToFloat()
	ip2 = ch2_1.getProcessor().convertToFloat()
	
	return ip1, ip2



def find_peaks(imp, radius, minPeakValue):
	
	# Set the parameters for DogDetector
	img = IL.wrap(imp)
	interval = img
	cal = imp.getCalibration()
	calibration = [cal.pixelWidth, cal.pixelHeight, cal.pixelDepth]
	#radius = 6
	threshold = minPeakValue
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
		
		# Loop through all the peak that were found
		for peak in peaks:
			# Print the current coordinates
			IJ.log(str(peak.getDoublePosition(0)) + "," + str(peak.getDoublePosition(1)) + "," +  str(peak.getDoublePosition(2)) + "\n")
			# Add the current peak to the Roi manager
			proi = PointRoi(peak.getDoublePosition(0) / cal.pixelWidth, peak.getDoublePosition(1) / cal.pixelHeight)
			proi.setPosition(int(peak.getDoublePosition(2) / cal.pixelDepth))
			rm.addRoi(proi)
		# Show all ROIs on the image
		rm.runCommand(imp, "Show All")
		
	else:
		print "The detector could not process the data."
	return peaks, rm


def process(srcDir, dstDir, currentDir, fileName, keepDirectories, ch1Name, ch2Name, Channel_1, Channel_2, radius, minPeakValueCh1, minPeakValueCh2):
	IJ.run("Close All", "")
	
	# Opening the image
	IJ.log("Opening image file: " + currentDir + "/" + fileName)
	imp = IJ.openImage(os.path.join(currentDir, fileName))
	#imp = IJ.getImage()
	#imp = BF.openImagePlus(os.path.join(currentDir, fileName))
	#imp = imp[0]
	
	IJ.log("Extracting channels")
	ip1, ip2 = extract_channel(imp, ch1Name, ch2Name, Channel_1, Channel_2)
	
	#imp1, imp2 = back_subtraction(ip1, ip2, radius_background)
	imp1 = ImagePlus(ch1Name, ip1)
	imp2 = ImagePlus(ch2Name, ip2)
	
	saveDir = currentDir.replace(srcDir, dstDir) if keepDirectories else dstDir
	if not os.path.exists(saveDir):
		os.makedirs(saveDir)
	IJ.log("Saving to" + saveDir)
	
	IJ.log("Finding peaks in first channel")
	peaks_1, rm = find_peaks(imp1, radius, minPeakValueCh1)
	
	#rm = RoiManager.getInstance()
	rm.runCommand("Deselect")
	rm.save(os.path.join(saveDir, fileName + "_ChArois.zip"))
	rm.reset()
	
	IJ.log("Finding peaks in second channel")
	peaks_2, rm = find_peaks(imp2, radius, minPeakValueCh2)
	#rm = RoiManager.getInstance()
	rm.runCommand("Deselect")
	rm.save(os.path.join(saveDir, fileName + "_ChBrois.zip"))
	rm.reset()
	
	IJ.selectWindow("Log")
	IJ.saveAs("Text", os.path.join(saveDir, "Peaks_Log.txt"))

def run():
	srcDir = srcFile.getAbsolutePath()
	dstDir = dstFile.getAbsolutePath()
	ch1Name, ch2Name, Channel_1, Channel_2, radius, minPeakValueCh1, minPeakValueCh2 = getOptions()

	IJ.log("\\Clear")
	IJ.log("Processing batch")
	IJ.log("options used:" \
		+ "\n" + "channel 1:" + ch1Name + ", " + str(Channel_1) \
		+ "\n" + "channel 2:"+ ch2Name+ ", "+ str(Channel_2) \
		+ "\n" + "Radius in um:"+ str(radius) \
		+ "\n" + "Min Peak Value for channel 1:"+str(minPeakValueCh1) \
		+ "\n" + "Min Peak Value for channel 2:"+str(minPeakValueCh2))
		
	for root, directories, filenames in os.walk(srcDir):
		filenames.sort()
	for filename in filenames:
		# Check for file extension
		if not filename.endswith(ext):
			continue
		# Check for file name pattern
		if containString not in filename:
			continue
		process(srcDir, dstDir, root, filename, keepDirectories, ch1Name, ch2Name, Channel_1, Channel_2, radius, minPeakValueCh1, minPeakValueCh2)
	IJ.log("Finished.")

run()


