from ij import IJ

imp=IJ.getImage()
ip=imp.getProcessor().convertToFloat()
pixels=ip.getPixels()

minimum = reduce(min, pixels)

pixels2 = map(lambda x: x-minimum, pixels)
ip2 = FloatProcessor(ip.width, ip.height, pixels2, None)
imp2 = ImagePlus(imp.title, ip2)

# the last argument is a colormodel?

imp2.show()


