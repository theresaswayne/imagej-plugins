// @Byte(label = "Condensate channel", style = "spinner", value = 1) fluoChannel
// @Byte(label = "Threshold value", value = 100) fixedThreshold
// @Byte(label = "Minimum particle size", value = 3) minSize
// @Byte(label = "Maximum particle size", value = 10000) maxSize
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

// TODO: For empty line, remove a comma before the label, add ROI number to the label

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
selectWindow(targetMask);
run("Options...", "iterations=1 count=1 black edm=16-bit do=Open");

// set measurement options
run("Set Measurements...", "area mean integrated centroid display redirect=&targetImage decimal=2");

// ---- Loop through ROIs and analyze particles ----

//For each ROI (cell) in manager, Analyze Particles on the binary image, 
// redirecting measurements to the original image

n = roiManager("count");
for (i = 0; i < n; i++) {
	roiNum = i+1;
	
	// check if there are any pixels to measure
	selectWindow(targetMask);
	roiManager("Select", i);
	getStatistics(area, mean, minimum, maximum, stdDev, histogram);
	print("The max value in the ROI is",maximum);
	
	if (maximum==0){ // no pixels above threshold, therefore don't measure particles
		resultsForNoParticles(basename, roiNum, outputDir);
		}
	else { 
		// find particles, and measure intensity of each in the original image
		measureParticles(basename, targetImage, targetMask, roiNum, minSize, maxSize, outputDir);
		}
	}

// ---- Save output files ----

selectWindow(targetMask);
saveAs("Tiff", outputDir  + File.separator + basename + "_mask.tif");
roiManager("deselect");
roiManager("save", outputDir  + File.separator + basename + "_ROIs.zip");
selectWindow("Log");
saveAs("text",outputDir  + File.separator + basename + "_Log.txt");

// ---- Clean up ----

close("*"); // image windows
selectWindow("Log");
run("Close");
//selectWindow("Summary");
//run("Close");
roiManager("reset");
run("Clear Results");

// ---- Functions ----

function measureParticles(original, target, mask, cellNum, min, max, output) {
	// carry out particle analysis and write results
	print("Measuring particles.");
	
	selectWindow(mask);
	run("Analyze Particles...", "size=&min-&max display clear exclude summarize");

	if (nResults == 0){ // for the case when there are positive pixels but no particles -- presumably on the edges.
		resultsForNoParticles(original, cellNum, output);
		}
	else { // we have particles and results

		// note that internally the rows of the results table start at 0 
		// so the referenced row number in the loop
		// will be 1 less than the printed row number in the table
		
		// update the results with the name of the original image
		for (r = 0; r < nResults; r++) {
			newLabel = original + "_" + cellNum;
			setResult("Label", r, newLabel); 
			}
		updateResults();

		// save individual particle measurements for this cell
		selectWindow("Results");
		saveAs("Results", output + File.separator + original + "_" + cellNum + ".csv");
	
		// save collected results (counts)
		
		summary = output  + File.separator + original + "_Summary.csv";
		 
		selectWindow("Summary");
		// gather info, tab separated
		lines = split(getInfo(), "\n"); 
		headings = lines[0]; // label count totalarea averagesize pctarea mean intden 
		values = split(lines[1], "\t"); // make an array from the values
		
		// replace the mask file name with the original file name
		origLabel = values[0];
		print("Original label",origLabel);
		newLabel = original + "_" + cellNum;
		values[0] = newLabel;
		print("Renamed to",newLabel);
		
		// construct the data line with values separated by commas
		summaryLine = String.join(values, ",");
		
		// begin the new comma-separated file if needed, then add the summary data
		if (File.exists(summary)==false) {
			SummaryHeaders = replace(headings, "\t",","); // replace tabs with commas
			File.append(SummaryHeaders,summary);
			print("added headings: ",SummaryHeaders);
	    	}
 		File.append(summaryLine,summary); // add one line of data
		print("added data");
		
		selectWindow("Summary");
		run("Close");
		} // end writing particle data
	
	run("Select None");
	}

function resultsForNoParticles(original, lineNum, output) {
	// write a line to summary results if there are no particles
	print("Writing zeroes to summary file."); 
	
	summary = output  + File.separator + original + "_Summary.csv";
	
	// if this is the first time, add headers to collected results file 
	if (File.exists(summary)==false) {
		SummaryHeaders = "Slice,Count,Total Area,Average Size,% Area,Mean,IntDen";
		File.append(SummaryHeaders,summary);
		print("added headings: ",SummaryHeaders);
		}
	summaryLine = original+"_"+lineNum+",,,,,"; // 5 commas
	File.append(summaryLine,summary);
	print("added line");
	}
