from ij import IJ, ImagePlus, ImageStack, CompositeImage
import os

# Grab the active image
# imp stands for ij.ImagePlus instance
imp = IJ.getImage()
stack=imp.getStack()
ssize = imp.getStackSize()
titleext=imp.getTitle()
title = os.path.splitext(titleext)[0]

# hyperstack loop example from kota miura
dimA = imp.getDimensions()
for c in range(dimA[2]):
	for z in range(dimA[3]):
		imp.setPosition(c+1, z+1)
		print c, z
		numberedtitle = title + "_c" + IJ.pad(c, 2) + "_z" + IJ.pad(z, 2)
		print numberedtitle
		stackindex = imp.getStackIndex(c, z)
		print "stackindex ", stackindex
		aframe = ImagePlus(numberedtitle, imp.getStack().getProcessor(stackindex))
		IJ.run(aframe, "Montage to Stack...", "images_per_row=5 images_per_column=3 border=0")
