#@ File(label = "Input folder:", style = "directory") inDir
#@ File(label = "Output folder:", style = "directory") outDir
#@ String(label="Image File Extension", required=false, value=".tif") image_extension
#@ int(label = "# of timepoints:",style = "spinner") numTimepoints

# stack_cytation_images.py
# Theresa Swayne, 2024
# Generates stacks from individual positions and channels within a Cytation experiment where all images are in the same folder 

# TO USE: Run the macro and specify folders for input and output, and select the # timepoints.
# The macro loads files in groups of n where n is the number of timepoints. 
# So all files in the experiment must be in the folder. There can be no partial groups.

# ---- Setup ----

import os
import math
import io
from net.imglib2.view import Views
from ij import IJ, ImagePlus, ImageStack
from ij.process import ImageProcessor, FloatProcessor, StackProcessor
import string

# Find image files
inputdir = str(inDir) # convert the directory object into a string
outputdir = str(outDir)
fnames = [] # empty array for filenames
for fname in os.listdir(inputdir):
	if fname.endswith(image_extension):
		fnames.append(os.path.join(inputdir, fname)) # add matching files to the array
fnames = sorted(fnames) # sort the file names

if len(fnames) < 1: # no files
	raise Exception("No image files found in %s" % inputdir)

# Calculate number of datasets and check for errors

numStacks = len(fnames)/numTimepoints
if len(fnames) % numTimepoints != 0: # not an even multiple
	raise Exception("Wrong number of image files found in %s" % inputdir)

print "Processing",len(fnames), "images into",numStacks,"stacks with",numTimepoints,"timepoints"

# Open and stack images

for stackIndex in range(0,numStacks):

	imageStartIndex = stackIndex * numTimepoints # 0 for the first one
	imageEndIndex = imageStartIndex + numTimepoints # 0 through 25 if there are 25 timepoints
	print "Creating stack", stackIndex, "from images",imageStartIndex,"to",imageEndIndex
	
	currentFile = os.path.basename(fnames[imageStartIndex])
	print "First filename:",currentFile
	
	imp = IJ.openImage(os.path.join(inputdir, fnames[imageStartIndex])) # open first image
	ip = imp.getProcessor()
	new_stack = ImageStack(imp.width, imp.height) # new stack with size based on the image
	new_stack.addSlice(currentFile, ip) # add the 1st image to the stack
	
	for fnameIndex in range(imageStartIndex + 1, imageEndIndex): # subset of the original array
		currentFile = os.path.basename(fnames[fnameIndex])
		print "Adding image",currentFile
		imp = IJ.openImage(os.path.join(inputdir, currentFile)) # open next image
		ip = imp.getProcessor()
		new_stack.addSlice(currentFile, ip) # slice label is orig file name
		# --- end stack creation loop
	
	basename = currentFile[0:-8] # assumes 3-digit timepoint plus .tif
	fileName = string.join((basename, image_extension), "")
	print "Saving stack",stackIndex,"with name", fileName
	stackImp = ImagePlus(fileName, new_stack) # generate an ImagePlus from the stack
	IJ.save(stackImp, os.path.join(outputdir, fileName))  #... so we can save it
	# --- end folder loop 
	


print "Finished"

