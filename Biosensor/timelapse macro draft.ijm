// setup
run("Set Measurements...", "area mean display redirect=None decimal=3");
run("Input/Output...", "jpeg=85 gif=-1 file=.csv copy_row save_column save_row");

// split channels
run("Split Channels");

// make background area
makeRectangle(76, 298, 78, 90);
roiManager("Add");

// measure background and save results
selectWindow("C1-JYY343 DTT 2x2-timelapse noZ0032.nd2");
roiManager("Select", 0);
roiManager("Multi Measure");
saveAs("Results", "/Users/theresaswayne/Desktop/Biosensor/2022-11-04 roGFP JYY134 HyPer7 JYY343/C1 bkgd JYY343 DTT 2x2-timelapse noZ0032.csv");
selectWindow("C2-JYY343 DTT 2x2-timelapse noZ0032.nd2");
roiManager("Select", 0);
roiManager("Multi Measure");
saveAs("Results", "/Users/theresaswayne/Desktop/Biosensor/2022-11-04 roGFP JYY134 HyPer7 JYY343/C2 bkgd JYY343 DTT 2x2-timelapse noZ0033.csv");

// subtract the average background
selectWindow("C1-JYY343 DTT 2x2-timelapse noZ0032.nd2");
run("Subtract...", "value=110 stack");
selectWindow("C2-JYY343 DTT 2x2-timelapse noZ0032.nd2");
run("Select None");
run("Subtract...", "value=110 stack");

// create sum image for thresholding
imageCalculator("Add create 32-bit stack", "C1-JYY343 DTT 2x2-timelapse noZ0032.nd2","C2-JYY343 DTT 2x2-timelapse noZ0032.nd2");
selectWindow("Result of C1-JYY343 DTT 2x2-timelapse noZ0032.nd2");

// threshold the sum image
setAutoThreshold("Default");
//run("Threshold...");
setAutoThreshold("MaxEntropy dark");
setOption("BlackBackground", true);
run("Convert to Mask", "method=MaxEntropy background=Dark calculate black list");

// save list of thresholds
saveAs("Text", "/Users/theresaswayne/Desktop/Biosensor/2022-11-04 bleaching analysis/thresholds JYY343 DTT 2x2-timelapse noZ0032.csv");

// convert mask to 0,1 and multiply it by each channel
run("Divide...", "value=255 stack");
imageCalculator("Multiply create 32-bit stack", "C1-JYY343 DTT 2x2-timelapse noZ0032.nd2","mask JYY343 DTT 2x2-timelapse noZ0032.tif");
imageCalculator("Multiply create 32-bit stack", "C2-JYY343 DTT 2x2-timelapse noZ0032.nd2","mask JYY343 DTT 2x2-timelapse noZ0032.tif");

// threshold the masked channels and save
setThreshold(1.0000, 1000000000000000000000000000000.0000);
run("NaN Background", "stack");
run("Save");
selectWindow("masked C1-JYY343 DTT 2x2-timelapse noZ0032.tif");
setThreshold(1.0000, 1000000000000000000000000000000.0000);
run("NaN Background", "stack");

// mark cells in ROI manager
selectWindow("C3-JYY343 DTT 2x2-timelapse noZ0032.nd2");
makePolygon(407,270,455,248,486,232,485,304,460,319,421,307);
Roi.setPosition(3);
roiManager("Add");
roiManager("Show All");

// measure cells, and save results and ROIs
selectWindow("masked C1-JYY343 DTT 2x2-timelapse noZ0032.tif");
roiManager("Deselect");
roiManager("Multi Measure");
saveAs("Results", "/Users/theresaswayne/Desktop/Biosensor/2022-11-04 bleaching analysis/C1 results.csv");

selectWindow("masked C2-JYY343 DTT 2x2-timelapse noZ0032.tif");
roiManager("Multi Measure");
selectWindow("Results");
saveAs("Results", "/Users/theresaswayne/Desktop/Biosensor/2022-11-04 bleaching analysis/C2 Results.csv");

roiManager("Deselect");
roiManager("Save", "/Users/theresaswayne/Desktop/Biosensor/2022-11-04 bleaching analysis/RoiSet.zip");
