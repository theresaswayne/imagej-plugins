# @ImagePlus imp

from ij.plugin.frame import RoiManager
from operator import add
from ij import IJ
from ij.gui import PolygonRoi, Roi, Plot
from ij.measure import ResultsTable, Measurements
from ij.plugin.frame import RoiManager
import math

def run():
    rm = RoiManager.getInstance()
    imp = IJ.getImage()
    bitdepth = imp.getBitDepth()
    if not rm: # return if no ROI manager is open
        print "No ROI manager open"
        return    
#    roiIndexes = rm.getSelectedIndexes()
#    if not roiIndexes: # if no ROI is selected, take all ROIs
    roiIndexes = rm.getIndexes()
    hist = []
    for roiID in roiIndexes: # loop over all ROI indices
        print roiID
        rm.select(imp, roiID)
        stats = imp.getStatistics()
        print stats.histogram16
        
#        if not hist: # initialize the first histogram
#            hist = stats.histogram16
#        else: # add the current histogram to the accumulated histogram
#            hist = map(add, hist, stats.histogram16)
#    print hist
    
run()