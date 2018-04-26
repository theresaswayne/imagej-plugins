from ij import IJ

imp=IJ.getImage()
ip=imp.getProcessor().convertToFloat()
pixels=ip.getPixels()


# counting pixels meeting a criterion

mean = sum(pixels)/len(pixels)

print "mean is",mean

n_pix_above = reduce(lambda count, a: count + 1 if a > mean else count, pixels, 0)

# getting the pixel array indices of these pixels

above = filter(lambda i: pixels[i] > mean, xrange(len(pixels)))

print "number of pixels above mean:",len(above)

# using the indices to get coordinates and then centroid = aveX, aveY

width=imp.width

# modulus of pixel index / width gives x coord. (starts with 0)

xc = sum(map(lambda i: i % width, above))/len(above)
yc = sum(map(lambda i: i / width, above))/len(above)

print xc,yc

