// @File(label = "Input directory", style = "directory") dir1
// @File(label = "Output directory", style = "directory") dir2
// @String(label = "File suffix", value = ".tif") suffix

// Note: DO NOT DELETE OR MOVE THE FIRST 3 LINES -- they supply essential parameters
// batch_cfosArc_Analysis.ijm
// IJ macro to analyze c-fos and Arc in nuclei, and Arc in whole image
// Theresa Swayne, Columbia University, 2017
// Based on IJ batch processing template
// This macro processes all the images in a folder and any subfolders. But note that the results all end up in a single directory.
// input: a folder of single-channel single-z TIFFs with names starting with either "C1" (arc) or "C2" (cfos)
// output: 1 ROIset per image, one csv file per channel containing measurements of all images
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

processFolder(dir1); // this actually executes the functions

function processFolder(dir1) {
   list = getFileList(dir1);
   for (i=0; i<list.length; i++) {
        if(File.isDirectory(dir1 + File.separator + list[i])) {
			processFolder("" + dir1 +File.separator+ list[i]);}
        else if (endsWith(list[i], suffix))
        	if (startsWith(list[i], "C1"))
           		processC1Image(dir1, list[i]);
           	else if (startsWith(list[i], "C2")) {
           		processC2Image(dir1, list[i]);
           	}
    }
}



function processC1Image(dir1, name) {
   open(dir1+File.separator+name);
   print(n++, name);

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

roiManager("Save", dir2 + File.separator + roiName); // will be needed for colocalization 
roiManager("reset");

String.copyResults;
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

function processC2Image(dir1, name) {
   open(dir1+File.separator+name);
   print(n++, name);

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

roiManager("Save", dir2 + File.separator + roiName); // will be needed for colocalization 
selectWindow(procName);
close();
selectWindow(title);
close();
run("Clear Results");
roiManager("reset");
}


