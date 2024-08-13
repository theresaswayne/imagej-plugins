# thresholder demo

from ij import IJ, ImagePlus, ImageStack
import net.imagej.ops
import os

# open a practice stack
IJ.run("Close All", "");
imp = IJ.openImage("http://imagej.net/images/mri-stack.zip")
imp.show()

# or use the current image
#imp = IJ.getImage()

imp = imp.duplicate()

# Option 1: GUI Auto Threshold command
# see https://forum.image.sc/t/how-do-i-do-thresholding-when-the-whole-image-is-grayscale/89785/3
IJ.run(imp, "Auto Threshold", "method=Huang white stack use_stack_histogram")
imp.setTitle("AutoThreshold stack")
imp.show()

# Option 2: GUI Threshold command
imp = IJ.openImage("http://imagej.net/images/mri-stack.zip")
imp.show()
imp = imp.duplicate()
IJ.setAutoThreshold(imp, "Huang dark no-reset stack")
IJ.run(imp, "Convert to Mask", "method=Huang background=Dark black")
imp.setTitle("Threshold stack")
imp.show()

