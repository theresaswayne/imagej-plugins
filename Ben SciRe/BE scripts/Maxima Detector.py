from ij import IJ
from ij.gui import PointRoi
from ij.plugin.frame import RoiManager
from net.imglib2.img.display.imagej import ImageJFunctions as IL
from net.imglib2.algorithm.dog import DogDetection
from net.imglib2.view import Views
from jarray import zeros
from ij.measure import ResultsTable

# TODO:
# 1. Determine parameters (sigmaSmaller, sigmaLarger, minPeakValue) that work well on a couple of images 
# 2. Use code in this script and find_close_peaks_batch.py to create a table called Counts 
#    that will contain the image name and the total number of peaks found 
# 3. Create a function to incorporate all of this within the main script, 
#    and save the point ROIs (every image) and the Counts table (at the end of the batch)
#    (be sure to use the original image for peak detection... if you use the masked image, 
#    you may detect erroneous peaks at the edge of the mask where intensity changes rapidly)

# Heres the link: https://javadoc.scijava.org/ImgLib2/index.html?net/imglib2/algorithm/dog/DogDetection
# More info: https://en.wikipedia.org/wiki/Difference_of_Gaussians
# https://javadoc.scijava.org/ImgLib2/net/imglib2/algorithm/dog/DifferenceOfGaussian.html
# https://syn.mrc-lmb.cam.ac.uk/acardona/fiji-tutorial/#find-cells-with-DoG

IJ.run("Close All", "") # close all open windows
IJ.run("Clear Results", "") # clear the Results window
IJ.log("\\Clear") # clear the ImageJ log

# Open the single-channel Z-stack image as an ImagePlus
#imp = IJ.openImage("C:\Users\Ben\Downloads\Sci Re pictures\New folder\C1-hsp104del_satd_osm_35hs_60REC-001_crop1.tif")
imp = IJ.openImage("/Users/theresaswayne/Desktop/input/C1-hsp104del_satd_osm_35hs_60REC-001_crop1.tif")
imp.show()
#-----------------

# Preparation of images

# Access its pixel data from an ImgLib2 data structure: a RandomAccessibleInterval  
ipRAI = IL.wrapReal(imp)

# View as an infinite image, mirrored at the edges which is ideal for Gaussians  
ipExtended = Views.extendMirrorSingle(ipRAI)


# sigmaSmaller ==> Size of the smaller dots (in calibrated units)
# sigmaLarger ==> Size of the bigger dots (in calibrated units)
# minPeakValue ==> Intensity above which to look for dots
# calibration = [1.0 for i in range(ip1_1.numDimensions())]
cal = imp.getCalibration()
calibration = [cal.pixelWidth] # must be a double array 
extremaType = DogDetection.ExtremaType.MINIMA # bright spots on black background
sigmaSmaller = 1
sigmaLarger = 5
minPeakValue = 10
normalizedMinPeakValue = False

detection = DogDetection(ipExtended, ipRAI, calibration, sigmaSmaller, sigmaLarger,
  				   extremaType, minPeakValue, normalizedMinPeakValue)


peaks = detection.getPeaks()
IJ.log(str(len(peaks)) + " peaks were found.")

# A temporary array of integers, one per dimension the image has
peakCoords = zeros(ipRAI.numDimensions(), 'i')

#roiPeaks = new PointRoi()   

# optional -- table of peak positions
#peaksTable = ResultsTable()

# Add points to ROI manager
rm = RoiManager.getInstance()
if not rm:
    rm = RoiManager()
rm.reset()

for peak in peaks:
	# Read peak coordinates into an array of integers
	peak.localize(peakCoords) # in pixels
	proi = PointRoi(peak.getDoublePosition(0), peak.getDoublePosition(1))
	proi.setPosition(int(peak.getDoublePosition(2)))
	rm.addRoi(proi)
	
	# optional -- table of peak positions
	#peaksTable.incrementCounter()
	#peaksTable.addValue("File",imp.getTitle())
	#peaksTable.addValue("X",peakCoords[0])
	#peaksTable.addValue("Y",peakCoords[1])
	#peaksTable.addValue("Z",peakCoords[2])

# optional -- table of peak positions
#peaksTable.show("Peaks")


# Show all ROIs on the image
rm.runCommand(imp, "Show All")
