// @File(label = "Image to analyze:") sourceimage
// @File(label = "Output folder:", style = "directory") outputdir

// Note: DO NOT DELETE OR MOVE THE FIRST 2 LINES -- they supply essential parameters.

// IB mask and intensity meas.ijm
// ImageJ/Fiji macro
// Theresa Swayne, tcs6@cumc.columbia.edu, 2017
// Measures inclusion body in 2-channel time-lapse images.
// Allows user to mark background in each channel.
//
// Input: A 2-channel, single-plane time-lapse series
// Output: Results table containing background measurement and inclusion measurements for both channels, all timepoints.
// Usage: Run the macro. (Image should not be open before running)

// setup -- clear results and ROI Manager
run("Clear Results");
roiManager("reset");

// get file info 
open(sourceimage);
id = getImageID();
title = getTitle();
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);

// get background measurement
setTool("freehand");
waitForUser("Mark background", "Draw a background area that works for both channels, then click OK");
run("Set Measurements...", "area mean min centroid integrated display redirect=None decimal=3");

// for each channel
for (i = 1; i < 3; i++) { // loop runs 2x

	print("Processing channel",i);
	channelName = basename+"_C"+i;
//	print("will rename to "+channelName);
	channelMask = channelName+"_m";

	// make a copy
	selectImage(id); // original 2-channel image
	run("Select None"); // get rid of the ROI temporarily, or else image will be cropped
	run("Duplicate...", "title=&channelName duplicate channels="+i);

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
	setThreshold(lowerThresh, 4095); // lower = 150% of the mean 
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark black");
	
	// remove stray pixels
	run("Options...", "iterations=1 count=1 black edm=16-bit do=Open stack");

	print("finished with channel",i);
	}

// OR the two channels -- generally gives the larger inclusion
channel1Name = basename + "_C1";
channel2Name = basename + "_C2";

imageCalculator("OR create stack", channel1Name+"_m",channel2Name+"_m");
selectWindow("Result of "+channel1Name+"_m");
rename("inclusion_mask");

// find particles in the OR image, and measure each one in each channel of the original image

selectWindow("inclusion_mask");
run("Set Measurements...", "area mean min centroid integrated display redirect=["+channel1Name+"] decimal=3");
run("Analyze Particles...", "display exclude stack");

selectWindow("inclusion_mask");
run("Set Measurements...", "area mean min centroid integrated display redirect=["+channel2Name+"] decimal=3");
run("Analyze Particles...", "display exclude stack");

// clean up
//selectWindow(channel1Name);
//close();

//selectWindow(channel2Name);
//close();

run("Set Measurements...", "area mean min centroid integrated display redirect=None decimal=3");
