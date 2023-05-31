#@ Double (label="How far inside cell outline to create membrane band? (microns)", style="format:#.#") innerMargin
#@ Double (label="Width of membrane band (microns)", style="format:#.#") bandWidth
#@ int (label="Channel for analysis") Channel
#@ string (label="Thresholding method", choices={"None","Default","Huang","Intermodes","IsoData","IJ_IsoData","Li","MaxEntropy","Mean","MinError","Minimum","Moments","Otsu","Percentile","RenyiEntropy","Shanbhag","Triangle","Yen"}, style="listBox") threshMethod
#@ File (label = "Output directory", style = "directory") outputDir

// Membrane_staining.ijm
// ImageJ/Fiji macro by Theresa Swayne for Sarah Cardoso, 2023
// Measures membrane staining in 2D multichannel images
// Input:
// Output: 
// How to use this script: Open an image. Run the script. Enter the parameters.
// The cells are first detected using one channel, and then the membrane is defined as a band folowing the cell contour.
// The size and position of the band are defined by 2 parameters, inner margin and width.
// *Inner margin* defines the inner boundary of the band. The cell outline is shrunk (moved inward) by this many um.
// *Width* is the thickness of the band in um. 
// The cells are thresholded and the mean pixel intensity above threshold is measured in the whole cell, the shrunken (cytoplasmic) area, and the membrane band



// ---- Setup ----

roiManager("reset");
run("Select None");
// get image info
id = getImageID();
title = getTitle();
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);

// ---- Pre-process images ---- 
//
//Make a copy of the image for processing
Stack.setChannel(Channel);
duplicateName = basename+"_copy";
run("Duplicate...", "title=&duplicateName");
selectWindow(duplicateName);

//Enhance local contrast: Process > Enhance Local Contrast CLAHE, use default settings 
run("Enhance Local Contrast (CLAHE)", "blocksize=127 histogram=256 maximum=3 mask=*None* fast_(less_accurate)");

//Smooth the contrast-enhanced image: Process > Filters > Gaussian Blur, sigma = 4 pixels 
run("Gaussian Blur...", "sigma=4");

// ---- Define cells ----

//Auto threshold the smoothed, enhanced image: Image > Adjust > Threshold, select Minimum, or experiment to find the best option, Apply 
setAutoThreshold(threshMethod +" dark");
setOption("BlackBackground", true);
run("Convert to Mask");

// If cells are merged together after thresholding, draw a line to separate them: 
// Also, if small processes of cells go to the image boundary, you can draw a line to separate them from the edge

run("Select None");
setTool("line");
setLineWidth(4); // line is wide to fully separate cells
setForegroundColor(0, 0, 0);
waitForUser("Use the line ROI tool to draw a line between merged cells, \nthen press F to finalize the line. \nAfter finalizing all lines, click OK.");
run("Fill Holes");

// Define cells
// Edit the Size parameters as needed to exclude artifacts

run("Analyze Particles...", "size=100-100000 display exclude clear add");

// ---- Define cell membrane ----

//For each cell ROI in the ROI Manager: 

// rename the Cell ROIs

renameROIs("Cell");

// go through the list of cells and create the cytoplasm and membrane ROIs
numCells = roiManager("count"); // count at the beginnning before adding all the extra ROIs 
innerMargin = 0-innerMargin;
for (i = 0; i < numCells; i++) {
	cellName = "Cell_"+i;
	print("Searching for",cellName);
	index = findRoiWithName(cellName);
	if (index != -1) {
		print("ROI",index,"is a cell");
		roiManager("Select", index);
		run("Enlarge...", "enlarge=&innerMargin");
		Roi.setName("Cytoplasm_"+index); // must rename before adding
		roiManager("add"); // will be added at the end of the list
		run("Make Band...", "band=&bandWidth");
		Roi.setName("Membrane_"+index); // must rename before adding
		roiManager("add"); // will be added just after the cytoplasm ROI
	}
}


// save the full set of ROIs 
run("Select None");
roiManager("Deselect");
roiManager("save", outputDir+File.separator+basename+"_ROIs.zip");

// ---- Measure intensity ----

//Set up measurements: Analyze > Set Measurements, check Area, Mean, Display Label, Limit to Threshold 

//Threshold the original image:  

//Image > Adjust > Threshold, select Default, or Otsu, or experiment to find the best option to detect positive staining 

//Do NOT click Apply 

//For each band ROI in the Manager: 

//Select the band ROI in the Manager to activate it on the original image 

//Measure intensity: Press M or Analyze > Measure. 

//Alternatively, in the ROI Manager, click More >> MultiMeasure to automatically measure all ROIs.  

// ---- Save results ----

// Save the results table or copy/paste results into your preferred analysis software. 

// ---- Clean up ----
selectWindow(duplicateName);
close();
roiManager("reset");


// ---- Functions ----

// Function to rename ROIs in order

function renameROIs(newName) {
	numRois = roiManager("count");
	for (index = 0; index < numRois; index++) {
		roiManager("Select", index);
		roiManager("rename", newName+"_"+index);
		roiManager("deselect");	
	}
}


// Function to find ROIs by name
/* 
 * Returns index of first ROI that matches  
 * the given regular expression 
 */ 
 // thanks to Olivier Burri on forum.image.sc
function findRoiWithName(roiName) { 
	nR = roiManager("count"); 
 
	for (i=0; i<nR; i++) { 
		roiManager("Select", i); 
		rName = Roi.getName(); 
		if (matches(rName, roiName)) { 
			return i; 
		} 
	} 
	return -1; 
} 
 
