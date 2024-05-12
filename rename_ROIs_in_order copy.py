#@ Dataset dataset
# rename_ROIs_in_order.py
# ImageJ Python (Jython) script by Theresa Swayne, Columbia University, 2023
# Purpose:  give ROIs more readable names

# setup
from ij import IJ
from ij.plugin.frame import RoiManager
from ij.gui import Roi

imp=dataset.getImgPlus()

# get the current ROI Manager or create one if none exists

rm = RoiManager.getInstance()
if not rm:
  rm = RoiManager()

# make sure nothing is selected

rm.deselect()

# loop through ROIs and number them in order starting with 1
# (but note that the ROI indices start with 0)

nROIs = rm.getCount()
for i in range(0, nROIs):
  roiNum = i + 1
  rm.select(i)
  rm.runCommand("Rename", str(roiNum))
  rm.deselect()
  
# make the ROIs easier to see
from array import array
allROIs = array('i', (i for i in range(0,nROIs+1)))

rm.setSelectedIndexes(allROIs);
rm.runCommand("Remove Channel Info");
rm.runCommand("Remove Slice Info");

# test the selection
# rm.runCommand("Measure");

