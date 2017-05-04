// @File(label = "Input directory", style = "directory") dir1
// @File(label = "Output directory", style = "directory") dir2
// @String(label = "File suffix", value = ".tif") suffix

// Note: DO NOT DELETE OR MOVE THE FIRST 3 LINES -- they supply essential parameters
// batch_multichannel_cfosArc_Analysis.ijm
// IJ macro to analyze c-fos and Arc in nuclei, and Arc in whole image
// Theresa Swayne, Columbia University, 2017
// Based on IJ batch processing template
// This macro processes all the images in a folder and any subfolders. But note that the results all end up in a single directory.
// input: a folder of 2-channel single-z TIFFs with channel 1 = (arc) and channel 2= (cfos)
// the two channels are processed slightly differently and for channel 1, the whole image is measured in addition to the nuclei
// output: 2 component channels, 1 ROIset per channel image, one csv file per channel containing measurements of all images
// summarizes as it goes, adding the nuclei count, average size, intensity, etc. per image to a separate file 
// usage: run the macro, choose input and output folders -- these must be separate, not nested, and output must be empty -- and specify the file suffix.

// ADJUSTABLE PARAMETERS -------------------------

// The following neighborhood values should be larger than the largest nucleus in the image, in pixels
BACKGROUNDSIZE = 50 // used in background subtraction.
BLOCKSIZE = 50 // used in contrast enhancement
RADIUS = 40 // used in local thresholding

// The following values affect how the nuclear boundaries are adjusted after thresholding
OPENITER = 3 // higher value = more smoothing
OPENCOUNT = 3 // lower value = more smoothing
ROIADJUST = -0.5; // adjustment of nuclear boundary, in microns. Negative value shrinks the cell.

// The following values govern allowable nuclei sizes in microns^2
CELLMIN = 50 // minimum area
CELLMAX = 300 // maximum area

// SETUP -----------------------------------------------------------------------

run("Input/Output...", "file=.csv copy_row save_column save_row"); // saves data as csv, preserves headers, preserves row number for copy/paste 
run("Set Measurements...", "area mean min centroid integrated display decimal=2");
run("Clear Results");
roiManager("reset");

setBatchMode(true);
n = 0;

// add headers to results file
headers = ",Label,Area,Mean,Min,Max,X,Y,IntDen,RawIntDen";
File.append(headers,dir2  + File.separator+ "C1_results.csv");
File.append(headers,dir2  + File.separator+ "C2_results.csv");

// add headers to summary file
// desired output format
// 0 filename, 1-3 c1 whole image (mean, intden, rawintden), 
// 4 c1 nuclei count, average and sd of c1 (5-6 area, 7-8 mean, 9-10 intden, 11-12 rawintden), 
// 13 c2 nuclei count, average and sd of c2 (14-15 area, 16-17 mean, 18-19 intden, 20-21 rawintden)
sumheaders1 = "Label,C1Mean,C1IntDen,C1RawIntDen,";
sumheaders2= "C1NucleiCount,C1AreaAve,C1AreaStdDev,C1MeanAve,C1MeanStdDev,C1IntDenAve,C1IntDenStdDev,C1RawIntDenAve,C1RawIntDenStdDev,";
sumheaders3="C2NucleiCount,C2AreaAve,C2AreaStdDev,C2MeanAve,C2MeanStdDev,C2IntDenAve,C2IntDenStdDev,C2RawIntDenAve,C2RawIntDenStdDev"'
sumheaders=sumheaders1+sumheaders2+sumheaders3;
File.append(headers,dir2  + File.separator+ "Batch_Summary.csv");

splitChannelsFolder(dir1); // splits the 2-channel images into C1 and C2
processFolder(dir1); // this actually executes the functions

