//@ int(label="Channel for numerator", style = "spinner") Channel_Num
//@ int(label="Channel for denominator", style = "spinner") Channel_Denom
//@ int(label="Channel for transmitted light -- select 0 if none", style = "spinner") Channel_Trans

// biosensor.ijm
// ImageJ macro to generate a ratio image from a multichannel Z stack with interactive background selection 
// Features are thresholded and 
// Output is a 32-bit ratio image which can be saved or measured
// Theresa Swayne, Columbia University, 2022-2023

// TO USE: Open a multi-channel Z stack image. Run the macro. 
// Save the resulting 32-bit image.

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
waitForUser("Mark background", "Draw a background area that works for both channels, then click OK");
run("Set Measurements...", "mean redirect=None decimal=2");

// measure and subtract background in numerator channel
selectWindow(numImage);
run("Measure Stack...");
numBGs = Results.getColumn("Mean");
Array.getStatistics(numBGs, min, max, mean, stdDev);
numMeasBackground = mean;
print("Numerator channel",Channel_Num, "background = ",numMeasBackground);
//numMeasBackground = getResult("Mean",nResults-1); // from the last row of the table
selectWindow(numImage);
run("Select None");
run("Subtract...", "value="+numMeasBackground);

// measure and subtract background in denominator channel
run("Clear Results");
selectWindow(denomImage);
run("Restore Selection"); // TODO: save this in the ROI manager
run("Measure Stack...");
denomBGs = Results.getColumn("Mean");
Array.getStatistics(denomBGs, min, max, mean, stdDev);
denomMeasBackground = mean;
print("Denominator channel",Channel_Denom, "background = ",denomMeasBackground);
selectWindow(denomImage);
run("Select None");
run("Subtract...", "value="+denomMeasBackground);

// TODO: save background results

// ---- Threshold on the sum of the 2 images ----
imageCalculator("Add create 32-bit stack", numImage,denomImage);
selectWindow("Result of "+numImage);
rename("Sum");
setAutoThreshold("MaxEntropy dark stack");
setOption("BlackBackground", false);
run("Convert to Mask", "method=MaxEntropy background=Dark black");

// divide the 8-bit mask to generate a 0,1 mask
selectWindow("Sum");
run("Divide...", "value=255 stack");
rename("Mask"); // TODO: save mask

// apply the mask to each channel
imageCalculator("Multiply create 32-bit stack", numImage, "Mask");
selectWindow("Result of "+numImage);
rename("Masked Num");

imageCalculator("Multiply create 32-bit stack", denomImage, "Mask");
selectWindow("Result of "+denomImage);
rename("Masked Denom");

// ---- Calculate the ratio image ----

saveAs("Tiff", "/Users/tcs6/Downloads/test analysis/masked C1.tif");
imageCalculator("Multiply create 32-bit stack", "C2-stack","mask");
selectWindow("Result of C2-stack");
saveAs("Tiff", "/Users/tcs6/Downloads/test analysis/masked C2-stack.tif");
setThreshold(-808080.0000, 1.0000);
setThreshold(1.0000, 1000000000000000000000000000000.0000);
run("NaN Background", "stack");
run("Save");
selectWindow("masked C1.tif");
setThreshold(-808080.0000, 1.0000);
setThreshold(1.0000, 1000000000000000000000000000000.0000);
run("NaN Background", "stack");
run("Save");
selectWindow("C3-stack");
//setTool("polygon");
makePolygon(526,175,546,236,618,246,636,227,637,179,571,159);
Roi.setPosition(10);
roiManager("Add");
makePolygon(337,174,303,196,279,215,254,253,285,270,317,270,356,216);
Roi.setPosition(10);
roiManager("Add");
makePolygon(252,188,267,221,298,202,312,192,338,176,304,149,252,158);
Roi.setPosition(10);
roiManager("Add");
makePolygon(224,289,147,284,138,341,164,363,251,355,242,301);
Roi.setPosition(10);
roiManager("Add");
roiManager("Show All");

open("/Users/tcs6/Downloads/test analysis/masked C1-stack.tif");
selectWindow("masked C1-stack.tif");
close();
open("/Users/tcs6/Downloads/test analysis/masked C2-stack.tif");
selectWindow("masked C2-stack.tif");
open("/Users/tcs6/Downloads/test analysis/masked C1.tif");
selectWindow("masked C1.tif");
selectWindow("masked C2-stack.tif");
imageCalculator("Divide create 32-bit stack", "masked C2-stack.tif","masked C1.tif");
selectWindow("Result of masked C2-stack.tif");
saveAs("Tiff", "/Users/tcs6/Downloads/test analysis/C2 over C1.tif");
roiManager("Show None");
roiManager("Show All");
roiManager("Multi Measure");
saveAs("Results", "/Users/tcs6/Downloads/test analysis/ratio Results.csv");
//run("Brightness/Contrast...");
run("Enhance Contrast", "saturated=0.35");
close();
close();
selectWindow("masked C1.tif");
close();

selectWindow("C1-stack");
selectWindow("masked C1.tif");
roiManager("Show None");
roiManager("Show All");
roiManager("Deselect");
roiManager("Save", "/Users/tcs6/Downloads/test analysis/RoiSet.zip");
roiManager("Multi Measure");
selectWindow("Results");
saveAs("Results", "/Users/tcs6/Downloads/test analysis/C1 Results.csv");


selectWindow("masked C2-stack.tif");
roiManager("Show None");
roiManager("Show All");
roiManager("Multi Measure");
run("Set Measurements...", "area mean integrated display redirect=None decimal=2");
selectWindow("masked C1.tif");
roiManager("Multi Measure");
saveAs("Results", "/Users/tcs6/Downloads/test analysis/C1 Results.csv");
selectWindow("masked C2-stack.tif");
roiManager("Multi Measure");
saveAs("Results", "/Users/tcs6/Downloads/test analysis/C2 Results.csv");
close();
selectWindow("C3-stack");
close();
selectWindow("mask");
close();
close();
selectWindow("C2-stack");
close();
selectWindow("C1-stack");
close();
run("Close");
