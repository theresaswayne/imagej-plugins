#@ File(label="Input directory", style="directory") srcDir
#@ File(label="Output directory", style="directory") tarDir
#@ String  (label = "File extension", value=".czi") ext
#@ String  (label = "File name contains", value = "") containString

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
# ---- more info: https://medium.com/@nicolaisafai/re-factor-to-make-your-code-more-understandable-2697af65789c


counter = 1

for filename in os.listdir(srcDir):	
	if filename.lower().endswith("crop"+str(counter)+".tif"):	
		# Get the image path
	    imagePath = os.path.join(srcDir, filename)
		#get the right channel from split
	    imp = IJ.openImage(imagePath)
	    channels = ChannelSplitter.split(imp)
	    imp = channels[0]
	    #threshold
	    IJ.setAutoThreshold(imp, "Huang dark no-reset stack")
	    #Convert and get mask
	    IJ.run(imp, "Convert to Mask", "")
	    imp = IJ.getImage()
	    #close and fill holes
	    IJ.run(imp, "Close-", "stack")
	    IJ.run(imp, "Fill Holes", "stack")
	    #save
	    newFilename = "MASK_" + filename
	    targetPath = os.path.join(tarDir, newFilename)
	    IJ.saveAs(imp, "Tiff", targetPath)
	    imp.close()
	    counter = counter + 1
	else:
		counter = 1
		continue