function splitChannelsFolder(dir1) 
	{
	// first step -- split each image into C1 and C2 
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
	// second step -- analyze the single-channel images
   list = getFileList(dir1);
   for (i=0; i<list.length; i++) 
   		{
        if(File.isDirectory(dir1 + File.separator + list[i])){
			processFolder("" + dir1 +File.separator+ list[i]);}
        else if (endsWith(list[i], suffix))
        	{
        	if (startsWith(list[i], "C1")){
           		processC1Image(dir1, list[i]);}
           	else if (startsWith(list[i], "C2")){
           		processC2Image(dir1, list[i]);}
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

function processC1Image(dir1, name) 
	{
	// analyze Arc -- count and measure nuclei, measure whole-image intensity, and save ROIs for overlap analysis
   open(dir1+File.separator+name);
   print("analyzing",n++, name);

   id = getImageID();
   title = getTitle();
   dotIndex = indexOf(title, ".");
   basename = substring(title, 0, dotIndex);
   procName = "processed_" + basename + ".tif";
   resultName = "C1_results.csv";
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
	run("Options...", "iterations=" + OPENITER + " count=" + OPENCOUNT + " black"); // smooth borders
	run("Open");
	run("Watershed"); // separate touching nuclei

	// analyze particles to get initial ROIs

	roiManager("reset");
	run("Analyze Particles...", "size=" + CELLMIN + "-" + CELLMAX + " exclude add");

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

	selectImage(id); // measure intensity in the original image
	roiManager("Deselect");
	// roiManager("multi-measure measure_all append"); // measures individual nuclei and appends results -- but erases the whole-image measurement
	run("Select None");
	for(i=0; i<numROIs;i++) // measures each ROI in turn
		{ 
		roiManager("Select", i); 
		run("Measure");
		}	
	run("Select None");
	run("Measure"); // measures whole image

	// SAVING DATA AND CLEANING UP  ------------------------------------------------------

	roiManager("Save", dir1 + File.separator + roiName); // will be needed for colocalization 
	roiManager("reset");

	String.copyResults;
	newResults = String.paste;
	newResults = substring(newResults,0,lengthOf(newResults)-1); // strip the final newline
	newResults = replace(newResults, "\t",","); // replace tabs with commas for csv
	File.append(newResults,dir2 + File.separator + resultName);

	// TODO: calculate averages and standard deviations, append to new results file

	//  the input results are in csv format: 
	// 0 rownumber, 1 label, 2 area, 3 mean, 4 min, 5 max, 6 x, 7 y, 8 intden, 9 rawintden
	// the label field has the filename; the first 3 chars are the channel (C1-), the last 9 chars are the ROI (:0000-0000)

	// desired output format
	// 0 filename, 1-3 c1 whole image (mean, intden, rawintden), 
	// 4 c1 nuclei count, average and sd of c1 (5-6 area, 7-8 mean, 9-10 intden, 11-12 rawintden), 
	// 13 c2 nuclei count, average and sd of c2 (14-15 area, 16-17 mean, 18-19 intden, 20-21 rawintden)

	// split results by line and comma
	C1numRows = 0; // get from length of the split results
	C1wholeImageResults = ""; // last line
	C1nucCount = 0; // get from length -1
	C1nucAreas = newArray(nucCount);
	C1nucMeans = newArray(nucCount);
	C1nucIDs = newArray(nucCount);
	C1nucRIDs = newArray(nucCount);
	
	// accumulate the values in the arrays
	// column 0  =  

	// calculate the means and stdevs
	
	// write to the summary file -- problem -- this cannot be done in this mode
	// because each image does not know about the other one, and we have to write one row at a time. cannot put C1 and C2 results in the same row.
	// column 0 = filename
	// columns 1-3 = whole image info
	// columns 4 = nuclei count
	// columns 

	run("Clear Results");

	selectWindow(procName);
	close();
	selectWindow(title);
	close();
	}

function processC2Image(dir1, name) 
	{
	// analyze c-Fos-- count and measure nuclei, and save ROIs for overlap analysis
   open(dir1+File.separator+name);
   print("analyzing",n++, name);

   id = getImageID();
   title = getTitle();
   dotIndex = indexOf(title, ".");
   basename = substring(title, 0, dotIndex);
   procName = "processed_" + basename + ".tif";
   resultName = "C2_results.csv";
   roiName = "RoiSet_" + basename + ".zip";

	// process a copy of the image
	selectImage(id);
	// square brackets allow handing of filenames containing spaces
	run("Duplicate...", "title=" + "[" +procName+ "]"); 
	selectWindow(procName);

	// PRE-PROCESSING -----------------------------------------------------------

	run("Subtract Background...", "rolling="+BACKGROUNDSIZE);
	run("Gaussian Blur...", "sigma=1");
	run("Enhance Local Contrast (CLAHE)", "blocksize=" + BLOCKSIZE + " histogram=256 maximum=3 mask=*None*");

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
	run("Analyze Particles...", "size=" + CELLMIN + "-" + CELLMAX + " exclude add");

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

	selectImage(id);
	roiManager("Deselect");
	// roiManager("multi-measure measure_all");
	run("Select None");
	for(i=0; i<numROIs;i++) // measures each ROI in turn
		{ 
		roiManager("Select", i); 
		run("Measure");
		}	
	run("Select None");

	// SAVING DATA AND CLEANING UP  ------------------------------------------------------

	String.copyResults;
	newResults=String.paste;
	newResults = substring(newResults,0,lengthOf(newResults)-1); // strip the final newline 
	newResults = replace(newResults, "\t",","); // replace tabs with commas for csv
	File.append(newResults,dir2 + File.separator + resultName);

	roiManager("Save", dir1 + File.separator + roiName); // will be needed for colocalization 
	selectWindow(procName);
	close();
	selectWindow(title);
	close();
	run("Clear Results");
	roiManager("reset");
	}


