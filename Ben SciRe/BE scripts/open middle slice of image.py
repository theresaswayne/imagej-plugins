from ij import IJ, ImagePlus, ImageStack
from ij.io import DirectoryChooser
import os

dc = DirectoryChooser("Choose directory with stacks")
srcDir = dc.getDirectory()
tarDir = DirectoryChooser("Choose target directory").getDirectory()
 
def extractChannel(imp, nChannel, nFrame):
 #get the stack of the image
 print(imp)
 stack = imp.getImageStack()
 #dimensions of image
 ch = ImageStack(imp.width, imp.height)
 # find middle index (slice) of the image you want
 index = imp.getStackIndex(nChannel, ((imp.getNSlices()/2)+1), nFrame)
 # add slice to channel
 ch.addSlice(str(((imp.getNSlices()/2)+1)), stack.getProcessor(index))
 print(index)
 return ImagePlus("Channel " + str(nChannel), ch)
 print("Slices", imp.getNSlices)
 
 
# PUT FOR LOOP HERE: CYCLING THROUGH ALL IMAGES IN A DIRECTORY 

#ChatGPT helped me figure out an error called: "AttributeError: 'NoneType' object has no attribute 'getImageStack'"
for filename in os.listdir(srcDir):
    # Get the image path
    imagePath = os.path.join(srcDir, filename)
    # Open image
    imp = IJ.openImage(imagePath)
    print("Got image", filename)
    # Process the image if opened successfully
    if imp:
        imp.show()
        if filename.lower().endswith(".tif"):
            extracted_image = extractChannel(imp, 0, 1)
        if extracted_image:
            extracted_image.show()
            if filename.lower().endswith(".tif"):
                newFilename = filename[:-4] + "_middle_slice.tif"
                targetPath = os.path.join(tarDir, newFilename)
                IJ.saveAs(extracted_image, "Tiff", targetPath)
            # Close the image after processing
            extracted_image.close()
        imp.close()  # Close the original image after processing
    else:
        print("Failed to open image:", filename)