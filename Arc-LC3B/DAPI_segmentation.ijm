// DAPI_segmentation.ijm
// ImageJ macro to identify DAPI nuclei in somewhat faint/noisy images at high magnification
// Theresa Swayne, Ph.D, Columbia University, tcs6 at cumc.columbia.edu
// Designed as part of an analysis of cytoplasmic neuronal markers

// Input: single 3- channel image with DAPI as the 1st channel
// Output: split channels, ROI set containing nuclei
// Usage: Open an image. Run the macro.
 
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
CELLMIN = 20 // minimum area
CELLMAX = 60 // maximum area

// SETUP -----------------------------------------------------------------------

// Sample image for testing
open("/Users/confocal/Google\ Drive/Confocal\ Facility/User\ projects/Alberini\ brain\ image\ analysis/Kiran\ folder/Kiran\ tiffs\ second\ group/Arc+LC3B\ -\ new\ -\ Set\ 1\ -\ Copy_Series049_MIP_7.tif")' 

// get file info
path = getDirectory("image");
// id = getImageID();
title = getTitle();
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);
procName = "processed_" + basename + ".tif";
resultName = "results_" + basename + ".csv";
roiName = "RoiSet_" + basename + ".zip";

// split and save channels
print("splitting",basename);
run("Split Channels");
while (nImages > 0)  // works on any number of channels
	{
	saveAs ("tiff", path+getTitle());	// save every picture in the *input* folder
	close();
	}

// re-open the DAPI channel, assuming it's channel 1

open(path+"C1-"+title);
id = getImageID();

// process a copy of the image

selectImage(id);
// square brackets allow handing of filenames containing spaces
run("Duplicate...", "title=" + "[" +procName+ "] duplicate"); 
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
run("Options...", "iterations=" + OPENITER + " count=" + OPENCOUNT + " black"); // smooth borders
run("Open");
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
