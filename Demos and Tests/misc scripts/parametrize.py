# @ImagePlus source
# @ImagePlus target

from ij import IJ

def run():
	# ensure images are compatible
	if source.getStackSize() != target.getStackSize():
		IJ.error("Source and target images must have same stack size.")
		return
	# copy the labels
	for i in range(1, source.getStackSize()):
		label = source.getStack().getSliceLabel(i)
		target.getStack().setSliceLabel(label, i)

run()