#@ File(label = "Input directory", style = "directory") srcDir
#@ File(label = "Output directory", style = "directory") dstDir

#@ String(label="Image File Extension", required=false, value=".tif") image_extension
#@ String(label = "File name contains", value = "") containString

#@ OpService ops

#@OUTPUT Dataset output

#@ DatasetService ds
#@ DatasetIOService io

# based on templates -- modifying to figure out how to open, process, save files in IJ2 python

# ----------- setup and imports

import os
from ij import IJ, ImagePlus

from net.imagej.axis import Axes
from net.imglib2.view import Views



#  ----------- helper functions

def process(source, dest, name):
	
	print("Processing: %s" % name)
	
	# Open image
	data = io.open(name)
	
	# output = Views.stack(stack)
	output_ds = ds.create(output)
		
	# Set the name of the dataset to the directory name
	output_ds.setName("output_file" + image_extension)
	
	# save 
	fileName = output_ds.getName()
	print("File name is %s" % fileName)
	print("Saving to  %s" % dstDir)
	io.save(output_ds, os.path.join(dest,fileName))
	print("done!")
	
#def run(srcDir, dstDir, image_extension, axis_type):
	
# Find image files
src = str(srcDir)
dst = str(dstDir)
fnames = []
for fname in os.listdir(src):
    if fname.endswith(image_extension):
		# Check for file name pattern
		if containString not in fname:
			continue
		fnames.append(os.path.join(srcDir, fname))
fnames = sorted(fnames)

if len(fnames) < 1:
    raise Exception("No matching image files found in %s" % srcDir)

# Process images
for fname in fnames:
	process(src, dst, fname)

# ----------- run

#run()
