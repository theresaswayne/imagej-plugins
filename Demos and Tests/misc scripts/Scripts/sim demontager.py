from ij import IJ, ImagePlus, ImageStack, CompositeImage
from ij.plugin import Concatenator
import os
from jarray import array

# Grab the active image
# imp stands for ij.ImagePlus instance
imp = IJ.getImage()
stack=imp.getStack()

titleext=imp.getTitle()
title = os.path.splitext(titleext)[0]

nChannels=imp.getNChannels()
nSlices=imp.getNSlices()
nFrames=imp.getNFrames()

# create new stack to hold demontaged images assuming 5 phases going across and 3 angles going down
montageWidth=imp.width
montageHeight=imp.height
imageWidth=montageWidth/5
imageHeight=montageHeight/3

demontagedStack=ImageStack(imageWidth,imageHeight)

# Print image details  
print "title:", imp.title  
print "number of pixels:", imp.width * imp.height  
print "number of slices:", nSlices  
print "number of channels:", nChannels  
print "number of time frames:",nFrames  

stackList=[]
ccc=Concatenator()
jaimp=array(stackList,ImagePlus)

for c in range(1,nChannels+1):
	for z in range(1,nSlices+1):
		for t in range(1,nFrames+1):
			imp.setPosition(c, z, t)
			print c, z, t
			numberedtitle = title + "_c" + IJ.pad(c, 2) + "_z" + IJ.pad(z, 4) + "_t" + IJ.pad(t, 4)
			print numberedtitle
			stackindex = imp.getStackIndex(c, z, t)
			print "stackindex ", stackindex
			aframe = ImagePlus(numberedtitle, imp.getStack().getProcessor(stackindex))
			IJ.run(aframe, "Montage to Stack...", "images_per_row=5 images_per_column=3 border=0")
			thisStack=WindowManager.getCurrentImage()
			thisStack.setTitle(numberedtitle)
			stackList.append(thisStack)
#			thisStack.close();

print stackList
concatStack=ccc.concatenate(jaimp,False)
concatStack.setDimensions(c, z*15, 1)
concatStack.setOpenAsHyperStack(True)
concatStack.show()


# You can get the current dispayed image by
# image = WindowManager.getCurrentImage()
# stack = image.getStack() # get the stack within the ImagePlus
#perhaps use ij.plugin.stackmaker instead of ij.run
