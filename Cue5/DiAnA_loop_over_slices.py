#@ File(label = "Treg label image:") TregFile
#@ File(label = "Fibroblast label image:") FbFile
#@ File(label = "Output folder:", style = "directory") outDir

# take 2 label image stacks representing 2D tracked cells over time
# use DiAnA to determine which cells in the first image overlap cells in the 2nd

# ---- Setup ----
import os
import math
import io
from net.imglib2.view import Views
from ij import IJ, ImagePlus, ImageStack
from ij.process import ImageProcessor, FloatProcessor, StackProcessor
from ij.process import ImageConverter
import string
from ij.measure import ResultsTable
from ij import WindowManager

IJ.run("Conversions...", " ")
#IJ.setOption("ScaleConversions", false)

# ---- Load files ----

TregPath = TregFile.getPath()
TregName = os.path.basename(TregPath)

TregImp = IJ.openImage(str(TregFile))
FbImp = IJ.openImage(str(FbFile))

ic = ImageConverter(TregImp)
ic.convertToGray16()
TregImp.updateImage()
#TregImp.show()

ic = ImageConverter(FbImp)
ic.convertToGray16()
FbImp.updateImage()
#FbImp.show()

TregStack = TregImp.getStack() # get the stack within the ImagePlus
FbStack = FbImp.getStack() # get the stack within the ImagePlus

n_slices = TregStack.getSize() # get the number of slices

wm = WindowManager
outputdir = str(outDir)

# ---- Loop over slices ---- 

for index in range(1, n_slices+1):
	TregIp = TregStack.getProcessor(index) 
	FbIp = FbStack.getProcessor(index)
	IJ.log("Processing slice " + str(index)) # output info on current slice
	TsliceName = "Treg_" + str(index)
	TsliceImp = ImagePlus(TsliceName, TregIp) # give the imp a name to use with DiAnA
	TsliceImp.show()
	FsliceName = "Fb_" + str(index)
	FsliceImp = ImagePlus(FsliceName, FbIp)
	FsliceImp.show()
	
	# find overlaps
	IJ.run("DiAna_Analyse", "img1="+TsliceName+" img2="+FsliceName+" lab1="+TsliceName+" lab2="+FsliceName+" coloc")
	
	# save results
	indexPadded = str(index).zfill(3)
	basename = TregName.split("_")[1] # should be ROI name
	outputName = string.join((indexPadded,"_",basename, "_ColocResults.csv"), "")
	#print("Saving as", outputName)
	rt_Window= WindowManager.getWindow("ColocResults")
	rt = rt_Window.getResultsTable()
	rt.save(os.path.join(outputdir, outputName))
	
	# clean up slices
	win = wm.getWindow("coloc")
	win.close()
	TsliceImp.close()
	FsliceImp.close()
	

