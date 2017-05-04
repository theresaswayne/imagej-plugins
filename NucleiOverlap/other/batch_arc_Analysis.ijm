// batch_arc_Analysis.ijm
// IJ macro to analyze arc-labeled nuclei and fibers
// Theresa Swayne, Columbia University, 2017
// Based on IJ batch processing template
// This macro processes all the images in a folder and any subfolders.
// input: a folder of single-channel single-z TIFFs
// output: 1 ROIset per image, one csv file containing measurements of all images
// usage: run the macro, choose input then output folders.

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

run("Input/Output...", "file=.csv save_column save_row"); // saves data as CSV and preserves headers
run("Set Measurements...", "area mean min centroid integrated display decimal=2");
run("Clear Results");
roiManager("reset");

// batch setup
extension = ".tif";
dir1 = getDirectory("Choose Source Directory "); // note that on Mac as of 2017 the dialog titles are not visible.
print("input = "+dir1);
dir2 = getDirectory("Choose Destination Directory "); 
print("output = "+dir2);
setBatchMode(true);
n = 0;
processFolder(dir1); // where the processing happens

function processFolder(dir1) {
   list = getFileList(dir1);
   for (i=0; i<list.length; i++) {
        if (endsWith(list[i], "/"))
            processFolder(dir1+list[i]);
        else if (endsWith(list[i], extension))
           processImage(dir1, list[i]);
    }
}

function processImage(dir1, name) {
   open(dir1+name);
   print(n++, name);

   id = getImageID();
   title = getTitle();
   dotIndex = indexOf(title, ".");
   basename = substring(title, 0, dotIndex);
   procName = "processed_" + basename + ".tif";
   resultName = "results_.csv";
   roiName = "RoiSet_" + basename + ".zip";

// process a copy of the image
selectImage(id);
// square brackets allow handing of filenames containing spaces
run("Duplicate...", "title=" + "[" +procName+ "]"); 
selectWindow(procName);

// PRE-PROCESSING -----------------------------------------------------------

// print("subtracting background for "+procName);
run("Subtract Background...", "rolling="+BACKGROUNDSIZE);
// print("median filtering "+procName);
run("Median...", "radius=3");
// run("Enhance Local Contrast (CLAHE)", "blocksize=" + BLOCKSIZE + " histogram=256 maximum=3 mask=*None*"); 

// SEGMENTATION AND MASK PROCESSING -------------------------------------------

selectWindow(procName);
print("thresholding image "+procName);
run("Auto Local Threshold", "method=Phansalkar radius=" + RADIUS + " parameter_1=0 parameter_2=0 white");
// print("masking "+procName);
run("Convert to Mask");

selectWindow(procName);
// print("binary-opening "+procName);
run("Options...", "iterations=" + OPENITER + " count=" + OPENCOUNT + " black"); // smooth borders
run("Open");
// print("watershedding "+procName);
run("Watershed"); // separate touching nuclei

// analyze particles to get initial ROIs

roiManager("reset");
// print("analyzing particles in "+procName);
run("Analyze Particles...", "size=" + CELLMIN + "-" + CELLMAX + " exclude add");

// shrink ROIs to match nuclei

// print("shrinking ROIs for "+procName);
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
// print("measuring "+procName);
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

// print("saving ROIs for "+procName);
roiManager("Save", dir2 + roiName); // will be needed for colocalization 
roiManager("reset");
saveAs("Results", dir2 + resultName); // saves every time
selectWindow(procName);
close();
selectWindow(title);
close();

}


