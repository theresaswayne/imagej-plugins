// @File(label = "Image to analyze:") sourceImage
// @Byte(label = "Fluorescence channel", style = "spinner", value = 1) fluoChannel
// @File(label = "Output folder:", style = "directory") outputDir

// Note: DO NOT DELETE OR MOVE THE FIRST 2 LINES -- they supply essential parameters.

// IB mask and intensity meas z.ijm
// ImageJ/Fiji macro
// Theresa Swayne, tcs6@cumc.columbia.edu, 2017-018
// Measures inclusion body in fluorescence z-series images.
// Allows user to mark background.
//
// Input: A 2-channel, single-time z series where one channel is brightfield. The image should represent 1 cell.
// Output: Results table containing background measurement and inclusion measurements for the brightest z plane.
// Usage: Run the macro. (Image should not be open before running)

// TODO: save results to file, allow append and/or batch

// setup -- clear results and ROI Manager
run("Clear Results");
roiManager("reset");

// get file info 
open(sourceImage);
id = getImageID();
title = getTitle();
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);

// get background measurement
setTool("freehand");
waitForUser("Mark background", "Draw a cytoplasmic background area, then click OK");
run("Set Measurements...", "area mean min centroid integrated display redirect=None decimal=3");

print("Processing channel",fluoChannel);
channelName = basename+"_C"+fluoChannel;
channelMask = channelName+"_m";

// make a copy
selectImage(id); // original 2-channel image
run("Select None"); // get rid of the ROI temporarily, or else image will be cropped
run("Duplicate...", "title=&channelName duplicate channels="+fluoChannel);

// measure background
selectWindow(channelName);
run("Restore Selection");
run("Measure"); // gets the original image measurement
channelBackground = getResult("Mean",nResults-1); // from the last row of the table
run("Select None"); 

// make initial mask
selectWindow(channelName);
run("Duplicate...", "title=&channelMask duplicate");	
lowerThresh = 1.5 * channelBackground;
print("Threshold = ",lowerThresh);
setThreshold(lowerThresh, 4095); // lower = 150% of the mean 
setOption("BlackBackground", false);
run("Convert to Mask", "method=Default background=Dark black");
rename("inclusion_mask");

// remove stray pixels
run("Options...", "iterations=1 count=1 black edm=16-bit do=Open stack");

print("finished with channel",fluoChannel);

// find particles, and measure each one in each channel of the original image

selectWindow("inclusion_mask");
run("Set Measurements...", "area mean min centroid integrated display redirect=["+channelName+"] decimal=3");
run("Analyze Particles...", "display exclude stack");

// clean up

run("Set Measurements...", "area mean min centroid integrated display redirect=None decimal=3");
