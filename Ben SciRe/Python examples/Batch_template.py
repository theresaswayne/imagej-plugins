#@ File(label="Input directory", style="directory") inputDir
#@ File(label="Output directory", style="directory") outputDir
#@ String	(label = "File extension", value=".tif") ext
#@ String	(label = "File name contains", value = "crop") containString

# ImageJ Jython script template for batch processing

# Tip: Use the script parameters above to gather global variables without having to code dialogs
# ---- more info: https://imagej.net/scripting/parameters

# ---- IMPORTS
# Place additional imports here as needed

from ij import IJ, ImagePlus, ImageStack
from ij.plugin import ChannelSplitter
import os

# --- FUNCTION DEFINITIONS
# --- Why functions?: https://medium.com/@nicolaisafai/re-factor-to-make-your-code-more-understandable-2697af65789c

# --- This batch file processor includes 2 basic functions:
# 		1) "run": traverses the input directory
#		2) "process": executes the actual job of the script,
#			including calling additional functions if desired

def run():
	""" Walk through the directory and identify files matching our criteria """

	# Setup
	IJ.run("Close All", "") # close all open windows
	IJ.log("\\Clear") # clear the ImageJ log
	
	IJ.log("Beginning batch processing")
	
	# Convert user-selected directories into Python paths
	srcDir = inputDir.getAbsolutePath()
	tarDir = outputDir.getAbsolutePath()
	
	# Loop through directories and sub-directories
	for root, directories, filenames in os.walk(srcDir):
		filenames.sort();
		for filename in filenames:
			IJ.log("Checking file " + filename)
			# Check for file extension
			# The string ext is defined in the script parameters
			if not filename.endswith(ext):
				continue
			# Check for file name pattern
			# The string containString is defined in the script parameters
			if containString not in filename:
				continue
			# Process the file
			process(srcDir, tarDir, root, filename)
			
	IJ.log("Done")


def process(srcDir, tarDir, root, filename):
	""" Run processing functions on a file and save output """

	IJ.log("Processing " + filename)
	
	# Get the image path
	imagePath = os.path.join(srcDir, filename)
	
	# Open the image as an ImagePlus
	imp = IJ.openImage(imagePath)
	
	# INSERT YOUR PROCESSING STEPS OR FUNCTIONS HERE

	# Run a sample function on the ImagePlus
	imp = dummyFunction(imp)
	
	# Save output
	newFilename = "Colorized_" + filename
	targetPath = os.path.join(tarDir, newFilename) #tarDir defined in script parameters
	IJ.log("Saving output for " + filename)
	IJ.saveAs(imp, "Tiff", targetPath)
	imp.close()
	return

def dummyFunction(imp):

	""" 
	Invert the image, apply the Fire LUT, and convert to RGB 

	Parameters:
        imp (ImagePlus): The image to be processed. Can be single slice or stack.

    Returns:
        imp (ImagePlus): The converted image.
    """
    
	IJ.run(imp, "Invert", "")
	IJ.run(imp, "Fire", "")
	IJ.run(imp, "RGB Color", "")

	return imp

# ---- THIS IS THE ACTUAL SCRIPT LOL
run()



