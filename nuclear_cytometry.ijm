// @File(label = "Input directory", style = "directory") dir1
// @File(label = "Output directory", style = "directory") dir2
// @String(label = "File suffix", value = ".tif") suffix
// @Integer(label = "Channel for detecting nuclei", value = 1) nucChan
// @Integer(label = "Typical nuclear area, µm", value = 30) nucArea

// Note: DO NOT DELETE OR MOVE THE FIRST FEW LINES -- they supply essential parameters
// nuclear_cytometry.ijm
// IJ macro to analyze nuclei as for Toledo 2013, Cell
// Theresa Swayne, Columbia University, 2018, for Demis Menolfi
// Based on IJ batch processing template and cfos macro from 2017
// This macro processes all the images in a folder. 
// input: a folder of multi-channel single-z TIFFs 
// procedure: 
//		Measures and subtracts background, 
//		detects nucle, 
//		collects mean and ntegrated ntensty for all channels usng a mask based on the detected nucle
//		wrtes a CSV fle of results for the batch 
// output: 
//		1 ROIset per image, 
//		1 csv file per batch containing measurements of all images

// Verson 1: To smplfy by borrowng eavly from prevous macro -- duplcate DAP channels then create mask and ROs.
// Save RO.
// iterate through 3 channels: Select ROs and measure, loadng results nto an Array
// Assemble results assgnng each ro an D
// TODO:
// Make flexble # channels
// Add flename and or tmestamp to output fle usng crop macro code

// ADJUSTABLE PARAMETERS -------------------------

// The following neighborhood values should be larger than the largest nucleus in the image, in pixels
BACKGROUNDSIZE = 50 // used in background subtraction.
BLOCKSIZE = 50 // used in contrast enhancement
RADIUS = 40 // used in local thresholding

// The following values affect how the nuclear boundaries are adjusted after thresholding
OPENITER = 3 // higher value = more smoothing
OPENCOUNT = 3 // lower value = more smoothing
ROIADJUST = -0.5; // adjustment of nuclear boundary, in microns. Negative value shrinks the cell.

// The following values govern allowable nuclei sizes in microns^2 TODO: Set based on nuclear value
CELLMIN = 50 // minimum area
CELLMAX = 300 // maximum area

// SETUP -----------------------------------------------------------------------

run("Input/Output...", "file=.csv copy_row save_column save_row"); // saves data as csv, preserves headers, preserves row number for copy/paste 
run("Set Measurements...", "area mean min centroid integrated stack display redirect=none decimal=2"); // mn temporarly for verfyng we measure the channel not bnary
run("Clear Results");
roiManager("reset");

setBatchMode(true);
n = 0;

// add headers to results file
headers = ",Flename,NucleusD,NucMean,NucTotal,C2Mean,C2Total,C3Mean,C3Total";
File.append(headers,dir2  + File.separator+ "_results.csv"); // TODO: check f fle exsts

processFolder(dir1); // this actually executes the functions

function processFolder(dir1) // search folder for mages wth desrd suffx -- recursve 
	{
	list = getFileList(dir1);
	for (i=0; i<list.length; i++) 
   		{
        if(File.isDirectory(dir1 + File.separator + list[i]))
        	{
			processFolder("" + dir1 +File.separator+ list[i]);
			}
        else if (endsWith(list[i], suffix))
        	{	
        	processImage(dir1, list[i]);
        	}
    	}
	}


function processImage(dir1, name) 
	{
	// dentfy nuclei, save ROIs, measure channels
	open(dir1+File.separator+name);
	print("analyzing",n++, name);
	
	id = getImageID();
	title = getTitle();
	dotIndex = indexOf(title, ".");
	basename = substring(title, 0, dotIndex);
	resultName = "C1_results.csv"; // necessary?
	roiName = "RoiSet_" + basename + ".zip";
	
	// process a copy of the image
	selectImage(id);
	// square brackets allow handing of filenames containing spaces
	run("Duplicate...", "title=nuclei duplicate channels=&nucChan"); // duplcates the nuclear channel only
	selectWindow("nuclei");
	
	// PRE-PROCESSING -----------------------------------------------------------
	
	run("Subtract Background...", "rolling="+BACKGROUNDSIZE); // TODO: Set to a multple of the nuclear sze converted to pxels
	run("Median...", "radius=3");
	// run("Gaussian Blur...", "sigma=1");

	// run("Enhance Local Contrast (CLAHE)", "blocksize=" + BLOCKSIZE + " histogram=256 maximum=3 mask=*None*"); 
	
	// SEGMENTATION AND MASK PROCESSING -------------------------------------------
	
	selectWindow("nuclei");
	run("Auto Local Threshold", "method=Phansalkar radius=" + RADIUS + " parameter_1=0 parameter_2=0 white");
	run("Convert to Mask");
	
	selectWindow("nuclei");
	run("Options...", "iterations=" + OPENITER + " count=" + OPENCOUNT + " black"); // smooth borders
	run("Open");
	run("Watershed"); // separate touching nuclei
	
	// analyze particles to get initial ROIs
	
	roiManager("reset");
	run("Analyze Particles...", "size=" + CELLMIN + "-" + CELLMAX + " exclude add");
	
	// adjust ROIs to match nuclei
	
	numROIs = roiManager("count");
	roiManager("Show None");
	for (index = 0; index < numROIs; index++) 
		{
		roiManager("Select", index);
		run("Enlarge...", "enlarge=" + ROIADJUST); // necessary?
		roiManager("Update");
		}
	
	// COUNTING NUCLEI AND MEASURING INTENSITY  ---------------------------------------------
	
	selectImage(id); // measure intensity in the original image
	// TODO: loop through channels
	roiManager("Deselect");
	// roiManager("multi-measure measure_all append"); // measures individual nuclei and appends results -- but erases the whole-image measurement
	run("Select None");
	for(i=0; i<numROIs;i++) // measures each ROI in turn
		{ 
		roiManager("Select", i); 
		run("Measure");
		}	
	run("Select None");

	
	// SAVING DATA AND CLEANING UP  ------------------------------------------------------
	
	roiManager("Save", dir1 + File.separator + roiName); // will be needed for colocalization 
	roiManager("reset");
	
	String.copyResults; // TODO: reformat results by loopng through and gettng values nto an Array.concat(array1,array2)
	newResults = String.paste;
	newResults = substring(newResults,0,lengthOf(newResults)-1); // strip the final newline
	newResults = replace(newResults, "\t",","); // replace tabs with commas for csv
	File.append(newResults,dir2 + File.separator + resultName);
	
	run("Clear Results");
	
	selectWindow(procName);
	close();
	selectWindow(title);
	close();
	}




