// @File(label = "Input folder:", style = "directory") inputDir
// @String(label = "File suffix", value = ".tif") suffix
// @Byte(label = "Inclusion channel", style = "spinner", value = 1) fluoChannel
// @File(label = "Output folder:", style = "directory") outputDir

// Note: DO NOT DELETE OR MOVE THE FIRST FEW LINES -- they supply essential parameters.

// IB maturity.ijm
// ImageJ/Fiji macro
// Theresa Swayne, tcs6@cumc.columbia.edu, 2022
// Measures inclusion body parameters in fluorescence z-series images.
// User must select cell area and select area for cytoplasmic background at each timepoint.
//
// Input: A folder of single- or multi-channel, zt series. Each image can include multiple cells
// Output: ROIs as ZIP file, Results table containing background measurement and inclusion measurements for the brightest z plane.
// Usage: Run the macro. (Image should not be open before running)

// setup -- clear results and ROI Manager
run("Clear Results");
roiManager("reset");

// set up parameters for saving data from whole folder:
// csv format, preserve headers for saving, preserve row number for copy/paste
// set file name based on input folder

run("Input/Output...", "file=.csv copy_row save_column save_row");
inputName = File.getName(inputDir);
resultsFile = outputDir  + File.separator + inputName + "_IB_results.csv";

// run the functions
n = 0; // image counter
processFolder(inputDir); // this actually executes the functions

// clean up
run("Set Measurements...", "area mean min centroid integrated stack display redirect=None decimal=3");
print("Finished with",n,"images.");

// function to recursively process folders
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


// function to process each image
function processImage(dir1, sourceImage) 
	{
	open(dir1+File.separator+sourceImage);
	n++; // image counter
	print("Processing image",n, sourceImage); // first loop, n=1
	
	// get file info 
	id = getImageID();
	title = getTitle();
	dotIndex = indexOf(title, ".");
	basename = substring(title, 0, dotIndex);
	getDimensions(width, height, channels, slices, frames);
	
	// make a copy of the channel of interest
	
	selectImage(title); // original possibly multi-channel image
	run("Select None"); // get rid of the ROI temporarily, or else image will be cropped
	
	// duplicate the IB channel
	fluoChannelName = basename+"_C"+fluoChannel;
	run("Duplicate...", "title=&fluoChannelName duplicate channels="+fluoChannel);
	
	// close the original image
	selectWindow(title);
	close();

	// loop through timepoints

	for (t = 1; t <= frames; t++) {

		// select cell, get background, do global threshold and measure inclusion at slice with highest max intensity 
		// save individual and combined results and ROIs (for shape reference only -- as the parent image will be cropped

		measureInclusion(fluoChannelName, t, 1.5);
	
		} // time loop

	// clean up
	run("Close All");
	roiManager("reset");
	} // processImage
	

function measureInclusion(imageName, time, multiplier) {
	
	print("Measuring inclusion in image",imageName,"frame",time);

	// duplicate a single timepoint
	selectWindow(imageName);
	
	Stack.setPosition(1, 1, time); // only channel (the duplicate), 1st z, time frame of interest 
	frameName = imageName+"_t"+time;
	run("Duplicate...", "title=&frameName duplicate frames="+time); // get a single-frame z stack
			
	selectWindow(frameName);
	middleSlice = slices/2;
	Stack.setPosition(1, middleSlice, 1); // move to only channel, middle slice, only frame

	// user crops out cell 
	getLocationAndSize(x, y, winWidth, winHeight); // find current location of window
	zoomPct = 500; // set this as desired
	run("Set... ", "zoom=&zoomPct"); // zoom up for easier viewing -- center is center of image
	setLocation(x, y, width*zoomPct/100, height*zoomPct/100); // expand window
	setTool("rectangle");
	waitForUser("Crop cell for image "+n+", frame "+time, "Draw a box around the cell in this frame, then click OK");
	selType = selectionType();
	if (selType == -1) { // no selection
		waitForUser("Crop cell for image "+n+", frame "+time, "Draw a box around the cell in this frame, then click OK");		
	}

	run("Crop"); // frameName window retains the same name

	// user marks background
	run("Set... ", "zoom=&zoomPct"); // zoom up for easier viewing -- center is center of image
	setLocation(x, y, width*zoomPct/100, height*zoomPct/100); // expand window
	setTool("freehand");
	waitForUser("Mark background for image "+n+", frame "+time , "Draw a cytoplasmic background area, then click OK");

	// measure background
	run("Set Measurements...", "area mean min centroid integrated stack display redirect=None decimal=3");
	run("Measure");
	channelBackground = getResult("Mean",nResults-1); // from the last row of the table
	print("Background in image",frameName,"=",channelBackground);
	run("Select None"); 

	// make initial mask
	selectWindow(frameName);
	run("Duplicate...", "title=&channelMask duplicate");
	lowerThresh = multiplier * channelBackground;
	print("Global threshold for image",frameName,"=",lowerThresh);
	setThreshold(lowerThresh, 65535); // lower = 150% of the mean if multiplier = 1.5
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark black");
	rename("inclusion_mask");
	
	// run binary Open to remove stray pixels, set black background
	run("Options...", "iterations=1 count=1 black edm=16-bit do=Open stack");
	
	// find particles, measure each one in the original image, save the mask as an ROI
	
	selectWindow("inclusion_mask");

	// check if there are any pixels to measure
	Stack.getStatistics(voxelCount, mean, min, max, stdDev);
	print("The max value in the thresholded",frameName,"stack is",max);

	if (max==0){ // no pixels above threshold, therefore don't measure particles
		resultsForNoParticles(channelBackground, time);
	}
	else { 
		
		brightestMaxZ = measureParticles(frameName, time); // measure particles and return the Z plane with highest IB max intensity
		print("The measureParticles function returned Z=",brightestMaxZ,"for the brightest max intensity in image",frameName);
	}

	// clean up windows and results
	selectWindow("inclusion_mask");
	close();
	selectWindow(frameName);
	close();
	run("Clear Results");
	
} // measureInclusion


