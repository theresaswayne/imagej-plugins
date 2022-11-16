// @File(label = "Input folder:", style = "directory") inputDir
// @String(label = "File suffix", value = ".tif") suffix
// @Integer(label = "Mito channel", value = 1) fluoChannel
// @Float(label = "Threshold multiplier", style="slider", min=0.5, max=3.0, stepSize=0.1, value = 1.5) threshMultiplier
// @File(label = "Output folder:", style = "directory") outputDir

// Note: DO NOT DELETE OR MOVE THE FIRST FEW LINES -- they supply essential parameters.

// mito_mp.ijm
// ImageJ/Fiji macro
// Theresa Swayne, tcs6@cumc.columbia.edu, 2022
// Measures integrated density of pixels exceeding a defined threshold in projected fluorescence z-series.
// User must select cell area and select an area for cytoplasmic background at each timepoint.
//
// Input: A folder of single- or multi-channel, zt series. Each image can include multiple cells.
// Output: ROIs as ZIP file, Results table containing background measurement and integrated density of all pixels exceeding a defined factor above background.
// Usage: Run the macro. (Image should not be open before running)

// setup -- clear results and set background to black
run("Clear Results");
setBackgroundColor(0, 0, 0);


// set up parameters for saving data from whole folder:
// csv format, preserve headers for saving, preserve row number for copy/paste
// set file name based on input folder

run("Input/Output...", "file=.csv copy_row save_column save_row");
inputName = File.getName(inputDir);
resultsFile = outputDir  + File.separator + inputName + "_Mito_results.csv";

// run the functions
n = 0; // image counter
processFolder(inputDir); // this actually executes the functions

// clean up
run("Set Measurements...", "area mean min integrated display redirect=None decimal=3");
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
	//print(width, height, channels, slices, frames);
	
	// make a copy of the channel of interest
	
	selectImage(title); // original possibly multi-channel image
	run("Select None"); // get rid of the ROI temporarily, or else image will be cropped
	
	// duplicate the mito channel
	fluoChannelName = basename+"_C"+fluoChannel;
	//print("The channel name will be",fluoChannelName);
	run("Duplicate...", "title=&fluoChannelName duplicate channels="+fluoChannel);

	// close the original image
	selectWindow(title);
	close();
	
	// max project if a z stack
	selectWindow(fluoChannelName);
	if (slices > 1) {
		if (frames > 1) {
			run("Z Project...", "projection=[Max Intensity] all");
		}
		else {
			run("Z Project...", "projection=[Max Intensity]");
		}
		selectWindow(fluoChannelName); // close the Z stack
		close();
	
		// restore the image name of the max projection
		selectWindow("MAX_"+fluoChannelName);
		rename(fluoChannelName);
	}
	
	// loop through timepoints

	for (t = 1; t <= frames; t++) {

		// select cell, get background, do global threshold and measure IntDen  
		// append to results

		measureMito(fluoChannelName, t, threshMultiplier); // the threshold multiplier is given by the user when the script is run
	
		} // time loop
	
	// clean up
	run("Close All");

	} // processImage
	
