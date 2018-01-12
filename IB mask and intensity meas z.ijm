// @File(label = "Input folder:", style = "directory") inputDir
// @String(label = "File suffix", value = ".tif") suffix
// @Byte(label = "Fluorescence channel", style = "spinner", value = 1) fluoChannel
// @File(label = "Output folder:", style = "directory") outputDir

// Note: DO NOT DELETE OR MOVE THE FIRST FEW LINES -- they supply essential parameters.

// IB mask and intensity meas z.ijm
// ImageJ/Fiji macro
// Theresa Swayne, tcs6@cumc.columbia.edu, 2017-018
// Measures inclusion body in fluorescence z-series images.
// Allows user to mark background.
//
// Input: A folder of 2-channel, single-time z series where one channel is brightfield. Each image should represent 1 cell.
// Output: Results table containing background measurement and inclusion measurements for the brightest z plane.
// Usage: Run the macro. (Image should not be open before running)

// setup -- clear results and ROI Manager
run("Clear Results");
roiManager("reset");

run("Input/Output...", "file=.csv copy_row save_row"); // saves data as csv, preserves headers, preserves row number for copy/paste 
run("Set Measurements...", "area shape feret's display stack redirect=None decimal=2");

// add headers to results file
IBheaders = ",Label,Area,foo";
File.append(IBheaders,outputDir  + File.separator+ "IB_results.csv");

n = 0;
processFolder(inputDir); // this actually executes the functions

// recursively process folders
function processFolder(dir1) 
	{
	list = getFileList(dir1);
   for (i=0; i<list.length; i++) 
   		{
        if(File.isDirectory(dir1 + File.separator + list[i])){
			processFolder("" + dir1 +File.separator+ list[i]);}
        else if (endsWith(list[i], suffix)){
           	processImage(dir1, list[i]);}
		}
	}


// processing steps to be done on each image
function processImage(dir1, sourceImage) 
	{
	open(dir1+File.separator+sourceImage);
	print("processing",n++, sourceImage);
	
	// get file info 
	id = getImageID();
	title = getTitle();
	dotIndex = indexOf(title, ".");
	basename = substring(title, 0, dotIndex);
	
	// get background measurement
	setTool("freehand");
	waitForUser("Mark background", "Draw a cytoplasmic background area, then click OK");
	run("Set Measurements...", "area mean min centroid integrated stack display redirect=None decimal=3");
	
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
	run("Set Measurements...", "area mean min centroid integrated stack display redirect=["+channelName+"] decimal=3");
	run("Analyze Particles...", "display exclude stack");

	} // end of image processing loop
	
// clean up

run("Set Measurements...", "area mean min centroid integrated stack display redirect=None decimal=3");
