# make an image with simulated peaks, detect them, and read the coordinates into an array and a point ROI

from ij import IJ, ImagePlus, ImageStack, WindowManager
from ij.plugin import ZProjector
from ij.plugin.filter import RankFilters
import net.imagej.ops
from net.imglib2.view import Views
from net.imglib2.img.display.imagej import ImageJFunctions as IL
from net.imglib2.algorithm.dog import DogDetection
from ij.gui import Roi, PointRoi, OvalRoi
from jarray import zeros
from ij.measure import ResultsTable
from java.awt import Color
from ij.plugin.frame import RoiManager
from net.imglib2 import Cursor, IterableInterval
from net.imglib2.type.numeric.real import FloatType

IJ.log("\\Clear")
rm = RoiManager.getInstance()
if not rm:
	rm = RoiManager()
rm.reset()

# create blank image
imp = IJ.createImage("Test_Peaks", "8-bit black", 200, 200, 1)
ip = imp.getProcessor()
imp.show()

# set foreground to white
ip.setValue(255)

# make small circle selections and fill with white
imp.setRoi(OvalRoi(50, 50, 3, 3))
IJ.run("Fill", "slice");

imp.setRoi(OvalRoi(140, 100, 3, 3))
IJ.run("Fill", "slice");

# blur to simulate gaussian peaks
IJ.run("Select None");
IJ.run(imp, "Gaussian Blur...", "sigma=3");
IJ.run(imp, "Enhance Contrast", "saturated=0.35");

# detect the peaks -- notes and most code from A. Cardona

# convert to floating point and then to ImagePlus
impF = imp.getProcessor().convertToFloat()
imp = ImagePlus("Test Processed", impF)

# Access pixel data from an ImgLib2 data structure: a RandomAccessibleInterval  
img = IL.wrapReal(imp)  

# View as an infinite image, mirrored at the edges which is ideal for Gaussians  
imgE = Views.extendMirrorSingle(img)  

# Parameters for DoG detection
cal = imp.getCalibration()
calibration = [cal.pixelWidth]
IJ.log("Cal "+ str(calibration))
# calibration = [1.0 for i in range(img.numDimensions())] # no calibration: identity  
sigmaSmaller = 1 # in pixels: a quarter of the radius  
sigmaLarger = 5  # pixels: half the radius  
extremaType = DogDetection.ExtremaType.MAXIMA  # find high points
minPeakValue = 10
normalizedMinPeakValue = False

# The img acts as the interval within which to look for peaks. The processing is done on the infinite imgE.  
dog = DogDetection(imgE, img, calibration, sigmaSmaller, sigmaLarger, extremaType, minPeakValue, normalizedMinPeakValue)  

peaks = dog.getPeaks()
IJ.log("Peaks " + str(peaks))

# Create a PointRoi from the DoG peaks, for visualization  
roi = PointRoi(0, 0)
# A temporary array of integers, one per dimension the image has  
p = zeros(img.numDimensions(), 'i')

table = ResultsTable()

# Load every peak as a point in the PointRoi  
for peak in peaks:  
	# Read peak coordinates into an array of integers  
	peak.localize(p)
	roi.addPoint(imp, p[0], p[1])
	IJ.log("Adding peak at %s, %s" %(str(p[0]),str(p[1])))

	# Add to results table  
	table.incrementCounter()
	table.addValue("x", p[0])  
	table.addValue("y", p[1])

table.show("Go Dog Go")

rm.addRoi(roi)
imp.show()

	