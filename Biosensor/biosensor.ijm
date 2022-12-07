//@ int(label="Channel for numerator", style = "spinner") Channel_Num
//@ int(label="Channel for denominator", style = "spinner") Channel_Denom
//@ int(label="Channel for transmitted light -- select 0 if none", style = "spinner") Channel_Trans
//@ File(label = "Output folder:", style = "directory") outputDir

// biosensor.ijm
// ImageJ macro to generate a ratio image from a multichannel Z stack with interactive background selection
// Input:
// Output:
// Theresa Swayne, Columbia University, 2022-2023

// TO USE: Open a multi-channel Z stack image. Run the macro. 

// TODO: Allow user to set threshold type, column format for measurement
// TODO: adapt for single images

// --- Setup ----
//roiManager("reset");
run("Clear Results");

// ---- Get image information ----
id = getImageID();
title = getTitle();
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);
getDimensions(width, height, channels, slices, frames);

// ---- Subtract background from a user-specified ROI ----
run("Split Channels");
numImage = "C"+Channel_Num+"-"+title;
denomImage = "C"+Channel_Denom+"-"+title;
if (Channel_Trans != 0) {
	transImage = "C"+Channel_Trans+"-"+title;
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
numMeasBackground = mean;
print("Numerator channel",Channel_Num, "background = ",numMeasBackground);
selectWindow(numImage);
run("Select None");
run("Subtract...", "value="+numMeasBackground);

// measure and subtract background in denominator channel
run("Clear Results");
selectWindow(denomImage);
run("Restore Selection"); // TODO: save this in the ROI manager
run("Measure Stack...");
denomBGs = Table.getColumn("Mean");
Array.getStatistics(denomBGs, min, max, mean, stdDev);
denomMeasBackground = mean;
print("Denominator channel",Channel_Denom, "background = ",denomMeasBackground);
selectWindow(denomImage);
run("Select None");
run("Subtract...", "value="+denomMeasBackground);

// TODO: save background results, clear results

// TODO: Get ROIs for cells

// ---- Create a mask based on the sum of the 2 images ----
imageCalculator("Add create 32-bit stack", numImage,denomImage);
selectWindow("Result of "+numImage);
rename("Sum");
// TODO: save sum
setAutoThreshold("MaxEntropy dark stack");
setOption("BlackBackground", false);
run("Convert to Mask", "method=MaxEntropy background=Dark black");

// divide the 8-bit mask to generate a 0,1 mask
selectWindow("Sum");
run("Divide...", "value=255 stack");
rename("Mask"); 
// TODO: save mask

// apply the mask to each channel
imageCalculator("Multiply create 32-bit stack", numImage, "Mask");
selectWindow("Result of "+numImage);
rename("Masked Num");

imageCalculator("Multiply create 32-bit stack", denomImage, "Mask");
selectWindow("Result of "+denomImage);
rename("Masked Denom");

// ---- Calculate the ratio image ----
imageCalculator("Divide create 32-bit stack", "Masked Num","Masked Denom");
selectWindow("Result of Masked Num");
rename("Ratio");
// TODO: save ratio

// set background pixels to NaN
setThreshold(1.0000, 1000000000000000000000000000000.0000);
run("NaN Background", "stack");

// TODO: --- Measure the cells, save results and ROIs ---
// run("Set Measurements...", "area mean integrated display redirect=None decimal=2");
// roiManager("Multi Measure"); // options?
// selectWindow("Results");
// saveAs("Results", "/Users/tcs6/Downloads/test analysis/ratio Results.csv");
// run("Brightness/Contrast...");
// roiManager("deselect");
// roiManager("save", outputDir  + File.separator + title + "_ROIs.zip";);


