# @ImagePlus imp

from ij.plugin.frame import RoiManager
from ij.gui import Plot
from operator import add

def run():
    rm = RoiManager.getInstance()
    if not rm: # return if no ROI manager is open
        print "No ROI manager open"
        return
    roiIndexes = rm.getSelectedIndexes()
    if not roiIndexes: # if no ROI is selected, take all ROIs
        roiIndexes = rm.getIndexes()
    hist = []
    for roiID in roiIndexes: # loop over all ROI indices
        print roiID
        rm.select(imp, roiID)
        if not hist: # initialize the first histogram
            hist = imp.getProcessor().getHistogram()
        else: # add the current histogram to the accumulated histogram
            hist = map(add, hist, imp.getProcessor().getHistogram())
    print hist

    bins = range(len(hist))
    plot = Plot("Histogram", "Intensity", "Frequency", bins, list(hist))
    plot.show()
    
run()