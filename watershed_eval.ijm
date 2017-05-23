// watershed_eval.ijm
// need to have the image active, and a list of ROIs, then run macro
// from a list of ROIs and an active image, generates the watershedded version of the ROI mask
 
title = getTitle();
numROIs = roiManager("count");

for (index = 0; index < numROIs; index++) {
	roiManager("Deselect");
	selectWindow(title);
	roiManager("Select", index);
	maskName = call("ij.plugin.frame.RoiManager.getName", index); // filename will be roi name
	run("Create Mask");
	selectWindow("Mask");
	rename(maskName);
	run("Watershed");
	roiManager("Select", index);
	run("Create Selection");
	roiManager("Update"); // now it's the watershedded version
	}

print("processed "+numROIs+" ROIs.")
