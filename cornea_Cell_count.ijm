// cornea_Cell_count.ijm
// IJ macro to count bright cells in microscopic images of cornea
// similar to https://goo.gl/images/vX4Mtd
// input: single image
// output: point selection and measurements of local maxima corresponding to cells
// usage: Open the image. Run the macro.
// note: Parameters in ALLCAPS are for cells with diameter ~15-30 pixels. 
// Images with a different cell size may require adjustment.

FLATFIELD_BLURRING = 40;
CLAHE_BLOCKSIZE = 39;
GAUSS_SIGMA = 2;
MEDIAN_RADIUS = 2;

run("8-bit"); // needed for RGB images; omit if image is already 8- or 16-bit
title = getTitle();
newname = title+"-1";
run("Duplicate...", "title=" + newname); 
run("Pseudo flat field correction", "blurring="+FLATFIELD_BLURRING);
selectWindow(newname);
run("Enhance Local Contrast (CLAHE)", "blocksize="+CLAHE_BLOCKSIZE+" histogram=256 maximum=3 mask=*None* fast_(less_accurate)");
run("Gaussian Blur...", "sigma="+GAUSS_SIGMA);
run("Median...", "radius="+MEDIAN_RADIUS);
// run("Enhance Local Contrast (CLAHE)", "blocksize=39 histogram=256 maximum=3 mask=*None*");
selectWindow(newname);
run("Select None");
run("Find Maxima...", "noise=20 output=[Point Selection] exclude");
selectWindow(newname);
roiManager("Add");
roiManager("Measure");

// TODO: check for image type and convert only if needed
