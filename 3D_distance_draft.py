from ij import IJ, ImagePlus, ImageStack
from ij.plugin import ZProjector
from ij.plugin.filter import RankFilters
from ij.plugin.filter import BackgroundSubtracter
import net.imagej.ops
from net.imglib2.view import Views
from net.imglib2.img.display.imagej import ImageJFunctions as IL
from net.imglib2.algorithm.dog import DogDetection
from ij.gui import PointRoi
from jarray import zeros
from ij.measure import ResultsTable
from math import sqrt
from java.awt import Color
from ij.plugin.frame import RoiManager
from ij.gui import GenericDialog

def distance(peak_1, peak_2):
	return sqrt((peak_2[2] - peak_1[2]) * (peak_2[2] - peak_1[2]) +(peak_2[1] - peak_1[1]) * (peak_2[1] - peak_1[1]) + (peak_2[0] - peak_1[0]) * (peak_2[0] - peak_1[0]))

xySize = 0.155
zSize = 1.00
min_dist = 20

# TODO read files
# TODO initialize arrays for total points

# transform z coords

for peak_1 in peaks_1:
	peak_1[2] = peak_1[2] * zSize/xySize

for peak_2 in peaks_2:
	peak_2[2] = peak_2[2] * zSize/xySize

# find group 1 points near group 2

for peak_1 in peaks_1:
	for peak_2 in peaks_2:
		d1 = distance(peak_1, peak_2)
		if  d1 < min_dist:
			OneNearTwo.addPoint(p_1[0], p_1[1], p_1[2])

# find group 2 points near group 1

for peak_2 in peaks_2:
	for peak_1 in peaks_1:
		d2 = distance(peak_2, peak_1)
		if  d2 < min_dist:
			TwoNearOne.addPoint(p_2[0], p_2[1], p_2[2])
)
			
