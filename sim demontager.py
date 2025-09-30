from ij import IJ, ImagePlus, ImageStack, CompositeImage
from ij.plugin import Concatenator
import os

# Grab the active image
# imp stands for ij.ImagePlus instance
imp = IJ.getImage()
stack=imp.getStack()
titleext=imp.getTitle()
title = os.path.splitext(titleext)[0]
nChannels=imp.getNChannels()
nSlices=imp.getNSlices()
nFrames=imp.getNFrames()
# Print image details  
print "title:", imp.title  
print "number of pixels:", imp.width * imp.height  
print "number of slices:", nSlices  
print "number of channels:", nChannels  
print "number of time frames:",nFrames  

for c in range(0,nChannels+1):
	for z in range(0,nSlices+1):
		for t in range(0,nFrames+1):
			imp.setPosition(c+1, z+1, t+1)
			print c, z, t
			numberedtitle = title + "_c" + IJ.pad(c, 2) + "_z" + IJ.pad(z, 4) + "_t" + IJ.pad(t, 4)
			print numberedtitle
			stackindex = imp.getStackIndex(c, z, t)
			print "stackindex ", stackindex
			aframe = ImagePlus(numberedtitle, imp.getStack().getProcessor(stackindex))
			IJ.run(aframe, "Montage to Stack...", "images_per_row=5 images_per_column=3 border=0")
			thisStack=WindowManager.getCurrentImage()
			outputStack.add
			

# You can get the current dispayed image by
# image = WindowManager.getCurrentImage()
# stack = image.getStack() # get the stack within the ImagePlus

