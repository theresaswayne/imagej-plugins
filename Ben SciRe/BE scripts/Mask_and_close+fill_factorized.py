#@ File(label="Input directory", style="directory") inputDir
#@ File(label="Output directory", style="directory") outputDir
#@ String	(label = "File extension", value=".tif") ext
#@ String	(label = "File name contains", value = "crop") containString

# ImageJ Jython script to detect cell area in a 2-channel stack and output a masked 1-channel stack

from ij import IJ, ImagePlus, ImageStack
from ij.plugin import ChannelSplitter
from ij.io import DirectoryChooser
import os

# --- Suggestion 1: Use the script parameters at the top of the file to replace these commands
# --- They look like comments but they are not comments!
# ---- more info: https://imagej.net/scripting/parameters
#dc = DirectoryChooser("Choose directory with stacks")
#srcDir = dc.getDirectory()
#tarDir = DirectoryChooser("Choose target directory").getDirectory()

# --- Suggestion 2: Define functions for each job that the script performs. 
# --- This makes it easier to debug and to combine functions later
# --- more info: https://medium.com/@nicolaisafai/re-factor-to-make-your-code-more-understandable-2697af65789c

# --- Suggestion 3: For a batch file processer, create standard functions:
# 		a function "run" that traverses the directory
#		a function "process" that calls the different processing sub-functions

# --- FUNCTION DEFINITIONS

def run(): # this is the function that walks through the directory
	
	# setup
	IJ.run("Close All", "");
	IJ.log("\\Clear")
	
	IJ.log("Processing batch masking")
	
	srcDir = inputDir.getAbsolutePath()
	tarDir = outputDir.getAbsolutePath()
	for root, directories, filenames in os.walk(srcDir):
		filenames.sort();
		for filename in filenames:
			IJ.log("Checking file " + filename)
			# Check for file extension
			#ext defined at top (the file ending the user inputs)
			if not filename.endswith(ext):
				continue
			# Check for file name pattern
			if containString not in filename:
				continue
			process(srcDir, tarDir, root, filename)
	IJ.log("Done")



def process(srcDir, tarDir, root, filename):
	IJ.log("Processing " + filename)
	
	# Get the image path
	imagePath = os.path.join(srcDir, filename)
	
	#get the right channel from split
	imp = IJ.openImage(imagePath)
	channels = ChannelSplitter.split(imp)
	imp = channels[0]
	
	#threshold
	IJ.run(imp, "Auto Threshold", "method=Huang white stack use_stack_histogram")
	
	#close, remove outliers, fill
	IJ.run(imp, "Close-", "stack")
	IJ.run(imp, "Remove Outliers...", "radius=2 threshold=50 which=Bright stack");
	IJ.run(imp, "Fill Holes", "stack")
	
	#save
	newFilename = "MASK_" + filename
	targetPath = os.path.join(tarDir, newFilename) #tarDir defined in run
	IJ.log("Saving output for " + filename)
	IJ.saveAs(imp, "Tiff", targetPath)
	imp.close()
	return


# ---- This is the actual script lol
run()



#selection command: 