from ij import IJ

from java.lang import Float

from org.apache.commons.math3.stat.descriptive.rank import Min, Max, Median, Percentile
  
imp = IJ.getImage()  
ip = imp.getProcessor().convertToFloat() # as a copy  
pixels = ip.getPixels()  
  
print "Image is", imp.title, "of type", imp.type  

# this is a double array that Min() can operate on. The pixels array cannot be used 
newpixels = []
for pixel in pixels:
    newpixels.append(pixel)
    
minimum = Min().evaluate(newpixels)
maximum = Max().evaluate(newpixels)
median = Median().evaluate(newpixels)
percentile = Percentile().evaluate(newpixels)

print "1. Minimum is:", minimum
print "2. Maximum is:", maximum
print "3. Median is:", median
print "4. Percentile is:", percentile


minimum = Float.MAX_VALUE  
for i in xrange(len(pixels)):  
  if pixels[i] < minimum:  
    minimum = pixels[i]  
  
print "0. Minimum is:", minimum
