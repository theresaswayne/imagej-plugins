// @Byte(label = "Condensate channel", style = "spinner", value = 1) fluoChannel
// @Byte(label = "Threshold value", value = 100) fixedThreshold
// @File(label = "Output folder:", style = "directory") outputDir


// Analyze_Small_Condensates.ijm
// ImageJ macro language script by Theresa Swayne, Columbia University, 2023
// Measures condensates in cell images
// Input: Fluorescence image, single plane
// Output: //Individual particle results 
//Cell ROIs 
//thresholded image 
//Summary counts 
// TO USE: Open an image. Run the script.


// --- Setup ----
print("\\Clear"); // clears Log window
roiManager("reset");
run("Clear Results");


// ---- Get image information ----
id = getImageID();
title = getTitle();
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);
getDimensions(width, height, channels, slices, frames);
print("Processing",title, "with basename",basename);
// save data as csv, preserve headers for saving, preserve row number for copy/paste 
run("Input/Output...", "file=.csv copy_row save_column save_row"); 
resultsFile = outputDir  + File.separator + basename + "_Summary.csv";

// ---- Get cell ROIs ----

selectWindow(title);
setTool("freehand");
waitForUser("Mark cells", "Draw ROIs and add to the ROI manager (press T after each),\nor open an ROI set.\nThen click OK");

// rename ROIs for easier interpretation of results

n = roiManager("count");
if (n == 0) {
	print("Analyzing entire image");
	run("Select All");
	roiManager("Add");
	roiManager("Select", 0);
    roiManager("Rename", "ROI_1");
	}
else if (n >= 1) {
	// rename with cell number
	for (i = 0; i < n; i++) {
		roiNum = i+1;
		roiManager("Select", i);
		newName = "Cell_"+roiNum;
    	roiManager("Rename", newName);
		}
	}
roiManager("deselect");  

// ---- Prepare images ----

run("Split Channels"); // TODO: check single channel behavior
targetImage = "C"+fluoChannel+"-"+title;
targetMask = basename+"_mask";

// ---- Apply threshold and clean up stray pixels ----

// make initial mask
selectWindow(targetImage);
run("Duplicate...", "title=&targetMask duplicate");
selectWindow(targetMask);
setThreshold(fixedThreshold, 4095); // supplied by user at the beginning
print("Threshold: ",fixedThreshold);
setOption("BlackBackground", false);
run("Convert to Mask", "background=Dark black");

// remove stray pixels
run("Options...", "iterations=1 count=1 black edm=16-bit do=Open");

// ---- Loop through ROIs and analyze particles ----

//For each ROI (cell) in manager, Analyze Particles on the binary image, 
// redirecting measurements, with min. size = 3 pixels, [borrow code from inclusion analysis],  
// do not append results but write lines to summary file 

n = roiManager("count");
for (i = 0; i < n; i++) {
	roiNum = i+1;
	
	// check if there are any pixels to measure
	selectWindow(targetMask);
	roiManager("Select", i);
	getStatistics(area, mean, min, max, stdDev, histogram);
	print("The max value in the ROI is",max);
	
	if (max==0){ // no pixels above threshold, therefore don't measure particles
		resultsForNoParticles();
		}
	else { 
		// find particles, and measure intensity of each in the original image
		measureParticles(basename, targetImage, targetMask, roiNum, outputDir);
		}
	
	// clean up results
	
	run("Clear Results");

	
	}





// find particles, and measure intensity of each in the original image



//Set measurements: Area, Mean, IntDen, Centroid, Display Label, redirect to original image  
run("Set Measurements...", "area mean integrated centroid display redirect=&title decimal=2");


//
//Save for each cell: 
//Individual particle results 
//
//Save for entire image:  
//Cell ROIs 
//thresholded image 
//Summary counts 



function measureParticles(original, target, mask, cellNum, output) {
	// carry out particle analysis and write results
	print("Measuring particles.");
	run("Set Measurements...", "area mean integrated centroid display redirect=&target decimal=2");
	selectWindow(mask);
	run("Analyze Particles...", "display clear exclude summarize");

	if (nResults == 0){ // for the case when there are positive pixels but no particles -- presumably on the edges.
		resultsForNoParticles();
	}
	else { // we have particles and results

		// note that internally the rows of the results table start at 0 
		// so the referenced row number in the loop
		// will be 1 less than the printed row number in the table
		
		// update the results with the name of the original image
		for (r = 0; r < nResults; r++) {
			setResult("Label", r, original); 
			}
		updateResults();
				
		// save individual particle measurements for this cell
		saveAs("Results", output + File.separator + original + "_" + cellNum + ".csv");
	
		// save collected results (counts)
		
		// the first time, add headers to collected results file 
		results = output  + File.separator + original + "_Summary.csv";
		 
		if (cellNum==1) {
			if (File.exists(results)==false) {
				SummaryHeaders = String.getResultsHeadings();
				SummaryHeaders = replace(SummaryHeaders, "\t",","); // replace tabs with commas
				File.append(SummaryHeaders,results);
				print("added headings: ",SummaryHeaders);
		    	}
		}
	
		// Get summary info
		
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
