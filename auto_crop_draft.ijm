
// auto crop images -- draft

run("Z Project...", "projection=[Max Intensity]");
setAutoThreshold("Huang dark");
setOption("BlackBackground", true);
run("Convert to Mask");
run("Close-");
// TODO: refine edges more
// note -- sum proj has cleaner edges but may split cells more

run("Ultimate Points"); // generates points with value proportional to size of object they're the center of

setThreshold(10, 255); // TODO: decide best threshold (scaling?)
run("Analyze Particles...", "size=1-1 pixel display exclude clear add");

// TODO: Iterate through manager or results table

// for each point
// select original image 
// create ROI rectangle roughly 12 x 12 um centered on the point
// duplicate (crops to the roi, preserves original)
// save the file

// TODO: investigate if this can be done better with trans.
// could look for high values of the gradient/LoG within a sliding window