#@ File    (label = "Input directory", style = "directory") srcFile
#@ File    (label = "Output directory", style = "directory") dstFile
#@ String  (label = "File extension", value=".nd2") ext
#@ String  (label = "File name contains", value = "") containString
#@ boolean (label = "Keep directory structure when saving", value = true) keepDirectories

# https://github.com/bioimage-analysis/find_close_peaks by Cedric Espenel, Stanford University
# updated by Theresa Swayne, Columbia University, 2022
# Supports different peak height by channel
# Saves results and log separately, plus ROI manager point selections


from ij import IJ, ImagePlus, ImageStack
from ij.plugin import ZProjector
from ij.plugin.filter import RankFilters
from ij.plugin.filter import BackgroundSubtracter
import net.imagej.ops
from net.imglib2.view import Views
from net.imglib2.img.display.imagej import ImageJFunctions as IL
from net.imglib2.algorithm.dog import DogDetection
from ij.gui import PointRoi
from jarray import zeros
from ij.measure import ResultsTable
from math import sqrt
from java.awt import Color
from ij.plugin.frame import RoiManager
from ij.gui import GenericDialog
import os
from loci.plugins import BF

def distance(peak_1, peak_2):
	return sqrt((peak_2[1] - peak_1[1]) * (peak_2[1] - peak_1[1]) + (peak_2[0] - peak_1[0]) * (peak_2[0] - peak_1[0]))

# edited for Xu Zhang's defaults
def getOptions():
	gd = GenericDialog("Options")
	gd.addNumericField("Channel_1", 4, 0)
	gd.addNumericField("Channel_2", 3, 0)
	gd.addNumericField("radius_background", 20, 0)
 	gd.addNumericField("sigmaSmaller", 2, 0)
 	gd.addNumericField("sigmaLarger", 9, 0)
  	gd.addNumericField("minPeakValueCh1", 300, 0)
  	gd.addNumericField("minPeakValueCh2", 600, 0)
  	gd.addNumericField("min_dist", 10, 0)
  	gd.showDialog()
	Channel_1 = gd.getNextNumber()
	Channel_2 = gd.getNextNumber()
	radius_background = gd.getNextNumber()
  	sigmaSmaller = gd.getNextNumber()
  	sigmaLarger = gd.getNextNumber()
  	minPeakValueCh1 = gd.getNextNumber()
  	minPeakValueCh2 = gd.getNextNumber()
  	min_dist = gd.getNextNumber()

  	return int(Channel_1), int(Channel_2), radius_background, sigmaSmaller, sigmaLarger, minPeakValueCh1, minPeakValueCh2, min_dist

def extract_channel(imp_max, Channel_1, Channel_2):

	stack = imp_max.getImageStack()
	ch_1 = ImageStack(imp_max.width, imp_max.height)
	ch_1.addSlice(str(Channel_1), stack.getProcessor(Channel_1))

	ch_2 = ImageStack(imp_max.width, imp_max.height)
	ch_2.addSlice(str(Channel_2), stack.getProcessor(Channel_2))

	ch1 = ImagePlus("Neuron" + str(Channel_1), ch_1)
	ch2 = ImagePlus("Glioma" + str(Channel_2), ch_2)

	ch1_1 = ch1.duplicate()
	ch2_1 = ch2.duplicate()

	ip1 = ch1_1.getProcessor().convertToFloat()
	ip2 = ch2_1.getProcessor().convertToFloat()

	return ip1, ip2


def back_subtraction(ip1, ip2, radius_background):
	bgs=BackgroundSubtracter()
	bgs.rollingBallBackground(ip1, radius_background, False, False, True, True, True)
	bgs.rollingBallBackground(ip2, radius_background, False, False, True, True, True)

	imp1 = ImagePlus("ch1 back sub", ip1)
	imp2 = ImagePlus("ch2 back sub", ip2)

	return imp1, imp2

