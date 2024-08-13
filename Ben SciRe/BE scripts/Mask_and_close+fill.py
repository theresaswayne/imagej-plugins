from ij import IJ, ImagePlus, ImageStack
from ij.plugin import ChannelSplitter
from ij.io import DirectoryChooser
import os

dc = DirectoryChooser("Choose directory with stacks")
srcDir = dc.getDirectory()
tarDir = DirectoryChooser("Choose target directory").getDirectory()
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