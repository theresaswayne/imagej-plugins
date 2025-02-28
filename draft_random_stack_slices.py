#@ File(label = "Input folder:", style = "directory") inDir
#@ File(label = "Output folder:", style = "directory") outDir
#@ String(label="Image File Extension", required=false, value=".tif") image_extension
#@ String  (label = "File name contains", value = "") containString
#@ int(label = "# of samples per stack:",style = "spinner") numSamples

# random_stack_slices.py
# Theresa Swayne, 2024
# From a folder of multichannel stacks, saves a designated number of (multichannel) slices from each 
# Useful for generating training images for cellpose training
# note that the start point is randomly selected but the slices are uniformly spaced after that

# TO USE: Run the macro and specify folders for input and output, and select the # samples to take.


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

print "Processing",len(fnames), "images and retrieving",numSamples,"from each one"

# Loop through files

for fname in fnames:

	
	currentFile = os.path.basename(fname)
	print "Processing file:",currentFile
	
	imp = IJ.openImage(os.path.join(inputdir, fname)) # open  image
	ip = imp.getProcessor()
	
	# get slices, frames, etc
	# calculate the gap between samples based on the number of samples requested (e.g. if n = 3, then the gap is  
	# calculate the available range over which to pick the first slice
	# randomly select the 1st slice
	# loop 
	basename = currentFile[0:-8] # assumes 3-digit timepoint plus .tif
	fileName = string.join((basename, image_extension), "")
	print "Saving stack",stackIndex,"with name", fileName
	stackImp = ImagePlus(fileName, new_stack) # generate an ImagePlus from the stack
	IJ.save(stackImp, os.path.join(outputdir, fileName))  #... so we can save it
	# --- end folder loop 
	


print "Finished"