def find_peaks(imp1, imp2, sigmaSmaller, sigmaLarger, minPeakValueCh1, minPeakValueCh2):
	# FIND PEAKS
	# sigmaSmaller ==> Size of the smaller dots (in pixels)
	# sigmaLarger ==> Size of the bigger dots (in pixels)
	# minPeakValue ==> Intensity above which to look for dots
	# Preparation Neuron channel
	ip1_1 = IL.wrapReal(imp1)
	ip1E = Views.extendMirrorSingle(ip1_1)
	imp1.show()

	#Preparation Glioma channel
	ip2_1 = IL.wrapReal(imp2)
	ip2E = Views.extendMirrorSingle(ip2_1)
	imp2.show()

	calibration = [1.0 for i in range(ip1_1.numDimensions())]
	extremaType = DogDetection.ExtremaType.MINIMA
	normalizedMinPeakValue = False

	dog_1 = DogDetection(ip1E, ip1_1, calibration, sigmaSmaller, sigmaLarger,
	  				   extremaType, minPeakValueCh1, normalizedMinPeakValue)

	dog_2 = DogDetection(ip2E, ip2_1, calibration, sigmaSmaller, sigmaLarger,
	  				   extremaType, minPeakValueCh2, normalizedMinPeakValue)

	peaks_1 = dog_1.getPeaks()
	peaks_2 = dog_2.getPeaks()

	return ip1_1, ip2_1, peaks_1, peaks_2


def process(srcDir, dstDir, currentDir, fileName, keepDirectories, Channel_1, Channel_2, radius_background, sigmaSmaller, sigmaLarger, minPeakValueCh1, minPeakValueCh2, min_dist):
 	IJ.run("Close All", "")

 	# Opening the image
 	IJ.log("Open image file:" + fileName)
 	#imp = IJ.openImage(os.path.join(currentDir, fileName))
	#imp = IJ.getImage()
	imp = BF.openImagePlus(os.path.join(currentDir, fileName))
	imp = imp[0]

	# getDimensions(width, height, channels, slices, frames)

	IJ.log("Computing Max Intensity Projection")

	if imp.getDimensions()[3] > 1:
		imp_max = ZProjector.run(imp,"max")
	else:
		imp_max = imp

	ip1, ip2 = extract_channel(imp_max, Channel_1, Channel_2)

	IJ.log("Subtract background")

	imp1, imp2 = back_subtraction(ip1, ip2, radius_background)

	IJ.log("Finding Peaks")

	ip1_1, ip2_1, peaks_1, peaks_2 = find_peaks(imp1, imp2, sigmaSmaller, sigmaLarger, minPeakValueCh1, minPeakValueCh2)

	# Create a PointRoi from the DoG peaks, for visualization
	roi_1 = PointRoi(0, 0)
	roi_2 = PointRoi(0, 0)
	roi_3 = PointRoi(0, 0)
	roi_4 = PointRoi(0, 0)

	# A temporary array of integers, one per dimension the image has
	p_1 = zeros(ip1_1.numDimensions(), 'i')
	p_2 = zeros(ip2_1.numDimensions(), 'i')


	# Load every peak as a point in the PointRoi
	for peak in peaks_1:
	  # Read peak coordinates into an array of integers
	  peak.localize(p_1)
	  roi_1.addPoint(imp1, p_1[0], p_1[1])

	for peak in peaks_2:
	  # Read peak coordinates into an array of integers
	  peak.localize(p_2)
	  roi_2.addPoint(imp2, p_2[0], p_2[1])

	# Chose minimum distance in pixel
	#min_dist = 20

	for peak_1 in peaks_1:
		peak_1.localize(p_1)
		for peak_2 in peaks_2:
			peak_2.localize(p_2)
			d1 = distance(p_1, p_2)
			if  d1 < min_dist:
				#roi_3.addPoint(imp1, p_2[0], p_2[1])
				roi_3.addPoint(imp1, p_1[0], p_1[1])
				break

	for peak_2 in peaks_2:
		peak_2.localize(p_2)
		for peak_1 in peaks_1:
			peak_1.localize(p_1)
			d2 = distance(p_2, p_1)
			if  d2 < min_dist:
				roi_4.addPoint(imp1, p_2[0], p_2[1])
				break

	cal = imp.getCalibration()
	min_distance = str(round((cal.pixelWidth * min_dist),1))

	table = ResultsTable()
	table.incrementCounter()
	table.addValue("Numbers of Neuron Markers", roi_1.getCount(0))
	table.addValue("Numbers of Glioma Markers", roi_2.getCount(0))
	table.addValue("Numbers of Glioma within %s um of Neurons" %(min_distance), roi_3.getCount(0))
	table.addValue("Numbers of Neurons within %s um of Glioma" %(min_distance), roi_4.getCount(0))
	#table.show("Results Analysis")
	saveDir = currentDir.replace(srcDir, dstDir) if keepDirectories else dstDir
	if not os.path.exists(saveDir):
		os.makedirs(saveDir)
	IJ.log("Saving to" + saveDir)
	table.save(os.path.join(saveDir, fileName + "_Results.csv"))
	IJ.selectWindow("Log")
	IJ.saveAs("Text", os.path.join(saveDir, fileName + "_Log.csv"));
	
	# save ROIs
	rm = RoiManager.getInstance()
	if not rm:
	  rm = RoiManager()
	rm.reset()

	rm.addRoi(roi_1)
	rm.addRoi(roi_2)
	rm.addRoi(roi_3)
	rm.addRoi(roi_4)

	rm.select(0)
	rm.rename(0, "ROI neuron")
	rm.runCommand("Set Color", "yellow")

	rm.select(1)
	rm.rename(1, "ROI glioma")
	rm.runCommand("Set Color", "blue")

	rm.select(2)
	rm.rename(2, "ROI glioma touching neurons")
	rm.runCommand("Set Color", "red")

	rm.select(3)
	rm.rename(3, "ROI neurons touching glioma")
	rm.runCommand("Set Color", "green")

	rm.runCommand(imp1, "Show All")
	
	rm.runCommand("Deselect")
	sel = rm.selected()
	tot = rm.getCount()
	IJ.log(str(sel) + " ROIs selected out of " + str(tot))
	rm.save(os.path.join(saveDir, fileName + "_rois.zip"))
	#rm.runCommand("save selected", os.path.join(folder, "temp.zip"))

	


