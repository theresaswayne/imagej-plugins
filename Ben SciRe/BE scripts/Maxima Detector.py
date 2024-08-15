from ij import IJ
from ij.gui import PointRoi
from ij.plugin.frame import RoiManager
from net.imglib2.img.display.imagej import ImageJFunctions as IL
from net.imglib2.algorithm.dog import DogDetection
from net.imglib2.view import Views
from jarray import zeros
from ij.measure import ResultsTable

# Heres the link: https://javadoc.scijava.org/ImgLib2/index.html?net/imglib2/algorithm/dog/DogDetection

IJ.run("Close All", "") # close all open windows
IJ.run("Clear Results", "") # clear the Results window
IJ.log("\\Clear") # clear the ImageJ log

# Open the single-channel Z-stack image as an ImagePlus
#imp = IJ.openImage("C:\Users\Ben\Downloads\Sci Re pictures\New folder\C1-hsp104del_satd_osm_35hs_60REC-001_crop1.tif")
imp = IJ.openImage("/Users/theresaswayne/Desktop/input/C1-hsp104del_satd_osm_35hs_60REC-001_crop1.tif")
imp.show()
#-----------------

# Preparation of images
ipReal = IL.wrapReal(imp)
ipMirror = Views.extendMirrorSingle(ipReal)
#imp.show()

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

detection = DogDetection(ipMirror, ipReal, calibration, sigmaSmaller, sigmaLarger,
  				   extremaType, minPeakValue, normalizedMinPeakValue)


peaks = detection.getPeaks()
IJ.log(str(len(peaks)) + " peaks were found.")

# A temporary array of integers, one per dimension the image has
peakCoords = zeros(ipReal.numDimensions(), 'i')

#roiPeaks = new PointRoi()   

peaksTable = ResultsTable()

# Add points to ROI manager
rm = RoiManager.getInstance()
if not rm:
    rm = RoiManager()
rm.reset()

for peak in peaks:
	# Read peak coordinates into an array of integers
	peak.localize(peakCoords)
	#roiPeaks.addPoint(imp1, peakCoords[0], peakCoords[1], peakCoords[2])
	#proi = PointRoi(peak.getDoublePosition(0) / cal.pixelWidth, peak.getDoublePosition(1) / cal.pixelHeight)
	#proi.setPosition(int(peak.getDoublePosition(2) / cal.pixelDepth))
	proi = PointRoi(peak.getDoublePosition(0), peak.getDoublePosition(1))
	proi.setPosition(int(peak.getDoublePosition(2)))
	rm.addRoi(proi)
	peaksTable.incrementCounter()
	peaksTable.addValue("File",imp.getTitle())
	peaksTable.addValue("X",peakCoords[0])
	peaksTable.addValue("Y",peakCoords[1])
	peaksTable.addValue("Z",peakCoords[2])

peaksTable.show("Peaks")

# Loop through all the peak that were found
#for peak in peaks:
#    # Print the current coordinates
#    print peak.getDoublePosition(0), peak.getDoublePosition(1), peak.getDoublePosition(2)
#    # Add the current peak to the Roi manager
#    proi = PointRoi(peak.getDoublePosition(0) / cal.pixelWidth, peak.getDoublePosition(1) / cal.pixelHeight)
#    proi.setPosition(int(peak.getDoublePosition(2) / cal.pixelDepth))
#    rm.addRoi(proi)

# Show all ROIs on the image
rm.runCommand(imp, "Show All")
