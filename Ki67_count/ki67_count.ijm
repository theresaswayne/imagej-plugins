// ki67_count.ijm
// ImageJ macro
// Theresa Swayne, tcs6 at cumc.columbia.edu, 2018

// Counts DAPI-labeled nuclei and calculates the percentage labeled by Ki67
// Input: 2-channel ND2 image with DAPI first
// Output:

// Usage: 

// setup
run("Set Measurements...", "area mean centroid display redirect=None decimal=3");
run("Clear Results");

// open ND2 image
// split channels

// segment channel 1 (dapi)

// Under: intermodes gets all but faint cells;  Li gets most of faint cells also
// Best: MaxEntropy, Yen, RenyiEntropy 
// Over: Default gets grainy background 

METHOD = "MaxEntropy";

run("Duplicate...", "title=&METHOD");
setAutoThreshold(METHOD+" dark");
setOption("BlackBackground", true);
run("Convert to Mask");
run("Close"); // for hollow-looking nuclei
run("Fill Holes"); // for hollow-looking nuclei
run("Open");
run("Watershed");
run("Create Selection");
roiManager("Add");
lastROI = roiManager("count")-1; // ROI manager count starts at 0
roiManager("Select", lastROI);
roiManager("Rename", "nuclei "+METHOD);
run("Select None");


// analyze particles to get total cell count and intensity in channel 2

selectWindow(METHOD);
run("Set Measurements...", "area mean centroid display redirect=[C2-1-BeWo NS- DMSO-1-2-20x.tif] decimal=3");
run("Analyze Particles...", "display exclude");

// save output file -- first save each particle to figure out cutoff (make histogram of distribution)


// clean up
run("Set Measurements...", "area mean centroid display redirect=None decimal=3");