// function to measure the IntDen of pixels exceeding a threshold in a time frame and save results
function measureMito(imageName, time, multiplier) {
	
	print("Measuring mitochondria in image",imageName,"frame",time);

	// duplicate a single timepoint
	selectWindow(imageName);
	
	Stack.setPosition(1, 1, time); // only channel (the duplicate), only z, time frame of interest 
	frameName = imageName+"_t"+time;
	run("Duplicate...", "title=&frameName duplicate frames="+time); // get a single-frame image
			
	selectWindow(frameName);
	
	// user crops out cell 
	getLocationAndSize(x, y, winWidth, winHeight); // find current location of window
	zoomPct = 300; // set this as desired
	run("Set... ", "zoom=&zoomPct"); // zoom up for easier viewing -- center is center of image
	setLocation(x, y, width*zoomPct/100, height*zoomPct/100); // expand window
	setTool("polygon"); // allows for cutting out nearby cells
	waitForUser("Crop cell for image "+n+", frame "+time, "Outline the cell in this frame, then click OK");
	selType = selectionType();
	if (selType == -1) { // no selection
		waitForUser("Crop cell for image "+n+", frame "+time, "Draw a box around the cell in this frame, then click OK");		
	}

	run("Clear Outside", "stack"); // allows for cutting out nearby cells
	run("Crop"); // to bounding box of polygon. frameName window retains the same name
	run("Select None"); // to get rid of polygon

	// user marks background
	run("Set... ", "zoom=&zoomPct"); // zoom up for easier viewing -- center is center of image
	setLocation(x, y, width*zoomPct/100, height*zoomPct/100); // expand window
	setTool("freehand");
	waitForUser("Mark background for image "+n+", frame "+time , "Draw a cytoplasmic background area, then click OK");

	// measure background
	run("Set Measurements...", "area mean integrated limit display redirect=&frameName decimal=3");
	setThreshold(0, 65535); 
	run("Measure");
	channelBackground = getResult("Mean",nResults-1); // from the last row of the table
	print("Background in image",frameName,"=",channelBackground);
	run("Clear Results");

	// set threshold and measure mito
	run("Set Measurements...", "area mean integrated limit display redirect=&frameName decimal=3");
	selectWindow(frameName);
	run("Select None");
	thresh = multiplier * channelBackground; // 150% of the background if multiplier = 1.5
	//print("Global threshold for image",frameName,"=",thresh);
	setThreshold(thresh, 65535); 
	run("Measure");
	
// add time and background to results
	selectWindow("Results");
	resultsRows = Table.size; // number of rows
	lastRow = resultsRows - 1;
	setResult("Time", lastRow, time);
	updateResults();
	setResult("Background",lastRow, channelBackground);
	updateResults();
	
	// save results
	// TODO: avoid this awful kludge of one line at a time
	//resultsName = frameName + "_results.csv";
	//saveAs("Results", outputDir + File.separator+resultsName);
	
	//appendResults(resultsFile);
	headings = split(Table.headings);
	
	// the first time, add headers to results file 
		if (File.exists(resultsFile)==false) 
		{
			MTheaders = String.getResultsHeadings();
			//print("original results file headers are",MTheaders);
			MTheaders = replace(MTheaders, "\t",","); // replace tabs with commas
			File.append(MTheaders,resultsFile);
			//print("headings are ",MTheaders);
		} // write headings
	
	for (i=0; i<resultsRows; i++){
		resultLine = "";
		for (col = 0; col<lengthOf(headings); col++){
			//print("getting result from row",i,"column",headings[col]);
			colName = headings[col];
			data = Table.getString(colName, i);
			resultLine = resultLine + "," + data;
			} // column loop
	//print("The result line from row",i,"is", resultLine);
	print("The Mean of row",i,"is",Table.getString("Mean", i));
	print("The IntDen of row",i,"is",Table.getString("IntDen", i));

	File.append(resultLine,resultsFile);
	}
	// clean up windows and results
	selectWindow(frameName);
	close();
	
} // measureMito

function appendResults(resultsFile) {
	// add results from one image to a CSV file
		// the first time, add headers to results file 
		if (n==1) {
			if (File.exists(resultsFile)==false) 
			{
				MTheaders = String.getResultsHeadings();
				print("original results file headers are",MTheaders);
				MTheaders = replace(MTheaders, "\t",","); // replace tabs with commas
				File.append(MTheaders,resultsFile);
				print("headings are ",MTheaders);
		    }
		}
		
		// loop through rows
		
		headings = split(String.getResultsHeadings);
		
		for (i = 0; i < nResults; i++) {
			resultLine = ""; 
			for (col=0; col<lengthOf(headings); col++){
				print("getting result from column",headings[col],"row",i);
				resultLine = resultLine + "," + getResultString(headings[col],i);
			}
			print("The result line from row",i,"is", resultLine);
			File.append(resultLine,resultsFile);
		}
	} // end writing results

