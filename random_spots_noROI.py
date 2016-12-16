
"""
Created on Wed Nov 30 10:44:02 2016

@author: theresaswayne
"""
# random_spots_noROI.py
# ImageJ Python (Jython) script by Theresa Swayne, Columbia University, 2016
# for Sean Xiaowei Chen
# Purpose:  Produce simulated images with "cells" placed randomly on the image. 
# To be used for significance testing of colocalization.

# Inputs: 
#   Cell area in um^2 (assume circular)
#   Target, multichannel image with scale 
#   Cell density (cells per unit area)
#   Number of randomized images to generate
# Output: set of images with simulated cells placed at appropriate density
# Usage: update parameters, run the script, open image when prompted
# note that the red cells will be placed everywhere on the image (even off tissue) but the density is calculated with respect to the identified tissue area. So the "cells" off tissue must be disregarded.

from ij import IJ
import os 
import random
import math
from ij.io import DirectoryChooser
from ij.io import OpenDialog
from ij import IJ
from ij.plugin.frame import RoiManager
from ij.process import ImageStatistics
from ij.measure import Measurements as Measure
from ij.gui import Roi, PolygonRoi


# hardcoded variables and images for testing
# srcpath = "/Users/confocal/Google Drive/Random spots Sean Chen/sample images/test.nd2"
#filename = os.path.basename(srcpath)
# print(filename)
# parentdirectory = os.path.dirname(srcpath)
#basename = os.path.splitext(filename)[0]
# print(basename)
#imp = IJ.openImage(srcpath)
# imp = IJ.getImage()

CELLAREA = 36.7 # in um2
PIXSIZE = 0.307 
CELLDENSITY = .000878 # cells per um2  
CHANNEL = 3 # red channel
TRIALS = 5 # number of simulations

# user chooses the file
od = OpenDialog("Choose multi-image file", None)
srcDir = od.getDirectory()
# print("directory = "+srcDir)
filename = od.getFileName()
# print("file = "+filename)
path = os.path.join(srcDir, od.getFileName())
basename = os.path.splitext(filename)[0]
# print("base = "+basename)
# print("path = "+path)

# get the target image
imp = IJ.openImage(path)
imp = IJ.getImage()

# get image size, dimensions, nChannels
width = imp.getWidth()
height = imp.getHeight()
composite = imp.isComposite()
if composite:
   channels = imp.getNChannels()

cal = imp.getCalibration()
scaled = cal.scaled();
if scaled:
   units = cal.units
   pixwidth = cal.pixelWidth
else:
    pixwidth = PIXSIZE

# print("width "+str(width)+" height "+str(height)+ " pixwidth = "+str(pixwidth))


# get the channel to randomize 
# TODO: user input
targetChannel = CHANNEL

# get the average yellow cell density by user input, in cells per um^2
# TODO: user input
cellDensity = CELLDENSITY

# get the average cell area in microns^2 from user input
# TODO: user input
cellarea = CELLAREA

#calculate cell diameter in pixels
celldiam = (2*math.sqrt(cellarea/math.pi))/pixwidth

# number of randomizations to do
# TODO: user input
trials = TRIALS

# calculate how many cells to place based on area of image
nCells = round(cellDensity * width * height * pixwidth * pixwidth) # float
# print("without ROI we will have "+str(nCells))


def drawSpot(point, diam):
    '''
    point: list of 2 integer values
    diam: float indicating the diameter of a cell in pixels
    Draws a filled circle on the selected channel of the current image at the indicated point
    '''
    xcenter = point[0]
    ycenter = point[1]
    # print("Drawing spot at "+str(xcenter)+", "+str(ycenter))
    IJ.run(imp2, "Specify...", "width="+str(diam)+" height="+str(diam)+" x="+str(xcenter)+" y="+str(ycenter)+" oval")
    IJ.run(imp2, "Fill", "slice")
    IJ.run(imp2, "Select None", "")
    return

def cellOverlap(xcenter, ycenter, diam, centerlist):
    '''
    xcenter, ycenter: integers denoting a candidate point
    diam: float indicating the diameter of a cell in pixels
    centerlist: list of lists, each representing a previously chosen point in pixel coords
    returns True if the candidate point is < 1 cell diameter from any other point in the list
    '''
    for point in centerlist:
        dist = math.sqrt(((xcenter-point[0]) ** 2) + ((ycenter-point[1]) ** 2))
        if dist < diam:
            # print("Eliminating spot at "+str(point))
            return True
    return False

# generate a set of simulated images
for trial in range(1, TRIALS+1):  

    count = 0
    centers = []
    
    print("Beginning simulation "+str(trial))
    
    while count < nCells:
    
        # choose random x and y from anywhere in the image
    
        xcenter = random.randint(0, width) # in pixel units because integers
        ycenter = random.randint(0, height)
        
        # discard positions that would generate overlapping cells
        if not cellOverlap(xcenter, ycenter, celldiam, centers):

            centers.append([xcenter, ycenter])
            # print("Spot "+str(count)+" center: "+str(centers[count]))

            count += 1
        
    # work on a copy of the image
    from ij.plugin import Duplicator
    imp2 = Duplicator().run(imp, 1, channels, 1, 1, 1, 1)
    
    # clear the existing channel
    imp2.setDisplayMode(IJ.COLOR);
    imp2.setC(targetChannel);
    IJ.run(imp2, "Select All", "");
    IJ.setBackgroundColor(0, 0, 0);
    IJ.run(imp2, "Clear", "slice");    
    
    # draw white circles to simulate cells
    IJ.setForegroundColor(255,255,255)
    for point in centers:
        drawSpot(point, celldiam)
    
    # save the simulated image
    IJ.saveAs(imp2, "Tiff", os.path.join(srcDir, basename+" sim "+str(trial)+".tif"));
    imp2.close()
    

# print("Finished simulations.")

# close the original
imp.close()
    
