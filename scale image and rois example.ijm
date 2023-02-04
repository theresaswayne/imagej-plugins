// scale image and rois example.ijm
// code snippet to show how to scale all ROIs so they mark the correct areas on a downsampled image

// setup
roiManager("reset");

//open sample image
run("Blobs (25K)");

// add some ROIs -- these should box several blobs 
makeRectangle(58, 20, 35, 43);
roiManager("Add");
makeRectangle(183, 36, 23, 46);
roiManager("Add");
makeRectangle(159, 216, 46, 29);
roiManager("Add");
makeRectangle(32, 158, 27, 31);
roiManager("Add");

// add some irregular ROIs -- these should outline several blobs
doWand(77, 41, 70.0, "Legacy");
roiManager("Add");
doWand(133, 121, 70.0, "Legacy");
roiManager("Add");
doWand(102, 212, 70.0, "Legacy");
roiManager("Add");
doWand(183, 224, 70.0, "Legacy");
roiManager("Add");
doWand(38, 168, 70.0, "Legacy");
roiManager("Add");

roiManager("Show All with labels");

run("In [+]");
showMessage("Click OK to bin and scale.");

run("Duplicate...", "title=binned");

// bin the image by summing 2x2 arrays
// make the image 32-bit to avoid saturation
selectWindow("binned");
run("32-bit");
run("Bin...", "x=2 y=2 bin=Sum");
// reset the contrast so we can see the blobs
//run("Enhance Contrast", "saturated=0.35");
resetMinAndMax();

// select all ROIs and scale them
numROIs = roiManager("count");
roiManager("deselect"); // select all
RoiManager.scale(0.5, 0.5, false); // 'Centered' box is unchecked

selectWindow("binned");
roiManager("Show All with labels");
// zoom to same size as original image
run("In [+]");
run("In [+]");
run("In [+]");



