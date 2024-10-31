#@ File(label = "Input folder:", style = "directory") inDir
#@ File(label = "Output folder:", style = "directory") outDir
#@ String(label="Image File Extension", required=false, value=".tif") image_extension
#@ int(label = "# of timepoints:",style = "slider", min=1, max = 100) numTimepoints

#@OUTPUT Dataset output

#@ DatasetService ds
#@ DatasetIOService io

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
	
	currentFile = fnames[imageStartIndex]
	print "First filename:",currentFile
	
	imp = IJ.openImage(os.path.join(inputdir, fnames[imageStartIndex])) # open first image
	ip = imp.getProcessor()
	new_stack = ImageStack(imp.width, imp.height) # new stack with size based on the image
	new_stack.addSlice(currentFile, ip) # add the 1st image tothe stack

	for fnameIndex in range(imageStartIndex + 1, imageEndIndex): # subset of the original array
		#data = io.open(fnames[fnameIndex])
		currentFile = fnames[fnameIndex]
		print "Adding image",currentFile
		imp = IJ.openImage(os.path.join(inputdir, currentFile)) # open next image
		ip = imp.getProcessor()
		new_stack.addSlice(currentFile, ip) # slice label is orig file name
		#IJ.run("Image Sequence...", "open=inDir number=11 starting=i sort"); 
		# --- end stack creation loop

		#stack.append(data)

	#output = Views.stack(stack)
	#output = ds.create(output)

	# TODO: make this based on the basename of the 1st fname
	fileName = string.join(("Stack",str(stackIndex), image_extension), "_")
	print "Saving stack",stackIndex,"with name", fileName	
	# output.setName(os.path.basename(inputdir) + image_extension) 
	stackImp = ImagePlus(fileName, new_stack) # generate an ImagePlus from the stack
	IJ.save(stackImp, os.path.join(outputdir, fileName))  #... so we can save it
	# --- end folder loop 
	
	# output.setName(os.path.basename(inputdir) + image_extension)

print "Finished"
#
#while (nImages>0) { // clean up open images
#	selectImage(nImages);
#	close();
#}
#
#
#setBatchMode(true); // faster performance
#//run("Bio-Formats Macro Extensions"); // support native microscope files
#
#
#// ---- Run ----
#
#// get number of images
#
#list = getFileList(inputDir);
#list = Array.sort(list);
#numFiles = list.length; // note it could include some extra files like DS Store
#numStacks = floor(numFiles/numTimepoints);
#print("The folder contains",numFiles,"files that will be made into",numStacks,"of",numTimepoints,"timepoints.");
#
#
#// Open files by start and count
#
#// TODO: Loop over numStacks
#
#File.openSequence(inputDir, "start=26 step=1 count=25 scale=50");
#
#
#// ALT: open image by file list index
#// ALT: open using this command from a few years ago 	
#// run("Image Sequence...", "open=inDir number=11 starting=i sort"); //read images and make stacks
#
#// get image info
#
#id = getImageID();
#title = getTitle(); // TODO -- get actual image name -- better done with the array
#dotIndex = indexOf(title, ".");
#baseEnd = dotIndex-4; // remove the timepoint
#basename = substring(title, 0, baseEnd);
#extension = substring(title, dotIndex);
#getDimensions(width, height, channels, slices, frames);
#print("Processing",title, "with basename",basename);
#
#
#
#
#// save original file (remove this later)
#
#print("Saving to " + outputDir);
#
#origName = basename+".tif";
#selectImage(id);
#saveAs("tiff", outputDir + File.separator + origName);
#	
#
#// TODO: run correction and save
#
#
#// clean up open images and tables
#while (nImages>0) {
#selectImage(nImages);
#close();
#}
#
#setBatchMode(false);
#
#print("Finished");

