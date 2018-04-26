from ij import IJ, ImagePlus, WindowManager
from ij.gui import GenericDialog

def run():
	# fail if no images are open
	wList = WindowManager.getIDList()
	if wList is None:
		IJ.noImage()
		return
	# build list of image titles
	titles = []
	for w in wList:
		imp = WindowManager.getImage(w)
		titles.append("" if imp is None else imp.getTitle())
	# prompt user for image inputs
	gd = GenericDialog("Label Copier")
	gd.addChoice("Source Image:", titles, titles[0])
	gd.addChoice("Target Image:", titles, titles[0])
	gd.showDialog()
	if gd.wasCanceled():
		return
	source = WindowManager.getImage(wList[gd.getNextChoiceIndex()])
	target = WindowManager.getImage(wList[gd.getNextChoiceIndex()])
	# ensure images are compatible
	if source.getStackSize() != target.getStackSize():
		IJ.error("Source and target images must have same stack size.")
		return
	# copy the labels
	for i in range(1, source.getStackSize()):
		label = source.getStack().getSliceLabel(i)
		target.getStack().setSliceLabel(label, i)

run()