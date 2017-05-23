// @File(label = "Input directory", style = "directory") dir1
// @File(label = "Output directory", style = "directory") dir2
// @String(label = "File suffix", value = ".tif") suffix

// Note: DO NOT DELETE OR MOVE THE FIRST 3 LINES -- they supply essential parameters

// DAPI_segmentation.ijm
// ImageJ macro to identify DAPI nuclei in somewhat faint/noisy images at high magnification
// Theresa Swayne, Ph.D, Columbia University, tcs6 at cumc.columbia.edu
// Designed as part of an analysis of cytoplasmic neuronal markers

// Input: folder of single 3- channel images with nuclei as the 1st channel
// Output: split channels, ROI set containing nuclei
// Usage: Run the macro.
 
// ADJUSTABLE PARAMETERS -------------------------

// The following neighborhood values should be larger than the largest nucleus in the image, in pixels
//BACKGROUNDSIZE = 50 // used in background subtraction.
BLOCKSIZE = 127 // used in contrast enhancement
RADIUS = 40 // used in local thresholding

// The following values affect how the nuclear boundaries are adjusted after thresholding
//OPENITER = 2 // higher value = more smoothing
//OPENCOUNT = 2 // lower value = more smoothing

// The following values govern allowable nuclei sizes in microns^2
CELLMIN = 30 // minimum area
CELLMAX = 500 // maximum area

// SETUP -----------------------------------------------------------------------

setBatchMode(true);
n = 0;

splitChannelsFolder(dir1); // split each image into channels
processFolder(dir1); // this actually executes the functions

function splitChannelsFolder(dir1) 
	{
   list = getFileList(dir1);
   for (i=0; i<list.length; i++) 
   		{
        if(File.isDirectory(dir1 + File.separator + list[i])) {
			processFolder("" + dir1 +File.separator+ list[i]);}
        else if (endsWith(list[i], suffix)) {
           		splitChannelsImage(dir1, list[i]);}
    	}
	}


function processFolder(dir1) 
	{
   list = getFileList(dir1);
   for (i=0; i<list.length; i++) 
   		{
        if(File.isDirectory(dir1 + File.separator + list[i])){
			processFolder("" + dir1 +File.separator+ list[i]);}
        else if (endsWith(list[i], suffix))
        	{
        	if (startsWith(list[i], "C1")){
           		segmentNucleiImage(dir1, list[i]);} // gets the nuclei -- assumes filename begins with "C1"
           	else if (startsWith(list[i], "C2")){
           		processC2Image(dir1, list[i]);} // TODO: nuclei/cytoplasm analysis
        	}
    	}
	}

function splitChannelsImage(dir1, name) 
	{
	open(dir1+File.separator+name);
	print("splitting",n++, name);
	run("Split Channels");
	while (nImages > 0)  // works on any number of channels
		{
		saveAs ("tiff", dir1+File.separator+getTitle);	// save every picture in the *input* folder
		close();
		}
	}

function segmentNucleiImage(dir1, name) 
	{
	// assumes nuclei are in channel 1 of the previously split image, and the filename begins with "C1"
	open(dir1+File.separator+name);
	dotIndex = indexOf(name, ".");
	basename = substring(name, 3, dotIndex); // taking off the channel number
	procName = "processed_" + basename + ".tif";
	resultName = "results_" + basename + ".csv";
	roiName = "Nuclei_" + basename + ".zip";
	id = getImageID();
	
	// process a copy of the image
	selectImage(id);
	// square brackets allow handing of filenames containing spaces
	run("Duplicate...", "title=" + "[" +procName+ "] duplicate"); 
	selectWindow(procName);
	
	// PRE-PROCESSING -----------------------------------------------------------
	run("Enhance Local Contrast (CLAHE)", "blocksize=" + BLOCKSIZE + " histogram=256 maximum=3 mask=*None*"); // accentuates faint nuclei
	run("Gaussian Blur...", "sigma=8"); // merges speckles to make nucleus more cohesive
	
	// SEGMENTATION AND MASK PROCESSING -------------------------------------------
	selectWindow(procName);
	run("Auto Local Threshold", "method=Phansalkar radius=" + RADIUS + " parameter_1=0 parameter_2=0 white");
	run("Convert to Mask");
	
	selectWindow(procName);
	//run("Options...", "iterations=" + OPENITER + " count=" + OPENCOUNT + " black"); // smooth borders
	//run("Open");
	run("Watershed"); // separate touching nuclei
	
	// analyze particles to get initial ROIs
	
	roiManager("reset");
	run("Analyze Particles...", "size=" + CELLMIN + "-" + CELLMAX + " exclude clear add");
	roiManager("Save", dir2 + File.separator + roiName); // saved in the output folder
	}

function processC2Image(dir1, name)
	{
	// TODO
	print("here will be the results of the next phase");
	}
	
