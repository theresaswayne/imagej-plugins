# @File(label="Output directory",style="directory") out_dir
# @String(label="Process filenames containing",description="Clear for no filtering",value=".tif") filenameFilter
#@ int(label="What size tiles would you like (pixel dimensions?") tileSize

# based on Process_Folder_PY.py, Particles_From_Mask.py, Crop_Confocal_Series.py

import csv, os
from ij import IJ, ImagePlus
from ij.measure import ResultsTable
from bar import Utils

from ij.gui import PointRoi
from ij.plugin.frame import RoiManager
from net.imglib2.algorithm.labeling.ConnectedComponents import StructuringElement
from net.imglib2.roi.labeling import LabelRegions


from net.imglib2.util import Intervals
from net.imagej.axis import Axes

def get_roi_manager(new=False):
    rm = RoiManager.getInstance()
    if not rm:
        rm = RoiManager()
    if new:
        rm.runCommand("Reset")
    return rm
    
# rm = get_roi_manager(new=True)

# Define directories as strings
src_dir = str(src_dir)
out_dir = str(out_dir)


# first take a look at the size and type of each dimension
for d in range(data.numDimensions()):
	print "axis d: type: "+str(data.axis(d).type())+" length: "+str(data.dimension(d))

img=data.getImgPlus()

xLen = data.dimension(data.dimensionIndex(Axes.X))
yLen = data.dimension(data.dimensionIndex(Axes.Y))
zLen = data.dimension(data.dimensionIndex(Axes.Z))
cLen = data.dimension(data.dimensionIndex(Axes.CHANNEL))

tileWidth = tileSize
tileHeight = tileSize

# crop a channel
c0=ops.transform().crop(img, Intervals.createMinMax(0, 0, 0,0,xLen-1, yLen-1, 0, zLen-1))
c0.setName("c0")

#this is macro language 
#tileWidth = width / n; 
#tileHeight = height / n; 
#for (y = 0; y < n; y++) { 
#offsetY = y * height / n; 
# for (x = 0; x < n; x++) { 
#offsetX = x * width / n; 
#selectImage(id); 
#call("ij.gui.ImageWindow.setNextLocation", locX + offsetX, locY + offsetY); 
#tileTitle = title + " [" + x + "," + y + "]"; 
# run("Duplicate...", "title=" + tileTitle); 
#makeRectangle(offsetX, offsetY, tileWidth, tileHeight); 
# run("Crop"); 


# Process list of images
for (counter, f) in enumerate(files):

    # Display progress
    IJ.showStatus("Processing roi "+ str(counter+1) +"/"+ str(len(rois)))


    # Save processed image in out_dir (enforcing .tif extension)
    newpath = os.path.splitext(out_dir + imp.getTitle())[0] +".tif"
    IJ.saveAsTiff(imp, newpath)
    imp.close()


# Proudly inform that processing terminated
if IJ.showMessageWithCancel("All done","Reveal output directory?"):
    Utils.revealFile(out_dir);

