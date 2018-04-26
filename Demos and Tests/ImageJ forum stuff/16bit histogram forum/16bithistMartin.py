from ij import IJ
from ij.gui import PolygonRoi, Roi
from ij.measure import ResultsTable, Measurements
from ij.plugin.frame import RoiManager
import math

rm = RoiManager.getInstance()
image = IJ.getImage()
rt = ResultsTable()
bitdepth = image.getBitDepth()
n_level=range(0,int(math.pow(2, bitdepth)))

# resulttable initialization
for n_roi in range(0,rm.getCount()):    
    roi = rm.getRoi(n_roi)
    for r in range(0,len(n_level)):
        rt.setValue("nbins",r,r)        
        rt.setValue(roi.getName(),r,0)
        
rt.addValue("ROIS HISTOGRAM",0)
rt.show("Results")
    
#get histogram of roi

for n_roi in range(0,rm.getCount()):
    rm.select(n_roi);    
    roi = rm.getRoi(n_roi)
    image.setRoi(roi)
    stats = image.getStatistics(Measurements.MEAN,bitdepth)
    if (bitdepth)>8:
        hist=stats.histogram16
    if (bitdepth)<=8:
        hist=stats.histogram   

    nonzero=[i for i, e in enumerate(hist) if e != 0]


    for r in nonzero:          
        value=int(hist[r])                     
        rt.setValue(roi.getName(),r,value)
        print(n_roi,r,value)
        #rt.updateResults()
        # calculate HISTOGRAM of specific r value of all roi 

        if (n_roi==rm.getCount()-1):              
            rt.show("Results")
            rt_text=rt.getResultsWindow().getTextPanel()              
            current_allRoi_line=rt_text.getLine(r);
            current_allRoi_list=current_allRoi_line.split("\t")              
            whole_line_hist=sum(int(v) for v in current_allRoi_list)-r-(r+1)               
            rt.setValue("ROIS HISTOGRAM",r,whole_line_hist)    
rt.show("Results")