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

// TODO: If no particles found, or no pixels above threshold, (MAX <= thresh?)
//       1) skip measurement, 
//		 2) write a line to the IB results with blanks except for Label and Background

// setup -- clear results and ROI Manager
run("Clear Results");
roiManager("reset");

// save data as csv, preserve headers for saving, preserve row number for copy/paste 
run("Input/Output...", "file=.csv copy_row save_column save_row"); 
resultsFile = outputDir  + File.separator+ "IB_results.csv";

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


// processing steps for each image
function processImage(dir1, sourceImage) 
	{
	open(dir1+File.separator+sourceImage);
	print("processing",n++, sourceImage); // n is printed as original value, then incremented
	
	// get file info 
	id = getImageID();
	title = getTitle();
	dotIndex = indexOf(title, ".");
	basename = substring(title, 0, dotIndex);
	getDimensions(width, height, channels, slices, frames);
	
	// get background ROI
	middleSlice = slices/2;
	Stack.setPosition(fluoChannel, middleSlice, 1); // move to center slice
	setTool("freehand");
	waitForUser("Mark background", "Draw a cytoplasmic background area, then click OK");
	run("Set Measurements...", "area mean min centroid integrated stack display redirect=None decimal=3");
	
	// print("Processing channel",fluoChannel);
	channelName = basename+"_C"+fluoChannel;
	channelMask = channelName+"_m";
	
	// make a copy of the channel of interest and close original
	selectImage(title); // original 2-channel image
	run("Select None"); // get rid of the ROI temporarily, or else image will be cropped
	run("Duplicate...", "title=&channelName duplicate channels="+fluoChannel);
	selectWindow(title);
	close();
	
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
	
	// print("finished with channel",fluoChannel);
	
	// find particles, measure each one in the original image, save the mask as an ROI
	selectWindow("inclusion_mask");

	// check if there are any pixels to measure
	Stack.getStatistics(voxelCount, mean, min, max, stdDev);
	print("The max value in stack is",max);

	if (max==0){ // no pixels above threshold, therefore don't measure particles
		resultsForNoParticles();
	}
	else { 
		measureParticles();
	}


	// clean up windows and results
	selectWindow("inclusion_mask");
	close();
	selectWindow(channelName);
	close();
	run("Clear Results");
	
	} // end of image processing loop
	
// clean up
run("Set Measurements...", "area mean min centroid integrated stack display redirect=None decimal=3");
print("Finished with",n,"images.");

function measureParticles() {
	// carry out particle analysis and writing results
	print("Measuring particles.");
	run("Set Measurements...", "area mean min centroid integrated stack display redirect=["+channelName+"] decimal=3");
	run("Analyze Particles...", "display clear exclude add stack");

	if (roiManager("count") == 0){ // for the case when there are positive pixels but no particles -- presumably on the edges.
		resultsForNoParticles();
	}
	else { // we have particles and results

		// save particles
		roiManager("Save", outputDir + File.separator + channelName+".zip");
		roiManager("reset");
		print("Saved ROI");

		// go through results table and 1) fix label field, 2) find the max mean

		brightestIB = 0; 
		brightestRow = 0;

		// note that internally the rows of the results table start at 0 
		// so the referenced row number in the loop
		// will be 1 less than the printed row number in the table
	
		for (r = 0; r < nResults; r++) {
			setResult("Label", r, channelName);
			sliceMean = getResult("Mean",r);
			// print("The mean for row",r+1,"is",sliceMean);
			if (sliceMean > brightestIB){
				brightestIB = sliceMean;
				brightestRow = r;
			}
		}
		updateResults();
		brightestZ = getResult("Slice",brightestRow);
		print("Peak for image ",channelName,"is z=",brightestZ,"at",brightestIB);
		
		// save all measurements for this cell
		saveAs("Results", outputDir + File.separator + channelName + ".csv");
	
		// the first time, add headers to collected results file 
		if (n==1) {
			if (File.exists(outputDir  + File.separator+ "IB_results.csv")==false) 
			{
				IBheaders = String.getResultsHeadings();
				IBheaders = replace(IBheaders, "\t",","); // replace tabs with commas
				IBheaders = IBheaders + ",Background";
				File.append(IBheaders,resultsFile);
				print("headings are ",IBheaders);
		    }
		}
	
		// add the row containing the brightest IB to a merged results file
		// only way to do this with a single row is to loop through columns 
		// include the background used
		
		headings = split(String.getResultsHeadings);
		resultLine = ",";
		for (col=0; col<lengthOf(headings); col++){
		    resultLine = resultLine + getResultString(headings[col],brightestRow) + ",";
		}
		resultLine = resultLine + channelBackground;
		File.append(resultLine,resultsFile);
	} // end writing particle ROIs and brightest result
	
	run("Select None");
}

function resultsForNoParticles() {
	// write a line to IB results if there are no particles
	print("Writing background value to IB results file."); 
		
	// if this is the first time, add headers to collected results file 
	if (n==1) {
		if (File.exists(outputDir  + File.separator+ "IB_results.csv")==false) 
		{
			IBheaders = ",Label,Area,Mean,Min,Max,X,Y,IntDen,RawIntDen,Slice"; // need to change this if we do different measurements!
			// IBheaders = replace(IBheaders, "\t",","); // replace tabs with commas
			IBheaders = IBheaders + ",Background";
			File.append(IBheaders,resultsFile);
			print("since we have no results, headings are ",IBheaders);
	    }
	}

	// add a row to the merged results file giving the label and background value
	headings = split(String.getResultsHeadings);
	resultLine = ","+channelName+",,,,,,,,,,"; // 10 commas
	resultLine = resultLine + channelBackground;
	File.append(resultLine,resultsFile);
}
