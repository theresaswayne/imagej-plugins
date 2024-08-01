# create an image with simulated peaks, locate them, and save the coordinates to a table

from ij import IJ  
from ij.gui import PointRoi  
from ij.measure import ResultsTable  
from net.imglib2.img.display.imagej import ImageJFunctions as IL  
from net.imglib2.view import Views  
from net.imglib2.algorithm.dog import DogDetection  
from jarray import zeros  
from ij.plugin.frame import RoiManager
from ij.gui import Roi, PointRoi, OvalRoi

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

imp.show()

# Access its pixel data from an ImgLib2 data structure: a RandomAccessibleInterval  
img = IL.wrapReal(imp)  
  
# View as an infinite image, mirrored at the edges which is ideal for Gaussians  
imgE = Views.extendMirrorSingle(img)

# Parameters for a Difference of Gaussian to detect peak positions  
calibration = [1.0 for i in range(img.numDimensions())] # no calibration: identity  
sigmaSmaller = 1 # in pixels   
sigmaLarger = 5  # pixels   
extremaType = DogDetection.ExtremaType.MINIMA  # non-intuitive
minPeakValue = 10
normalizedMinPeakValue = False 
  
# In the differece of gaussian peak detection, the img acts as the interval  
# within which to look for peaks. The processing is done on the infinite imgE.  
dog = DogDetection(imgE, img, calibration, sigmaSmaller, sigmaLarger, extremaType, minPeakValue, normalizedMinPeakValue)  
  
peaks = dog.getPeaks()  
  
# Create a PointRoi from the DoG peaks, for visualization  
roi = PointRoi(0, 0)  
# A temporary array of integers, one per dimension the image has  
p = zeros(img.numDimensions(), 'i')  
# Load every peak as a point in the PointRoi  
for peak in peaks:  
  # Read peak coordinates into an array of integers  
  peak.localize(p)  
  roi.addPoint(imp, p[0], p[1])  
  
imp.setRoi(roi)  
  
# Now, iterate each peak, defining a small interval centered at each peak,  
# and measure the sum of total pixel intensity,  
# and display the results in an ImageJ ResultTable.  
table = ResultsTable()  
  
for peak in peaks:  
  # Read peak coordinates into an array of integers  
  peak.localize(p)  
  # Define limits of the interval around the peak:  
  # (sigmaSmaller is half the radius of the embryo)  
  minC = [p[i] - sigmaSmaller for i in range(img.numDimensions())]  
  maxC = [p[i] + sigmaSmaller for i in range(img.numDimensions())]  
  # View the interval around the peak, as a flat iterable (like an array)  
  fov = Views.interval(img, minC, maxC)  
  # Compute sum of pixel intensity values of the interval  
  # (The t is the Type that mediates access to the pixels, via its get* methods)  
  s = sum(t.getInteger() for t in fov)  
  # Add to results table  
  table.incrementCounter()  
  table.addValue("x", p[0])  
  table.addValue("y", p[1])  
  table.addValue("sum", s)  
  
table.show("intensities at peaks")  
  
# Also show the image with the PointRoi on it:  
imp.show()  