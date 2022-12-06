//@ int(label="Channel for numerator", style = "spinner") Chan_Num
//@ int(label="Channel for denominator", style = "spinner") Chan_Denom


//

// Measures ratio image from a multichannel Z stack with interactive background selection 
// Output is a 32-bit image with the GP values
// GP Formula from Learmonth and Gratton, 2002, doi: 10.1007/978-3-642-56067-5_14
// GP = (Igel - Ilc)/(Igel + Ilc)
// GP is higher in less fluid membranes
// Theresa Swayne, Columbia University, 2022 for Erika Shor and Yasmine Hassoun

// TO USE: Open a multi-channel image. Run the macro. Save the resulting images -- both the GP image and the HSB.

// ---- Get image information ----
id = getImageID();
title = getTitle();
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);
getDimensions(width, height, channels, slices, frames);

// ---- Subtract background from a user-specified ROI ----

// get the ROI
setTool("freehand");
waitForUser("Mark background", "Draw a background area that works for both channels, then click OK");
run("Set Measurements...", "mean redirect=None decimal=3");

// measure background in Gel channel
Stack.setChannel(Chan_Gel);
run("Measure");
gelMeasBackground = getResult("Mean",nResults-1); // from the last row of the table

// measure background in LC channel
Stack.setChannel(Chan_LC);
run("Measure");
lcMeasBackground = getResult("Mean",nResults-1); // from the last row of the table

// subtract background from each channel

run("Split Channels");
open("/Users/tcs6/Downloads/2022-11-10 HyPer7 H2O2 titration/JYY343 no tr001.nd2");
selectWindow("JYY343 no tr001.nd2");
run("Duplicate...", "title=stack");
close();
selectWindow("JYY343 no tr001.nd2");
run("Duplicate...", "title=stack duplicate");
selectWindow("JYY343 no tr001.nd2");
close();
selectWindow("stack");
run("Split Channels");
makeRectangle(379, 266, 133, 125);
Roi.setPosition(1);
roiManager("Add");
selectWindow("C1-stack");
roiManager("Select", 0);
roiManager("Multi Measure");
run("Summarize");
saveAs("Results", "/Users/tcs6/Downloads/test analysis/C1 bg.csv");
selectWindow("C2-stack");
roiManager("Select", 0);
roiManager("Multi Measure");
run("Summarize");
saveAs("Results", "/Users/tcs6/Downloads/test analysis/C2 bg.csv");
selectWindow("C1-stack");
run("Select None");
run("Subtract...", "value=118 stack");
selectWindow("C2-stack");
run("Select None");
run("Subtract...", "value=116 stack");
imageCalculator("Add create 32-bit stack", "C1-stack","C2-stack");
selectWindow("Result of C1-stack");
close();
imageCalculator("Add create 32-bit stack", "C1-stack","C2-stack");
selectWindow("Result of C1-stack");
rename("sum");
setAutoThreshold("Default dark");
//run("Threshold...");
setAutoThreshold("Default dark stack");
setAutoThreshold("MaxEntropy dark stack");
setOption("BlackBackground", false);
run("Convert to Mask", "method=MaxEntropy background=Dark black");
run("Divide...", "value=255 stack");
run("Image Calculator...");
rename("mask");
imageCalculator("Multiply create 32-bit stack", "C1-stack","mask");
selectWindow("Result of C1-stack");
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
