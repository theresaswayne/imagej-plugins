// threshold_eval.ijm
// IJ1 macro to test and evaluate thresholding methods with pre-processing
// Theresa Swayne, tcs6@cumc.columbia.edu, 2017
// usage:  have an image open, run macro
// input: tested on single-channel single-slice images.
// output: series of masks thresholded by different methods, and ROIs corresponding to the masks 
// global thresholds are printed to the log window
// (local thresholds cannot be documented because they vary by definition)

// ----- setup

LOCALMETHODS = newArray("Bernsen","Mean","Median","Otsu","Niblack","Phansalkar"); // to try selected methods
//LOCALMETHODS = newArray("Bernsen", "Contrast", "Mean", "Median", "MidGrey", "Niblack","Otsu", "Phansalkar", "Sauvola") // to try all methods as of 5/17
GLOBALMETHODS = newArray("Default","Huang","Li","Mean","MinError(I)","Moments","Triangle"); // to try selected methods
//GLOBALMETHODS = getList("threshold.methods"); // to try all methods

id = getImageID();
roiManager("Reset");

// ---- functions to do thresholding and store ROIs

function localthresh(id, method) {
	// id = integer, imageID of active image
	// method = string specifying the method
	selectImage(id);
//	newName = substring(method, 0, 3) + "_" + getTitle();
	newName = method + "_" + getTitle();
	print(newName);
	run("Duplicate...", "title=" + "["+newName+"]");
	selectWindow(newName);
//	setAutoThreshold(method);
	run("Auto Local Threshold", "method="+method+" radius=40 parameter_1=0 parameter_2=0 white");
	run("Convert to Mask");
	mask_to_ROI(newName);
//	save();
	return;
	}

function globalthresh(id, method) {
	// id = integer, imageID of active image
	// method = string specifying the method
	selectImage(id);
//	newName = substring(method, 0, 3) + "_" + getTitle();
	newName = method + "_" + getTitle();
	print(newName);
	run("Duplicate...", "title=" + "["+newName+"]");
	selectWindow(newName);
//	setAutoThreshold(method);
	run("Auto Threshold", "method="+method+" white show");
	run("Convert to Mask");
	mask_to_ROI(newName);
//	save();
	return;
	}

function mask_to_ROI(mask) {
	// input: a mask image
	// creates an ROI named after the mask
	selectWindow(mask);
	name = getTitle();
	run("Create Selection");
	roiManager("Add");
	index = roiManager("count") - 1;
	roiManager("Select", index);  // selects most recently added ROI
	roiManager("Rename", name);
	roiManager("Deselect");
	return;

}
// ----- pre-processing -- adjust as needed
//run("Subtract Background...", "rolling=50");
//run("Gaussian Blur...", "sigma=1");
//run("Enhance Local Contrast (CLAHE)", "blocksize=49 histogram=256 maximum=3 mask=*None*");

// ---- local thresholding
for (i = 0; i < LOCALMETHODS.length; i++) 
	{
	localthresh(id, LOCALMETHODS[i]);
	}

// ----- global thresholding
for (i = 0; i < GLOBALMETHODS.length; i++) 
	{
	globalthresh(id, GLOBALMETHODS[i]);
	}
// ----- clean up display and restore unprocessed original image

selectImage(id);
run("Revert");
run("Tile");


//thresh(id, "Default dark");
//thresh(id, "IsoData dark");
//thresh(id, "Otsu dark");
//thresh(id, "Triangle dark");
//thresh(id, "Huang dark");


//run("GreyWhiteTopHatByReconstruction ");
//run("GreyscaleReconstruct ", "mask=[C2-aCC-1 - Arc + cfos_1_1L 01 bgsub.tif] seed=[C2-aCC-1 - Arc + cfos_1_1L 06 gaus 1 Maxima.tif] create 4");
//run("Find Maxima...", "noise=20 output=[Single Points]");
