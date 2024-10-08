// @File(label = "Input folder:", style = "directory") inputDir
// @String(label = "File suffix", value = ".tif") suffix
// @Byte(label = "Fluorescence channel", style = "spinner", value = 1) fluoChannel
// @File(label = "Output folder:", style = "directory") outputDir

// ib_open_test.ijm
// testing binary parameters for inclusion body detection
// Note: DO NOT DELETE OR MOVE THE FIRST FEW LINES -- they supply essential parameters.

// use a specific threshold
// do binary open with count of 1-8
// collect data on particle area and mean

// maybe vary threshold and repeat

// ultimately chart count vs area, count vs mean, for a given threshold
// perhaps thresh vs area and mean for each count to look for plateaus

// setup -- clear results and ROI Manager
run("Clear Results");
roiManager("reset");

// save data as csv, preserve headers for saving, preserve row number for copy/paste 
run("Input/Output...", "file=.csv copy_row save_column save_row"); 
resultsFile = outputDir  + File.separator+ "Open_results.csv";

BACKGROUND = 3000;

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
	
	// get image info 
	id = getImageID();
	title = getTitle();
	dotIndex = indexOf(title, ".");
	basename = substring(title, 0, dotIndex);
	getDimensions(width, height, channels, slices, frames);
	getVoxelSize(voxwidth, voxheight, depth, unit);

	// print("Processing channel",fluoChannel);
	channelName = basename+"_C"+fluoChannel;
	channelMask = channelName+"_m";
	
	// make a copy of the channel of interest and close original
	selectImage(title);
	run("Select None"); // get rid of the ROI temporarily, or else image will be cropped
	if (channels > 1) { // multi-channel
		run("Duplicate...", "title=&channelName duplicate channels="+fluoChannel);
		selectWindow(title);
		close();
		}
	else { // 1-channel image
		run("Duplicate...", "title=&channelName duplicate");
		selectWindow(title);
		close();
		}

	// Measure background and particles

// TODO: use a range of thresholds

	for (fr = 1; fr <= frames; fr ++) {

		run("Set Measurements...", "area mean min centroid integrated stack display redirect=None decimal=3");
		print("Processing frame",fr);
		Stack.setPosition(1, 1, fr) // go to the frame we want to analyze
		run("Reduce Dimensionality...", "channels slices keep"); // get a single-frame z stack
		frameName = channelName+"-1"; // this name is automatically set by IJ

		
		middleSlice = slices/2;
		
		selectWindow(frameName);
		setVoxelSize(voxwidth, voxheight, depth, unit); // restore the scale info to the single-frame image


		channelBackground = BACKGROUND; 
	
		// make initial mask
		selectWindow(frameName);
		run("Duplicate...", "title=&channelMask duplicate");
		
		// TODO: vary thresholds

		lowerThresh = 1.5 * channelBackground;
		print("Threshold = ",lowerThresh);
		setThreshold(lowerThresh, 65535); // lower = 150% of the mean cytoplasmic background
		// setOption("BlackBackground", false); // TODO: why was this here?
		run("Convert to Mask", "method=Default background=Dark black");
		rename("inclusion_mask");
		
		// remove stray pixels

		// TODO: try different COUNT values to preserve small inclusions

		run("Options...", "iterations=1 count=1 black edm=16-bit do=Open stack"); 

		// check if there are any pixels to measure
		selectWindow("inclusion_mask");
		Stack.getStatistics(voxelCount, mean, min, max, stdDev);
		print("The max value in mask is",max);
	
		if (max==0){ // no pixels above threshold, therefore don't measure particles
			resultsForNoParticles();
			}
		else { 
			measureParticles();
			}

		// clean up windows and results
		selectWindow("inclusion_mask");
		close();
		selectWindow(frameName);
		close();
		run("Clear Results");

		} // end of time frame loop 	

		selectWindow(channelName);
		close();

	} // end of image processing loop
	
// clean up
run("Set Measurements...", "area mean min centroid integrated stack display redirect=None decimal=3");
print("Finished with",n,"images.");

function measureParticles() {
	// carry out particle analysis and writing results
	print("Measuring particles.");
	run("Set Measurements...", "area mean min centroid integrated stack display redirect=["+frameName+"] decimal=3");
	run("Analyze Particles...", "display clear exclude add stack"); // TODO: try min filter for small noise particles

	if (roiManager("count") == 0){ // for the case when there are positive pixels but no particles -- presumably on the edges.
		resultsForNoParticles();
		}
	else { // we have particles and results

		// save particles
		roiManager("Save", outputDir + File.separator + channelName + "_t" + fr + ".zip");
		roiManager("reset");
		print("Saved particles for frame",fr);

		// go through results table and 1) fix label field, 2) find the max mean

		brightestIB = 0; 
		brightestRow = 0;

		// note that internally the rows of the results table start at 0 
		// so the referenced row number in the loop
		// will be 1 less than the printed row number in the table
	
		for (r = 0; r < nResults; r++) {
			setResult("Label", r, channelName);
			setResult("Frame", r, fr);
			sliceMean = getResult("Mean",r);
			// print("The mean for row",r+1,"is",sliceMean);
			if (sliceMean > brightestIB){
				brightestIB = sliceMean;
				brightestRow = r;
			}
		}
		updateResults();
		brightestZ = getResult("Slice",brightestRow);
		print("Peak for image ",channelName,"in frame",fr,"is z=",brightestZ,"at",brightestIB);
		
		// save all measurements for this cell in this frame
		saveAs("Results", outputDir + File.separator + channelName + "_t" + fr + ".csv");

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
	
		// add the row containing the brightest IB per frame to a merged results file
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
			IBheaders = ",Label,Area,Mean,Min,Max,X,Y,IntDen,RawIntDen,Slice,Frame"; // need to change this if we do different measurements!
			// IBheaders = replace(IBheaders, "\t",","); // replace tabs with commas
			IBheaders = IBheaders + ",Background";
			File.append(IBheaders,resultsFile);
			print("since we have no results, headings are ",IBheaders);
	    }
	}

	// add a row to the merged results file giving the label and background value
	headings = split(String.getResultsHeadings);
	resultLine = ","+channelName+",,,,,,,,,,"; // 10 commas
	resultLine = resultLine + fr + "," + channelBackground;
	File.append(resultLine,resultsFile);
}
