//@File(label = "Output image folder:", style = "directory") imagePath
//@File(label = "Output ROI folder:", style = "directory") roiPath
//
// crop_To_Roi.ijm
// ImageJ/Fiji macro by Theresa Swayne, Columbia University, 2017-2025
// Input: An image or hyperstack and a set of ROIs in the ROI manager 
// Output: A stack (or single plane) corresponding to each ROI, 
//		plus a snapshot of the ROI locations.
// 		Output images are numbered from 0 to the number of ROIs, 
//		and are saved in a folder of the user's choice.
//		Non-rectangular ROIs are cropped to their bounding box and the area outside the ROI is cleared to black.
//		The ROIs are also saved with their numbers, using the same base name as the image.
// Special feature: fixes colors that are messed up by exporting Volocity OME TIFFs
// Usage: Open an image. For each area you want to crop out, 
// 		draw an ROI and press T to add to the ROI Manager. (Or open a saved ROIset.)
//		Then run the macro.

// ---- Setup ----

IJ.log("\\Clear");
//path = getDirectory("image");
id = getImageID();
title = getTitle();
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);

// make sure nothing selected to begin with
selectImage(id);
roiManager("Deselect");
run("Select None");

// check for ROIs
numROIs = roiManager("count");
if (numROIs == 0) {
	showMessage("There are no ROIs saved. Draw ROIs around cells and press T to add each one to the Manager. Then run the macro.");
	exit;
}
// how much to pad ROI numbers?
digits = Math.ceil((log(numROIs+1)/log(10))); // the +1 is to handle 10 ROIs

setBackgroundColor(0, 0, 0); // set background to black for proper clearing outside 

// ---------- DOCUMENT ROI LOCATIONS


// fix colors for Cue5 images
Stack.setDisplayMode("color");
Stack.setChannel(3);
run("Grays");
resetMinAndMax;
Stack.setChannel(4);
run("Red");
resetMinAndMax;
Stack.setChannel(5);
run("Green");
resetMinAndMax;

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
//Stack.setPosition(channel, slice, frame); // restore the previous setup
run("Flatten");
flatID = getImageID();
selectImage(flatID);
saveAs("tiff", imagePath + File.separator + basename + "_ROIlocs.tif");

print("Saved snapshot");

// clean up snapshot images
if (isOpen(flatID)) {
	selectImage(flatID);
	close();
}
if (isOpen(rgbID)) {
	selectImage(rgbID);
	close();
}
	
// Number and save ROIs

// make sure nothing is selected to begin with
selectImage(id);
roiManager("Deselect");
run("Select None");

for(roiIndex=0; roiIndex < numROIs; roiIndex++) // loop through ROIs
	{ 
	selectImage(id);
	roiNum = roiIndex + 1; // so that image names start with 1 like the ROI labels
	roiNumPad = IJ.pad(roiNum, digits);
	cropName = basename + "_roi_"+ roiNumPad + ".tif";
	roiManager("Select", roiIndex);  // ROI indices start with 0
	roiManager("Rename", roiNum); // ROI names will start with 1
	run("Duplicate...", "title=&cropName duplicate"); // creates the cropped stack
	selectWindow(cropName);
	
	// if non-rectangular, clear outside
	if ((selectionType() != 0) && (selectionType() != -1)) {
		run("Clear Outside","stack"); // this works because non-rectangular rois are still active on the cropped image
		run("Select None");// clears the selection that is otherwise saved with the image (although it can be recovered with "restore selection")
	}
	
	saveAs("tiff", imagePath + File.separator + cropName);
	print("Saved",cropName);
	close();
	}	
	
// Save ROI set
run("Select None");
roiManager("Deselect"); 
roiSetName = basename + ".zip";
roiManager("Save", roiPath + File.separator +roiSetName);
print("Saved ROI set",roiSetName);

// ---------- CLEANUP

run("Select None");
print("Saved",numROIs,"cropped areas. Finished.");
//close();
