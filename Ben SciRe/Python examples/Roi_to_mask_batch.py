#@ File	(label = "Input directory", style = "directory") srcFile
#@ File	(label = "Output directory", style = "directory") dstFile
#@ String  (label = "Image file extension", value=".czi") ext
#@ String  (label = "File name contains", value = "") containString
#@ boolean (label = "Keep directory structure when saving", value = true) keepDirectories

# ROI_to_mask_batch.py
# Given a folder of ROI Manager sets (.roi) and multichannel single-slice images of the same name,
#   save the masks and a table of the mask areas

# ---- Import packages

from ij import IJ, ImagePlus, ImageStack
from ij.plugin import ZProjector
from ij.plugin.filter import RankFilters
import net.imagej.ops
from net.imglib2.view import Views
from net.imglib2.img.display.imagej import ImageJFunctions as IL
from jarray import zeros
import os
from loci.plugins import BF
from ij.process import ImageStatistics as IS
from ij.gui import Roi, PointRoi
from jarray import zeros
from ij.measure import ResultsTable
from math import sqrt
from java.awt import Color
from ij.plugin.frame import RoiManager
from ij.gui import GenericDialog

# ---- Define functions

def process(srcDir, dstDir, currentDir, fileName, keepDirectories, table):

	# setup
	IJ.run("Close All", "")
	rm = RoiManager.getInstance()
	if not rm:
		rm = RoiManager()
	rm.reset()

	# open the image
	IJ.log("Opening image file:" + fileName)
	#imp = IJ.openImage(os.path.join(currentDir, fileName))
	#imp = IJ.getImage()
	imp = BF.openImagePlus(os.path.join(currentDir, fileName))
	imp = imp[0]
	
	# add a line to the results table
	table.incrementCounter()
	table.addValue("Filename", fileName)

	# open the ROI set (assumes single roi)
	baseFileName = os.path.splitext(os.path.basename(fileName))[0]
	roiFileName = baseFileName + ".roi"
	IJ.log("Opening roi file:" + roiFileName)
	if not os.path.exists(os.path.join(currentDir, roiFileName)):
		IJ.log("ROI File does not exist!")
		table.addValue("Mask Area","NA")
		return
	rm.open(os.path.join(currentDir, roiFileName))
	
	# activate and measure the ROI
	rm.select(0);
	roi = imp.getRoi()
	rm.runCommand(imp,"Measure");
	stats = imp.getStatistics(IS.AREA)
	IJ.log("area: %s" %(stats.area))

	# Add to results table
	table.addValue("Mask Area",stats.area)

		
	# create the mask and show it
	rm.select(0);
	mask = imp.createRoiMask()
	maskImp = ImagePlus("Mask", mask)
	maskImp.show()
	
	# change values from 0,255 to 0,1 and display in a good LUT
	IJ.run(maskImp, "Divide...", "value=255");
	IJ.run(maskImp, "glasbey_inverted", "display=Mask")

	# Clear the area outside the ROI to avoid detecting background spots
	IJ.run(imp, "Clear Outside", "stack");

	# save the mask, results, log
	saveDir = currentDir.replace(srcDir, dstDir) if keepDirectories else dstDir
	if not os.path.exists(saveDir):
		os.makedirs(saveDir)
	IJ.log("Saving to" + saveDir)
	IJ.saveAs(imp, "Tiff", os.path.join(saveDir, baseFileName +".tif"))
	IJ.saveAs(maskImp, "Tiff", os.path.join(saveDir, baseFileName +"_Mask.tif"))
	table.save(os.path.join(saveDir, baseFileName + "_MaskArea.csv"))
	table.save(os.path.join(saveDir, "merged MaskAreas.csv"))
	IJ.selectWindow("Log")
	IJ.saveAs("Text", os.path.join(saveDir, "Masks_Log.txt"));


def run():

	srcDir = srcFile.getAbsolutePath()
	dstDir = dstFile.getAbsolutePath()

	IJ.log("\\Clear")
	IJ.run("Clear Results", "");
	IJ.log("Processing batch ROI masking")
	
	table = ResultsTable()
	
	# Traverse directories
	for root, directories, filenames in os.walk(srcDir):
		filenames.sort();
		for filename in filenames:
			# Check for file extension
			if not filename.endswith(ext):
				continue
			# Check for file name pattern
			if containString not in filename:
				continue
			#process(srcDir, dstDir, root, filename, keepDirectories, Channel_1, Channel_2, radius_background, sigmaSmaller, sigmaLarger, minPeakValueCh1, minPeakValueCh2, min_dist)
			
			# Add to results table

			
			process(srcDir, dstDir, root, filename, keepDirectories, table)
	
	
		IJ.log("Done")

# ---- Run

run()