function measureParticles(frameName, frameTime) {
	// carry out particle analysis and write results
	// returns Z of highest max intensity (integer)
	print("Measuring particles in",frameName);
	run("Set Measurements...", "area mean min centroid integrated stack display redirect=["+frameName+"] decimal=3");
	
	selectWindow("inclusion_mask");
	run("Analyze Particles...", "size=0.01-Infinity display clear exclude add stack");

	//if (roiManager("count") == 0){ // for the case when there are positive pixels but no particles -- presumably on the edges.
	if (nResults == 0){
		resultsForNoParticles(channelBackground, frameTime);
	}
	else { // we have initial particles and results

		// go through results table and 1) fix label field, 2) find the max mean, 3) find the max area

		brightestIB = 0; 
		brightestRow = 0;
		largestIBArea = 0;
		largestIBRow = 0;
		brightestMax = 0;
		brightestMaxRow = 0;
		
		print("Updating results for image",frameName, "time",frameTime);

		// note that internally the rows of the results table start at 0 
		// so the referenced row number in the loop
		// will be 1 less than the printed row number in the table
	
		for (r = 0; r < nResults; r++) {
			setResult("Label", r, frameName);
			setResult("Time", r, frameTime); // add a column for time
			updateResults();
			sliceMean = getResult("Mean",r);
			// print("The mean for row",r+1,"is",sliceMean);
			if (sliceMean > brightestIB){
				brightestIB = sliceMean;
				brightestRow = r;
			}
			sliceArea = getResult("Area", r);
			// print("The area in row",r+1,"is",sliceArea);
			if (sliceArea > largestIBArea){
				largestIBArea = sliceArea;
				largestIBRow = r;
			}
			sliceMax = getResult("Max", r);
			// print("The max in row",r+1,"is",sliceMax);
			if (sliceMax > brightestMax){
				brightestMax = sliceMax;
				brightestMaxRow = r;
			}
		}
		//updateResults();
		brightestZ = getResult("Slice",brightestRow);
		print("Peak mean intensity for image ",frameName,"is z=",brightestZ,"at",brightestIB);
		largestZ = getResult("Slice",largestIBRow);
		print("Peak IB area for image ",frameName,"is z=",largestZ,"at",largestIBArea);
		brightestMaxZ = getResult("Slice",brightestMaxRow);
		print("Peak IB max for image ",frameName,"is z=",brightestMaxZ,"at",brightestMax);
		 
		// ----- Measure irregularity -----

		// use the original inclusion as a mask to remove the background 
		selectWindow(frameName);
		// Stack.setPosition(1,brightestZ,1);
		Stack.setPosition(1,brightestMaxZ,1);
		//sliceName = frameName + "_z"+brightestZ;
		sliceName = frameName + "_z"+brightestMaxZ;
		print("Masking out background in",sliceName);
		run("Duplicate...", "title=&sliceName");
		
		// clear all but the main IB area
		
		// selectWindow("inclusion_mask");
		// Stack.setPosition(1,brightestZ,1);
		selectWindow(sliceName);
		setThreshold(lowerThresh, 65535); // lower = 150% of the mean if multiplier = 1.5
		getLocationAndSize(x, y, winWidth, winHeight); // find current location of window
		zoomPct = 500; // set this as desired
		run("Set... ", "zoom=&zoomPct"); // zoom up for easier viewing -- center is center of image
		setLocation(x, y, width*zoomPct/100, height*zoomPct/100); // expand window
		setTool("wand");
		waitForUser("Select inclusion in image "+n+", frame "+time, "Click on the inclusion, then click OK");
		selType = selectionType();
		if (selType == -1) { // no selection
			waitForUser("Select inclusion in image "+n+", frame "+time, "Click on the inclusion, then click OK");		
		}

		//run("Keep Largest Region"); // requires MorpholibJ plugin (IJPB update site)
		//run("Create Selection");
		//selectWindow(sliceName);
		//run("Restore Selection");
		run("Clear Outside");
		run("Select None");
		
		// use a local threshold to reveal discontinuities in intensity
		//print("thresholding locally");
		run("Set Measurements...", "area mean min centroid integrated stack display decimal=3"); // do not redirect

		selectWindow(sliceName);
		setMinAndMax(0, 4095);
		setOption("ScaleConversions", true);
		run("8-bit"); // required for local threshold
		run("Auto Local Threshold", "method=Niblack radius=5 parameter_1=0 parameter_2=0 white");
		//run("Keep Largest Region"); // get rid of any smaller particles
		setAutoThreshold("Default dark");
		run("Analyze Particles...", "size=0.01-Infinity display exclude add");
		lastRow = nResults-1;
		localThreshArea = getResult("Area",lastRow); // last row -- note only 1 particle is supported
		setResult("Slice", lastRow, brightestMaxZ);
		updateResults();
		setResult("Time", lastRow, frameTime);
		updateResults();

		resetThreshold();
		selectWindow(sliceName);
		run("Select None");
		//print("filling holes");
		run("Fill Holes");
		//rename(sliceName+"_filled");
		setAutoThreshold("Default dark");
		run("Analyze Particles...", "size=0.01-Infinity display exclude add");
		lastRow = nResults-1;
		localThreshFilledArea = getResult("Area",lastRow); // last row -- note only 1 particle is supported
		setResult("Slice", lastRow, brightestMaxZ);
		updateResults();
		setResult("Time", lastRow, frameTime);
		updateResults();
		
		// save measurements for this cell
		// last 2 lines are the local thresholded area and filled area
		
		saveAs("Results", outputDir + File.separator + frameName + ".csv");

		// save particles
		roiManager("Save", outputDir + File.separator + frameName+".zip");
		roiManager("reset");
		//print("Saved ROIs");
	
		// add the row containing the brightest IB Max to a merged results file
		// only way to do this with a single row is to loop through columns 
		// include the background used

		// the first time, add headers to collected results file 
		if (n==1) {
			if (File.exists(outputDir  + File.separator + inputName + "_IB_results.csv")==false) 
			{
				IBheaders = String.getResultsHeadings();
				print("Results file headers are",IBheaders);
				IBheaders = replace(IBheaders, "\t",","); // replace tabs with commas
				IBheaders = IBheaders + ",Background,LocalThreshArea,LocalThreshFilledArea";
				File.append(IBheaders,resultsFile);
				//print("headings are ",IBheaders);
		    }
		}
		
		headings = split(String.getResultsHeadings);
		resultLine = ",";
		for (col=0; col<lengthOf(headings); col++){
		    resultLine = resultLine + getResultString(headings[col],brightestMaxRow) + ",";
		}
		resultLine = resultLine + channelBackground + "," + localThreshArea + "," + localThreshFilledArea;
		File.append(resultLine,resultsFile);
	} // end writing particle ROIs and brightest Max result
	
	run("Select None");
	return(brightestMaxZ);

} // end measureParticles

function resultsForNoParticles(channelBackground, time) {
	// write a line to IB results if there are no particles
	print("No particles found. Writing background and time values to IB results file."); 
		
	// if this is the first time, add headers to collected results file 
	if (n==1) {
		if (File.exists(outputDir  + File.separator+ inputName + "_IB_results.csv")==false) 
		{
			//IBheaders = ",Label,Area,Mean,Min,Max,X,Y,IntDen,RawIntDen,Slice,MinThr,MaxThr,Time"; // need to change this if we do different measurements!
			IBheaders = ",Label,Area,Mean,Min,Max,X,Y,IntDen,RawIntDen,Slice,Time";
			// IBheaders = replace(IBheaders, "\t",","); // replace tabs with commas
			IBheaders = IBheaders + ",Background,LocalThreshArea,LocalThreshFilledArea";
			File.append(IBheaders,resultsFile);
			print("No particles found. Writing headings to IB results file.");
	    }
	}
	
	// add a row to the merged results file giving the label and background value
	headings = split(String.getResultsHeadings);
	resultLine = ","+frameName+",,,,,,,,,,"; // 10 commas
	resultLine = resultLine + time + "," + channelBackground+",,";
	File.append(resultLine,resultsFile);
} // function resultsForNoParticles
