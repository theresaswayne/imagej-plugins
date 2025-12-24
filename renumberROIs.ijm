// crop_To_Roi.ijm
// ImageJ/Fiji macro by Theresa Swayne, tcs6@cumc.columbia.edu, 2017
// Input: A stack (or single plane) and a set of ROIs in the ROI manager 
// Output: A stack (or single plane) corresponding to each ROI, 
//		plus a snapshot of the ROI locations.
// 		Output images are numbered from 0 to the number of ROIs, 
//		and are saved in the same folder as the source image.
//		Non-rectangular ROIs are cropped to their bounding box.
//		The ROIs are also saved with their numbers, using the same base name as the image.
// Usage: Open an image. For each area you want to crop out, 
// 		draw an ROI and press T to add to the ROI Manager. (Or open a saved ROIset.)
//		Then run the macro.

// ---- Setup ----

IJ.log("\\Clear");
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
// how much to pad?
digits = Math.ceil((log(numROIs+1)/log(10))); // the +1 is to handle 10 ROIs


// ---------- DOCUMENT ROI LOCATIONS

// save a snapshot
Stack.getPosition(channel, slice, frame); // how does the user currently have the stack set up
if (is("composite")) {
	Stack.setDisplayMode("composite"); // this command raises error if image is not composite
	run("Stack to RGB", "keep");
}
else {
	run("Select None");
//	run("Duplicate...", "title=copy duplicate"); // for single-channel non-RGB images; Flatten doesn't create new window
	run("Duplicate...", "title=copy"); // for single-channel non-RGB images; Flatten doesn't create new window
}
rgbID = getImageID();
selectImage(rgbID);

roiManager("Show All with labels");
Stack.setPosition(channel, slice, frame); // restore the previous setup
run("Flatten");
flatID = getImageID();
selectImage(flatID);
saveAs("tiff", path+File.separator+basename+"_ROIlocs.tif");

print("Saved snapshot");

// close images
if (isOpen(flatID)) {
	selectImage(flatID);
	close();
}
if (isOpen(rgbID)) {
	selectImage(rgbID);
	close();
}
	
for(i=0; i<numROIs;i++) // loop through ROIs
	{ 
	selectImage(id);
	roiNum = i + 1; // so that image names start with 1 like the ROI labels
	roiNumPad = IJ.pad(roiNum, digits);
	cropName = basename+"_roi_"+roiNumPad + ".tif";
	roiManager("Select", i);
	roiManager("Rename", roiNum);
	run("Duplicate...", "title=&cropName duplicate"); // creates the cropped stack
	selectWindow(cropName);
	saveAs("tiff", path + File.separator + cropName);
	print("Saved",cropName);
	close();
	}	
	
// Save ROI set
run("Select None");
roiManager("Deselect"); 
roiSetName = basename + ".zip";
roiManager("Save", path + File.separator +roiSetName);
print("Saved ROI set",roiSetName);


