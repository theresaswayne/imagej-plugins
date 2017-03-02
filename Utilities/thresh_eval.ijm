// IJ1 macro to help evaluate thresholding methods by adding masks quickly to ROI Manager
// usage:  have mask image open, run macro, or run in Batch Macro window (output is dispensable)
// input: tested on single-channel single-slice images.
// output: ROI Manager set with descriptive names. Then you can apply the ROIs to your raw image.

// data for testing
// run("Blobs (25K)");
// run("Make Binary");
// end testing

name = getTitle();
run("Create Selection");
roiManager("Add");
index = roiManager("count") - 1;
roiManager("Select", index);  // selects most recently added ROI
roiManager("Rename", name);
