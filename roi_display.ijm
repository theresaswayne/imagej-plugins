// roi_display.ijm
// Theresa Swayne, Columbia University, 2017
// IJ1 macro that loads a previously saved ROIset and flattens it on the image, optionally using a multi-hue LUT to show variable cell intensity
// input: single-channel image, and a saved ROIset with appropriate filename in same directory 
// usage: open the image then run the macro. 

path = getDirectory("image");
id = getImageID();
title = getTitle();
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);

run("Select None");
run("Remove Overlay");
run("16 colors");
//roiManager("Open", path+"RoiSet_" + basename + ".zip");
roiManager("Open", path+ basename + ".zip");
roiManager("Show All without labels");
run("Flatten");
roiManager("Show None");
roiManager("reset");

selectWindow(basename+"-1.tif");
close();
