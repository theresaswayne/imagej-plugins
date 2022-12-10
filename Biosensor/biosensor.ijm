//@ int(label="Channel for numerator", style = "spinner") Channel_Num
//@ int(label="Channel for denominator", style = "spinner") Channel_Denom
//@ int(label="Channel for transmitted light -- select 0 if none", style = "spinner") Channel_Trans
//@ string(label="Background subtraction method", choices={"None", "Fixed values", "Measured from image area"}, style="listBox") Background_Method
//@ File(label = "Output folder:", style = "directory") outputDir

// biosensor.ijm
// ImageJ macro to generate a ratio image from a multichannel Z stack with interactive background selection
// Input: multi-channel Z stack image
// Output: mask and ratio images, results, ROI set, log of background levels
// Theresa Swayne, Columbia University, 2022-2023

// TO USE: Open a multi-channel Z stack image. Run the macro. 

// TODO MAYBE: 
//	user sets threshold type
// 	adapt for single plane images
//  more graceful way to set background to NaN

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
print("Processing",title);

// ---- Prepare images ----
run("Split Channels");
numImage = "C"+Channel_Num+"-"+title;
denomImage = "C"+Channel_Denom+"-"+title;
if (Channel_Trans != 0) {
	transImage = "C"+Channel_Trans+"-"+title;
	}

// ---- Background handling ---

if (Background_Method == "Measured from image area") {
	print("Subtracting user-selected background");
	measBG = measureBackground(Channel_Num, Channel_Denom, Channel_Trans);
	numBG = measBG[0];
	denomBG = measBG[1];
	print("Measured numerator channel "+Channel_Num+" background", numBG);
	print("Measured denominator channel "+Channel_Denom+" background", denomBG);
	}
else if (Background_Method == "Fixed values") {
	Dialog.create("Enter Fixed Background Values");
	Dialog.addNumber("Numerator channel "+Channel_Num+" background", 0);
	Dialog.addNumber("Denominator channel "+Channel_Denom+" background", 0);
	Dialog.show();
	numBG = Dialog.getNumber();
	denomBG = Dialog.getNumber();
	print("Entered numerator channel "+Channel_Num+" background", numBG);
	print("Entered denominator channel "+Channel_Denom+" background", denomBG);
	}
else {
	numBG = 0;
	denomBG = 0;
	print("No background was subtracted");
	}

selectWindow(numImage);
run("Select None");
run("Subtract...", "value="+numBG+" stack");

selectWindow(denomImage);
run("Select None");
run("Subtract...", "value="+denomBG+" stack");

// ---- Segmentation and ratioing ----

// threshold on the sum of the 2 images
imageCalculator("Add create 32-bit stack", numImage,denomImage);
selectWindow("Result of "+numImage);
rename("Sum");
setAutoThreshold("MaxEntropy dark stack"); // change the threshold method if needed
//setOption("BlackBackground", false);
run("Convert to Mask", "method=MaxEntropy background=Dark black"); // change the threshold method if needed

// divide the 8-bit mask by 255 to generate a 0,1 mask
selectWindow("Sum");
run("Divide...", "value=255 stack");
rename("Mask");

// apply the mask to each channel by multiplication
// (a 32-bit result is required so we can change the background to NaN later)
imageCalculator("Multiply create 32-bit stack", numImage, "Mask");
selectWindow("Result of "+numImage);
rename("Masked Num");

imageCalculator("Multiply create 32-bit stack", denomImage, "Mask");
selectWindow("Result of "+denomImage);
rename("Masked Denom");

// calculate the ratio image
imageCalculator("Divide create 32-bit stack", "Masked Num","Masked Denom");
selectWindow("Result of Masked Num");
rename("Ratio");

// set background pixels to NaN
selectWindow("Ratio");
setThreshold(1.0000, 1000000000000000000000000000000.0000); // this should ensure all mask pixels are selected 
run("NaN Background", "stack");

// ---- Select cells and measure ----

run("Set Measurements...", "area mean integrated display redirect=None decimal=2");
if (Channel_Trans != 0) {
	transImage = "C"+Channel_Trans+"-"+title;
	selectWindow(transImage);
	}
else {
	selectWindow(Sum);
	}
setTool("freehand");
middleSlice = round(slices/2);
Stack.setPosition(1,middleSlice,1);
waitForUser("Mark cells", "Draw ROIs and add to the ROI manager (press T after each).\nThen click OK");


selectWindow("Ratio");
rename(basename + "_ratio"); // so the results will have the original filename attached

roiManager("deselect");
roiManager("Multi Measure"); // user sees dialog to choose rows/columns for output


// ---- Save output files ----

selectWindow("Mask");
saveAs("Tiff", outputDir  + File.separator + basename + "_mask.tif");
selectWindow(basename + "_ratio");
saveAs("Tiff", outputDir  + File.separator + basename + "_ratio.tif");
roiManager("deselect");
roiManager("save", outputDir  + File.separator + basename + "_ROIs.zip");
selectWindow("Results");
saveAs("Results", outputDir  + File.separator + basename + "_Results.csv");
selectWindow("Log");
saveAs("text",outputDir  + File.separator + basename + "_Log.txt");

// ---- Clean up ----

close("*"); // image windows
selectWindow("Log");
run("Close");
roiManager("reset");
run("Clear Results");

// ---- Helper function ----

function measureBackground(Num, Denom, Trans) { 
	// Measures background from a user-specified ROI
	// Returns the mean stack background values (rounded to nearest integer) in numerator and denominator channels
	
	if (Trans != 0) {
		transImage = "C"+Trans+"-"+title;
		selectWindow(transImage);
	}
	else {
		selectWindow(numImage);
	}
	
	// get the ROI
	setTool("rectangle");
	waitForUser("Mark background", "Draw a background area, then click OK");
	run("Set Measurements...", "mean redirect=None decimal=2");
	
	// measure and subtract background in numerator channel
	selectWindow(numImage);
	run("Measure Stack...");
	numBGs = Table.getColumn("Mean");
	Array.getStatistics(numBGs, min, max, mean, stdDev);
	numMeasBackground = round(mean);
	//print("Numerator channel",Num, "background = ",numMeasBackground);

	
	// measure and subtract background in denominator channel
	run("Clear Results");
	selectWindow(denomImage);
	run("Restore Selection"); // TODO: save this in the ROI manager
	run("Measure Stack...");
	denomBGs = Table.getColumn("Mean");
	Array.getStatistics(denomBGs, min, max, mean, stdDev);
	denomMeasBackground = round(mean);
	//print("Denominator channel",Denom, "background = ",denomMeasBackground);


	backgrounds = newArray(numMeasBackground, denomMeasBackground);
	return backgrounds;
	}
// measureBackground function