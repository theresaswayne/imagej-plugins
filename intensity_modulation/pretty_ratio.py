#@ File    (label = "Input directory", style = "directory") srcFile
#@ File    (label = "Output directory", style = "directory") dstFile
#@ String  (label = "File extension", value=".tif") ext
#@ String  (label = "File name contains", value = "") containString
#@ OpService ops
#@OUTPUT Dataset output
#@ DatasetService ds
#@ DatasetIOService io

# pretty_ratio.py
# working title for script to generate background-subtracted, intensity-modulated ratio images
# goals: generating an image suitable for publication with color scale, also saving a raw image suitable for quantitation
# possibly configurable choice of intensity standard

# ---- user input:
# numerator and denominator (TODO: decide if working from 2-channel images or split)
# threshold per channel: constant value or ROI chosen interactively (save the values)
# scheme for weighted averaging of components to get intensity -- collect coefficients for each

# ---- interactive background selection & subtraction

# ---- do something to avoid div by 0 (add 1? set NaN?)

# ---- division of images to get 32 bit raw ratio -- (save it)

# ---- calculation of intensity image

# ---- creation of IM image through conversion to HSV and back to RGB (with proper scaling)

# ---- placing of color scale and saving of image

# ---- saving of a tidy log with file names, threshold, perhaps min and max of images and of ratio

# TEST 1. Collect each image in a folder and (invert it or something simple)(TEST 2: do arithmetic on 2 of its channels). 
# Then save the result.

import os
from ij import IJ, ImagePlus

def run(): # from IJ process folder python template
  srcDir = srcFile.getAbsolutePath()
  dstDir = dstFile.getAbsolutePath()
  for root, directories, filenames in os.walk(srcDir):
    filenames.sort();
    for filename in filenames:
      # Check for file extension
      if not filename.endswith(ext):
        continue
      # Check for file name pattern
      if containString not in filename:
        continue
      process(srcDir, dstDir, root, filename)
 
def process(srcDir, dstDir, currentDir, fileName):
  print "Processing:"
   
  # Opening the image
  print "Open image file", fileName
  imp = IJ.openImage(os.path.join(currentDir, fileName)) # TODO: Replace with IJ2 equivalent
   
  # Put your processing commands here!  # TODO: Replace with some IJ2 operation
   
  # Saving the image

  print "Saving to", dstDir
  IJ.saveAs(imp, "Tiff", os.path.join(dstDir, fileName));  # TODO: Replace with IJ2 equivalent
  imp.close()
 
run()