def run():
  srcDir = srcFile.getAbsolutePath()
  dstDir = dstFile.getAbsolutePath()
  Channel_1, Channel_2, radius_background, sigmaSmaller, sigmaLarger, minPeakValueCh1, minPeakValueCh2, min_dist = getOptions()
  IJ.log("\\Clear")
  IJ.log("Processing batch Find_close_peaks")
  IJ.log("option used:" \
  		+ "\n" + "channel 1:" + str(Channel_1) \
  		+ "\n" + "channel 2:"+ str(Channel_2) \
  		+ "\n" + "Radius Background:"+ str(radius_background) \
  		+ "\n" + "Smaller Sigma:"+ str(sigmaSmaller) \
  		+ "\n" + "Larger Sigma:"+str(sigmaLarger) \
  		+ "\n" + "Min Peak Value for channel 1:"+str(minPeakValueCh1) \
  		+ "\n" + "Min Peak Value for channel 2:"+str(minPeakValueCh2) \
  		+ "\n" + "Min dist between peaks:"+str(min_dist))
  for root, directories, filenames in os.walk(srcDir):
    filenames.sort();
    for filename in filenames:
      # Check for file extension
      if not filename.endswith(ext):
        continue
      # Check for file name pattern
      if containString not in filename:
        continue
      process(srcDir, dstDir, root, filename, keepDirectories, Channel_1, Channel_2, radius_background, sigmaSmaller, sigmaLarger, minPeakValueCh1, minPeakValueCh2, min_dist)


run()
