// arc_Analysis.ijm
// IJ macro to analyze arc-labeled nuclei and fibers
// Theresa Swayne, Columbia University, 2017
// input: single-channel single-z image
// output: ROIs and measurements
// usage: open the image, run the macro

// ADJUSTABLE PARAMETERS -------------------------

// The following neighborhood values should be larger than the largest nucleus in the image, in pixels
BACKGROUNDSIZE = 50 // used in background subtraction.
BLOCKSIZE = 50 // used in contrast enhancement
RADIUS = 40 // used in local thresholding

// The following values affect how the nuclear boundaries are adjusted after thresholding
OPENITER = 2 // higher value = more smoothing
OPENCOUNT = 2 // lower value = more smoothing
ROIADJUST = -0.5; // adjustment of nuclear boundary, in microns. Negative value shrinks the cell.

// The following values govern allowable nuclei sizes in microns^2
CELLMIN = 50 // minimum area
CELLMAX = 300 // maximum area

// SETUP -----------------------------------------------------------------------

path = getDirectory("image");
id = getImageID();
title = getTitle();
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);
procName = "processed_" + basename + ".tif";
resultName = "results_" + basename + ".xls";
roiName = "RoiSet_" + basename + ".zip";

// process a copy of the image

selectImage(id);
// square brackets allow handing of filenames containing spaces
run("Duplicate...", "title=" + "[" +procName+ "]"); 
selectWindow(procName);

// PRE-PROCESSING -----------------------------------------------------------

run("Subtract Background...", "rolling="+BACKGROUNDSIZE);
run("Median...", "radius=3");
// run("Enhance Local Contrast (CLAHE)", "blocksize=" + BLOCKSIZE + " histogram=256 maximum=3 mask=*None*"); 

// SEGMENTATION AND MASK PROCESSING -------------------------------------------

selectWindow(procName);
run("Auto Local Threshold", "method=Phansalkar radius=" + RADIUS + " parameter_1=0 parameter_2=0 white");
run("Convert to Mask");

selectWindow(procName);
run("Options...", "iterations=" + OPENITER + " count=" + OPENCOUNT + " black do=Open"); // smooth borders
run("Watershed"); // separate touching nuclei

// analyze particles to get initial ROIs

roiManager("reset");
run("Analyze Particles...", "size=" + CELLMIN + "-" + CELLMAX + " exclude clear add");

// shrink ROIs to match nuclei

numROIs = roiManager("count");
roiManager("Show None");
for (index = 0; index < numROIs; index++) 
	{
	roiManager("Select", index);
	run("Enlarge...", "enlarge=" + ROIADJUST);
	roiManager("Update");
	}

// COUNTING NUCLEI AND MEASURING INTENSITY  ---------------------------------------------

run("Set Measurements...", "area mean min centroid display decimal=2");
selectImage(id);
roiManager("Deselect");
roiManager("multi-measure measure_all"); // measures individual nuclei
run("Select None");
run("Measure"); // measures whole image

// SAVING DATA AND CLEANING UP  ------------------------------------------------------

saveAs("Results", path + resultName);
roiManager("Save", path + roiName); // will be needed for colocalization 
selectWindow(procName);
close();
selectWindow(title);
close();
run("Clear Results");
roiManager("reset");
