from ij import IJ, ImagePlus, ImageStack, CompositeImage

# Load a stack of images: a fly brain, in RGB
imp = IJ.openImage("http://imagej.nih.gov/ij/images/flybrain.zip")
stack = imp.getImageStack()

# A new stack to hold the data of the hyperstack
stack2 = ImageStack(imp.width, imp.height)

print "there are ",stack2.getSize(),"slices in the stack at first"

# Convert each color slice in the stack
# to two 32-bit FloatProcessor slices
for i in xrange(1, imp.getNSlices()+1):
  # Get the ColorProcessor slice at index i
  cp = stack.getProcessor(i)
  # Extract the red and green channels as FloatProcessor
  red = cp.toFloat(0, None)
  green = cp.toFloat(1, None)
  # Add both to the new stack
  # at the moment this is a 1d stack!
  stack2.addSlice(None, red)
  stack2.addSlice(None, green)

# Create a new ImagePlus with the new stack
imp2 = ImagePlus("32-bit 2-channel composite", stack2)
imp2.setCalibration(imp.getCalibration().copy())

# Tell the ImagePlus to represent the slices in its stack
# in hyperstack form, and open it as a CompositeImage:
nChannels = 2             # two color channels
nSlices = stack.getSize() # the number of slices of the original stack
nFrames = 1               # only one time point 
imp2.setDimensions(nChannels, nSlices, nFrames)
comp = CompositeImage(imp2, CompositeImage.COMPOSITE)
comp.show()
