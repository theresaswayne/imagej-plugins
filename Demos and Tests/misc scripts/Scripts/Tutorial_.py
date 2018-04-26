from ij import IJ
from ij.io import FileSaver
from os import path

imp=IJ.getImage()
fs=FileSaver(imp)

folder="/Users/confocal/Desktop/jython"

if path.exists(folder) and path.isdir(folder):
	print "hooray. folder exists:",folder
	filepath=path.join(folder,"newboats.tif")
	if path.exists(filepath):
		print "File already exists. Saving canceled."
	elif fs.saveAsTiff(filepath):
 		print "file saved successfully at ",filepath
else:
	print "either folder ",folder," does not exist or it's not a folder. boo."
