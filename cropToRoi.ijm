// crop_To_Roi.ijm
// ImageJ/Fiji macro by Theresa Swayne, tcs6@cumc.columbia.edu, 2017
// Input: A stack (or single plane) and a set of ROIs in the ROI manager 
// Output: A stack (or single plane) corresponding to each ROI. 
// 		Output images are numbered from 0 to the number of ROIs, 
//		and are saved in the same folder as the source image.
//		Non-rectangular ROIs are cropped to their bounding box.
// Usage: Open an image. For each area you want to crop out, 
// 		draw an ROI and press T to add to the ROI Manager.
//		Then run the macro.

path = getDirectory("image");
id = getImageID();
title = getTitle();
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);

// make sure nothing selected to begin with
selectImage(id);
roiManager("Deselect");
run("Select None");

numROIs = roiManager("count");
for(i=0; i<numROIs;i++) // loop through ROIs
	{ 
	selectImage(id);
	cropName = basename+i;
	roiManager("Select", i); 
	run("Duplicate...", "title=&cropName duplicate"); // creates the cropped stack
	selectWindow(cropName);
	saveAs("tiff", path+getTitle);
	close();
	}	
run("Select None");

