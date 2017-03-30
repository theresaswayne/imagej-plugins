// cornea_Cell_count.ijm
run("8-bit");
title = getTitle();
newname = title+"-1";
run("Duplicate...", "title=" + newname); 
run("Pseudo flat field correction", "blurring=40");
selectWindow(newname);
run("Enhance Local Contrast (CLAHE)", "blocksize=39 histogram=256 maximum=3 mask=*None* fast_(less_accurate)");
run("Gaussian Blur...", "sigma=2");
run("Median...", "radius=2");
// run("Enhance Local Contrast (CLAHE)", "blocksize=39 histogram=256 maximum=3 mask=*None*");
selectWindow(newname);
run("Select None");
run("Find Maxima...", "noise=20 output=[Point Selection] exclude");
selectWindow(newname);
roiManager("Add");
roiManager("Measure");
