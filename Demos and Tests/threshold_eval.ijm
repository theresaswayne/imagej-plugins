//@ string(label="Pre-processing", choices={"Median",  "Gaussian","None"}, style="listBox") PreProcess
//@ int(label="Pre-processing radius or sigma (ignore if not using)", value = 0) Radius 
//@ String (label = "Threshold type", choices={"Local", "Global"}, style="radioButtonHorizontal") Thresh_Type
//@ boolean(label = "Show all masks?") Show_Masks

// threshold_eval.ijm
// IJ1 macro to test and evaluate thresholding methods with pre-processing
// Theresa Swayne, tcs6@cumc.columbia.edu, 2017, revised 2023
// usage:  have an image open, run macro
// input: a single-channel single-slice image
// output: series of masks thresholded by different methods, and ROIs corresponding to the masks 
// global thresholds are printed to the log window
// Note: Some thresholds require 8-bit or 16-bit input.

// ----- setup ----

LOCALMETHODS = newArray("Bernsen","Mean","Median","Otsu","Niblack","Phansalkar"); // to try selected methods
//LOCALMETHODS = newArray("Bernsen", "Contrast", "Mean", "Median", "MidGrey", "Niblack","Otsu", "Phansalkar", "Sauvola") // to try all methods as of 5/17
//GLOBALMETHODS = newArray("Default","Huang","Li","Mean","MinError(I)","Moments","Triangle"); // to try selected methods
GLOBALMETHODS = getList("threshold.methods"); // to try all methods

id = getImageID();
roiManager("Reset");


// ----- pre-processing ----

if (PreProcess == "Median") {
	run("Median...", "radius=&Radius");
	print("Applied median filter with radius",Radius);
}

else if (PreProcess == "Gaussian") {
	run("Gaussian Blur...", "sigma=&Radius");
	print("Applied Gaussian blur with sigma",Radius);
}

else if (PreProcess == "None") {
	continue;
}

else {
	print("Pre-processing was not defined!");
}

// ---- Thresholding ----

if (Thresh_Type == "Local") {

	for (i = 0; i < LOCALMETHODS.length; i++) 
		{
		localthresh(id, LOCALMETHODS[i]);
		}
}

else if (Thresh_Type == "Global") {
	for (i = 0; i < GLOBALMETHODS.length; i++) 
	{
	globalthresh(id, GLOBALMETHODS[i]);
	}
}

else {
	print("Thresholding was not defined!");
}


// ----- display results and original image

selectImage(id);
run("Revert");
run("Tile");


// ---- helper functions ----

function localthresh(id, method) {
	// id = integer, imageID of active image
	// method = string specifying the method
	selectImage(id);
	newName = method + "_" + getTitle();
	print(newName);
	run("Duplicate...", "title=" + "["+newName+"]");
	selectWindow(newName);
	run("Auto Local Threshold", "method="+method+" radius=40 parameter_1=0 parameter_2=0 white");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	mask_to_ROI(newName, Show_Masks);
	return;
	}

function globalthresh(id, method) {
	// id = integer, imageID of active image
	// method = string specifying the method
	selectImage(id);
	newName = method + "_" + getTitle();
	print(newName);
	run("Duplicate...", "title=" + "["+newName+"]");
	selectWindow(newName);
	setAutoThreshold(method+" dark");
	//run("Convert to Mask", "method=&method background=Dark");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	//run("Auto Threshold", "method="+method+" white show");
	//run("Convert to Mask");
	mask_to_ROI(newName, Show_Masks);
	return;
	}

function mask_to_ROI(mask, show) {
	// mask: a binary image
	// creates an ROI named after the mask
	selectWindow(mask);
	name = getTitle();
	run("Create Selection");
	roiManager("Add");
	index = roiManager("count") - 1;
	roiManager("Select", index);  // selects most recently added ROI
	roiManager("Rename", name);
	roiManager("Deselect");
	resetThreshold();
	if (show == false) {
		print("masks hidden");
		selectWindow(name);
		close();
		}
	else if (show == true) {
		print("masks shown");
	}
	else {
		print("masks undefined!");
	}
	return;

}
