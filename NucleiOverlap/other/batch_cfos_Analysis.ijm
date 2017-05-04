// batch_cfos_Analysis.ijm
// IJ macro to analyze c-fos nuclei
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
OPENITER = 3 // higher value = more smoothing
OPENCOUNT = 3 // lower value = more smoothing
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

run("Set Measurements...", "area mean min centroid display decimal=2");
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

saveAs("Results", dir2 + resultName);
roiManager("Save", dir2 + roiName); // will be needed for colocalization 
selectWindow(procName);
close();
selectWindow(title);
close();
// run("Clear Results");
roiManager("reset");
}
