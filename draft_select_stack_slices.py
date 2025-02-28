#@ File(label = "Input folder:", style = "directory") inDir
#@ File(label = "Output folder:", style = "directory") outDir
#@ String(label="Image File Extension", required=false, value=".tif") image_extension
#@ String  (label = "File name contains", value = "") containString
#@ int(label = "# of samples per stack:",style = "spinner") numSamples

# select_stack_slices.py
# Theresa Swayne, 2024
# From a folder of multichannel stacks, saves a designated number of uniformly spaced (multichannel) slices from each 
# Useful for generating training images for cellpose training


# TO USE: Run the macro and specify folders for input and output, and select the # samples to take.
# Limitations: Assumes that the input should be a 2D + T stack (no Z). Z will be converted to T if needed.

# ---- Setup ----

import os
import math
import io
from net.imglib2.view import Views
from ij import IJ, ImagePlus, ImageStack, plugin
from ij.process import ImageProcessor, FloatProcessor, StackProcessor
import string
from ij.plugin import Duplicator


# Find image files
inputdir = str(inDir) # convert the directory object into a string
outputdir = str(outDir)
fnames = [] # empty array for filenames

for fname in os.listdir(inputdir):
	if fname.startswith("."): # avoid dotfiles that have the extension and filename filter
		continue
	if fname.endswith(image_extension):
		fnames.append(fname) # add matching files to the array

fnames = sorted(fnames) # sort the file names

if len(fnames) < 1: # no files
	raise Exception("No image files found in %s" % inputdir)

print "Processing",str(len(fnames)), "images and retrieving",numSamples,"from each one"

# Loop through files

for fname in fnames:
	currentFile = os.path.basename(fname)
	print "Processing file:",currentFile
	imp = IJ.openImage(os.path.join(inputdir, fname)) # open  image
	stack = imp.getStack()
	slices = stack.getNSlices()
	frames = stack.getNFrames()
	#stack.getDimensions(width, height, channels, slices, frames)

	# fix Z/T confusion for future analysis
	if slices > 1:
		print "Re-ordering"
		IJ.run("Re-order Hyperstack ...", "channels=[Channels (c)] slices=[Frames (t)] frames=[Slices (z)]")
		# get the new numbers
		#stack.getDimensions(width, height, channels, slices, frames)
		slices = stack.getNSlices()
		frames = stack.getNFrames()
	else:
		print "No need to re-order"
	
	for i in range(0, numSamples):
		print "Collecting", str(numSamples), "frames from a total of", str(frames), "frames"
		frameNum = math.floor(i * (frames/numSamples)) + 1 # frames start at 1
		impFrame = Duplicator().run(stack, 1, channels, 1, 1, frameNum, frameNum)
		basename = currentFile[0:-4] # assumes .tif
		# todo: format with leading zeroes
		fileName = string.join((basename, str(frameNum), image_extension), "_")
		print "Saving image",str(i),"with name", fileName
		IJ.save(impFrame, os.path.join(outputdir, fileName))
		
	# --- end frame loop
	
# --- end folder loop 
	

print "Finished"

