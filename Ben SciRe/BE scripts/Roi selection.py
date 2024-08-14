#@ File(label="Mask: Input file", style="file") inputMask
#@ File(label="Image: Input file", style="file") inputImage


#To-do List:
#1. Get rid of ROI error: "active image does not have a selection"
#2. Do measurements on only Fluorescence channel (channel 1)
#---- maybe set a position or access the image processor (part of image class) or accessing particular channels + slices of the stack


from ij import IJ
from ij.plugin.frame import RoiManager

#set up roi manager
#IJ.run("Close All", "") #closes all open images
rm = RoiManager.getInstance()
if not rm:
	rm = RoiManager()
rm.reset()

srcMask = inputMask.getAbsolutePath()
srcImage = inputImage.getAbsolutePath()

#get image
impMask = IJ.openImage(srcMask)

IJ.run(impMask, "Select None", "")

#loop through slices n on the mask image
#if theres a BLACK SLICE (typically slice 1 and 1/some of the end slices), the roi manager will not display selections on those slices
for n in range(1, impMask.getNSlices()+1):
	impMask.setSlice(n)
	IJ.run(impMask, "Create Selection", "")
	roi = impMask.getRoi()
	#roi.setPosition(n)
	rm.addRoi(roi)

#HOW TO SAVE ROIS TO A FOLDER
#rm.runCommand("Deselect")
#rm.save(os.path.join(saveDir, fileName + "_cellROIs.zip"))

imp = IJ.openImage(srcImage)
for n in range(0, rm.getCount()):
	rm.select(n); #roi indeces go from 0 to n-1
	IJ.run(imp, "Measure", ""); #gets mean intensity values
	IJ.run(imp, "Find Maxima...", "prominence=20 output=[Count]");