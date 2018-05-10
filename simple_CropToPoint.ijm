// @Integer(label = "Cropped image width, pixels:") cropWidth
// @Integer(label = "Cropped image height, pixels:") cropHeight
// @File(label = "Output folder:", style = "directory") outputdir

// simple_CropToPoint.ijm
// ImageJ/Fiji macro by Theresa Swayne
// Input: An open image (single plane or stack) and a set of single-point ROIs in the ROI manager.
// Output: For each point, the image is cropped to the specified size, centered on the point, in the same slice as the point ROI
// 		Output images are named with the original filename plus a numerical suffix from 0 to the number of point ROIs.
// Usage: Open an image. Mark points with the Point tool, or otherwise load them into ROI Manager. Run the macro. 

// get file info 
id = getImageID();
title = getTitle();
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);

selectImage(id);

numROIs = roiManager("count");
for(i=0; i<numROIs;i++) // loop through ROIs
	{ 
	selectImage(id); 
	cropName = basename+"_"+i; // this becomes the name of the cropped image
	roiManager("Select", i); 
	roiSlice = getSliceNumber();
	Roi.getCoordinates(x, y); // x and y are arrays
	run("Specify...", "width=&cropWidth height=&cropHeight x="+x[0]+" y="+y[0]+" slice=&roiSlice centered"); // rectangle ROI centered on the point
	run("Duplicate...", "title=&cropName"); // create the cropped image, relevant slice only
	selectWindow(cropName);
	saveAs("tiff", outputdir + File.separator + getTitle);
	close();
	}	
run("Select None");
