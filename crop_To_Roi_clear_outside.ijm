// @File(label = "Output folder:", style = "directory") outputdir
// @Byte(label = "Mito channel", style = "spinner", value = 1) mitoChannel

// DO NOT MOVE OR DELETE THE FIRST FEW LINES! They supply essential parameters.
//
// crop_To_Roi_mitograph.ijm
// ImageJ/Fiji macro by Theresa Swayne, Columbia University, 2017
//
// Input: A multichannel image or stack, and a set of ROIs in the ROI manager 
// Output: The following items are saved in the same folder as the input image: 
// -- A cropped image or stack for each ROI, in the mitochondrial channel selected by the user. 
// 		Output images are numbered from 1 to the number of ROIs.
//		Non-rectangular ROIs are cropped to their bounding box, but the area outside the ROI is cleared to black.
// -- An ROI set (.zip file) containing the ROIs.
// -- A snapshot of the ROI locations on the composite image, using the current display settings.
//
// Usage: Open an image. 
//		For each area you want to crop out, draw an ROI and press T to add to the ROI Manager.
//		Then run the macro.

// ---------- SETUP

id = getImageID();
title = getTitle();
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);

// check for ROIs
numROIs = roiManager("count");
if (numROIs == 0) {
	showMessage("There are no ROIs saved. Draw ROIs around cells and press T to add each one to the Manager. Then run the macro.");
	exit;
}

// check for bad mito channel choice
Stack.getDimensions(width, height, channels, slices, frames);
if (mitoChannel > channels) {
	showMessage("There are not enough channels in the dataset. Check the mito channel and re-run the macro.");
	exit;
}

print("Processing image",basename,"channel",mitoChannel);

setBackgroundColor(0, 0, 0); // set background to black for proper clearing outside 

// ---------- DOCUMENT ROI LOCATIONS

// save ROIs to show location of each cell
roiManager("save",outputdir+File.separator+basename+"_ROIs.zip");

// save a snapshot
if (is("composite")) {
	Stack.setDisplayMode("composite"); // this command raises error if image is not composite
	run("Stack to RGB", "keep");
}
else {
	run("Select None");
	run("Duplicate...", "title=copy duplicate"); // for single-channel non-RGB images; Flatten doesn't create new window
}
rgbID = getImageID();
selectImage(rgbID);
roiManager("Show All with labels");
run("Flatten", "stack");
flatID = getImageID();
selectImage(flatID);
saveAs("tiff", outputdir+File.separator+basename+"_ROIlocs.tif");

print("Saved ROIs and snapshot.");

// clean up snapshot images
if (isOpen(flatID)) {
	selectImage(flatID);
	close();
}
if (isOpen(rgbID)) {
	selectImage(rgbID);
	close();
}

// ---------- CROP AND SAVE

// make sure nothing is selected to begin with
selectImage(id);
roiManager("Deselect");
run("Select None");


for(roiIndex=0; roiIndex < numROIs; roiIndex++) // loop through ROIs
	{ 
	selectImage(id);
	roiNum = roiIndex + 1; // image names starts with 1 like the ROI labels
	cropName = basename+"_crop"+roiNum;
	roiManager("Select", roiIndex);  // ROI indices start with 0
	run("Duplicate...", "title=&cropName duplicate channels="+mitoChannel); // creates the cropped stack
	selectWindow(cropName);
	run("Clear Outside","stack"); // this works because the roi is still active on the cropped image
	run("Select None");// clears the selection that is otherwise saved with the image (although it can be recovered with "restore selection")
	saveAs("tiff", outputdir+File.separator+getTitle);
	close();
	}	

// ---------- CLEANUP

run("Select None");
print("Saved",numROIs,"cropped areas. Finished.");
//close();
