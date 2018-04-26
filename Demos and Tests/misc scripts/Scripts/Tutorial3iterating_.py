from ij import IJ

imp = IJ.getImage()

ip = imp.getProcessor().convertToFloat()
pixels = ip.getPixels()

print "Image is",imp.title,"of type",imp.type,"dude"

minimum = Float.MAX_VALUE
for i in xrange(len(pixels)):
#    print minimum
#    print pixels[i]
    if pixels[i] < minimum:
        minimum = pixels[i]

print "1. final minimum is:",minimum

minimum = Float.MAX_VALUE
for pix in pixels:
#    print minimum
#    print pix
    if pix < minimum:
        minimum = pix

print "2. final minimum is:",minimum

minimum = reduce(min,pixels)

print "3. Final minimum is:",minimum

