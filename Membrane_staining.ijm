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
run("Clear Results");
run("Input/Output...", "file=.csv copy_row save_column save_row"); 
// get image info
id = getImageID();
title = getTitle();
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);

// ---- Pre-process images ---- 
//
//Make a copy of the image for processing
Stack.setChannel(Channel);
maskName = basename+"_mask";
run("Duplicate...", "title=&maskName");
selectWindow(maskName);

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

run("Analyze Particles...", "size=500-100000 exclude clear add");

// ---- Define cell membrane ----

//For each cell ROI in the ROI Manager: 

// rename the Cell ROIs

renameROIs("Cell");

// go through the list of cells and create the cytoplasm and membrane ROIs
numCells = roiManager("count"); // count at the beginnning before adding all the extra ROIs 
innerMargin = 0-innerMargin;
for (i = 0; i < numCells; i++) {
	cellName = "Cell_"+i;
	//print("Searching for",cellName);
	index = findRoiWithName(cellName);
	if (index != -1) {
		//print("ROI",index,"is a cell");
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

// set which measurements to make
run("Set Measurements...", "area mean integrated display redirect=None decimal=2");

// collect measurements for each type of ROI
// 1. select all ROIs of a type (or of a cell then multimeasure?)
// 2. measure these ROIs
// 3. Split the results into arrays 

selectWindow(title); // original image
Stack.setChannel(Channel); // channel for analysis
duplicateName = basename+"_copy";
run("Duplicate...", "title=&duplicateName");
selectWindow(duplicateName); // image with only one channel

resultFile = outputDir + File.separator + basename+"_results.csv";

for (cell = 0; cell < numCells; cell++) {
	// select all the ROIs belonging to that cell
	cellExp = ".*_"+cell; // regex finding all with that number appended
	cellIndices = findRoisWithName(cellExp);
	roiManager("select", cellIndices);
	roiManager("multi-measure one"); // one row per slice, does not append results
	
	selectWindow("Results");
	lines = split(getInfo(), "\n"); 
	values = split(lines[1], "\t"); // results table is tab-separated
	values[0] = cell; // include the cell number

	//		construct the data line with values separated by commas
	resultLine = String.join(values, ",");

	// begin the new comma-separated file if needed, then add the data
	if (File.exists(resultFile)==false) {
		ResultHeaders = "CellNumber,Label,Area_Cell,Mean_Cell,IntDen_Cell,RawIntDen_Cell,Area_Cytoplasm,Mean_Cytoplasm,IntDen_Cytoplasm,RawIntDen_Cytoplasm,Area_Membrane,Mean_Membrane,IntDen_Membrane,RawIntDen_Membrane"; // comma-separated
		File.append(ResultHeaders,resultFile);
		print("added headings: ",ResultHeaders);
    	}
	File.append(resultLine,resultFile);
	print("Added results for cell",cell);
}



// ---- Clean up ----
selectWindow(maskName);
close();
selectWindow(duplicateName);
close();
roiManager("reset");
showMessage("Finished.");

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

/* 
 * Returns an array of indexes of ROIs that match  
 * the given regular expression 
 */ 
 // thanks to Olivier Burri on forum.image.sc
function findRoisWithName(roiName) { 
	nR = roiManager("Count"); 
	roiIdx = newArray(nR); 
	k=0; 
	clippedIdx = newArray(0); 
	 
	for (i=0; i<nR; i++) { 
		roiManager("Select", i); 
		rName = Roi.getName(); 
		if (matches(rName, roiName) ) { 
			roiIdx[k] = i; 
			k++; 
		} 
	} 
	if (k>0) { 
		clippedIdx = Array.trim(roiIdx,k); 
	} 
	 
	return clippedIdx; 
} 

