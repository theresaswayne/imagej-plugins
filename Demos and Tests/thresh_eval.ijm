// thresh_eval.ijm
// IJ1 macro to help evaluate thresholding methods by generating a list of ROIs corresponding to the threshold masks.
// usage:  have mask image open, run macro, or run in Batch Macro window on a batch of masks (output is dispensable)
// input: tested on single-channel single-slice images.
// output: ROI Manager set with names = the name of the mask image (which is normally the name of the threshold method). 
// Then you can apply the ROIs to your raw image.

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
