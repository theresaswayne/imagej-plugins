// ImageJ macro to create an image with a polygon ROI, generate a mask from the ROI, and adjust the values of the mask to 0,1
// HiLo LUT is used to show the mask more clearly

newImage("HyperStack", "8-bit composite-mode label", 200, 200, 4, 1, 1);
setForegroundColor(137, 137, 137);
run("Select All");
run("Fill", "slice");
makePolygon(112,49,47,91,114,151,173,119,153,40);
run("Create Mask");
run("Divide...", "value=255");
run("HiLo");
