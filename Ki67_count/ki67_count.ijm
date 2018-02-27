// ki67_count.ijm
// ImageJ macro
// Theresa Swayne, tcs6 at cumc.columbia.edu, 2018

// Counts DAPI-labeled nuclei and calculates the percentage labeled by Ki67
// Input: 2-channel ND2 image with DAPI first

// ** include fainter, "hollow" looking cells? If so, need to fill holes

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
run("Open");
run("Watershed");
run("Create Selection");
roiManager("Add");
lastROI = roiManager("count")-1; // ROI manager count starts at 0
roiManager("Select", lastROI);
roiManager("Rename", "nuclei "+METHOD);
run("Select None");


// analyze particles to get total cell count
// analyze particles again, redirecting to measure intensity of channel 2 
// save output file -- first save each particle to figure out cutoff (make histogram of distribution)



