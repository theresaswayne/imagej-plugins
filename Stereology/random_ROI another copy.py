# random_ROI.py
# ImageJ Python (Jython) script by Theresa Swayne, Columbia University, 2016
# Purpose:  Select random ROIs from a grid produced by EPFL VSI Reader

# Usage: 
# 1) Edit the fieldsNeeded value as desired. 
# 2) Open your VSI image and select a rectangular area of tissue
# 3) On the VSI bar, click Grid to create the grid squares.
# 4) Run this script. You will need to select a folder to save the ROIs.
# 5) Select all the remaining ROIs in the Manager
# 6) Click Extract Current Image on the VSI bar.

# number of fields you need (must be <= gridSquares)
fieldsNeeded = 30

from ij import IJ
from ij.plugin.frame import RoiManager
from ij.gui import Roi

rm = RoiManager.getInstance()
if not rm:
  rm = RoiManager()

# number of squares in the grid = number of values to choose from
gridSquares = rm.getCount()

# get path for temp file
import os
from ij.io import DirectoryChooser
dc = DirectoryChooser("Pick folder for saving ROI temp file")
folder = dc.getDirectory()

# make a list of random integers
# ROI manager indices start with 0

from java.util import Random
import random

fields = random.sample(range(0, gridSquares), fieldsNeeded)
# print fields

# convert the list to an array that is usable by ROI Manager
from array import array
aFields = array('i', [0] * fieldsNeeded)
aFields = fields

# select the rois and save as temp
rm.setSelectedIndexes(aFields)
rm.runCommand("save selected", os.path.join(folder, "selected.zip"))

# reset ROI mgr, open the temp
rm.reset()
rm.runCommand("Open", os.path.join(folder, "selected.zip"))

# rename the remaining ROIs so that VSI can deal with them
# i is the index within ROI Mgr. i+1 is the number given by VSI Reader

# get base name of ROIs
# searching the last 5 characters for the hashmark because there are usually 2 in the ROI name

oldname = rm.getName(0)
hashPos = oldname.find("#",-5) + 1
# print hashPos
basename = oldname[0:hashPos]
# print "Basename is " + basename

nROIs = rm.getCount()

for i in range(0, nROIs):
  roiNum = i + 1
  rm.select(i)
  rm.runCommand("Rename", basename + str(roiNum))
  rm.deselect()

rm.runCommand("Save", os.path.join(folder, "renamed.zip"))


 
