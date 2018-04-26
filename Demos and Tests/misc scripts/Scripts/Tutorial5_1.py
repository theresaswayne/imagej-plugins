from ij import IJ, ImagePlus
from ij.process import FloatProcessor  
from array import zeros  
from random import random  
from ij.gui import Roi, PolygonRoi
  
width = 1024  
height = 1024  
pixels = zeros('f', width * height)  
  
for i in xrange(len(pixels)):  
  pixels[i] = random()  
  
fp = FloatProcessor(width, height, pixels, None)  
imp = ImagePlus("Random", fp)  

# Fill a rectangular region of interest  
# with a value of 2:  
roi = Roi(400, 200, 400, 300)  
fp.setRoi(roi)  
fp.setValue(2.0)  
fp.fill()  
  
# Fill a polygonal region of interest  
# with a value of -3  
xs = [234, 174, 162, 102, 120, 123, 153, 177, 171,  
      60, 0, 18, 63, 132, 84, 129, 69, 174, 150,  
      183, 207, 198, 303, 231, 258, 234, 276, 327,  
      378, 312, 228, 225, 246, 282, 261, 252]  
ys = [48, 0, 60, 18, 78, 156, 201, 213, 270, 279,  
      336, 405, 345, 348, 483, 615, 654, 639, 495,  
      444, 480, 648, 651, 609, 456, 327, 330, 432,  
      408, 273, 273, 204, 189, 126, 57, 6]  
proi = PolygonRoi(xs, ys, len(xs), Roi.POLYGON)  
fp.setRoi(proi)  
fp.setValue(-3)  
fp.fill(proi.getMask())  # Attention!  

imp.show()