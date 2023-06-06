#@ Double (label="How far inside cell outline to create membrane band? (microns)", style="format:#.#") innerMargin
#@ Double (label="Width of membrane band (microns)", style="format:#.#") bandWidth
#@ int (label="Channel for analysis") Channel
#@ string (label="Thresholding method", choices={"None","Default","Huang","Intermodes","IsoData","IJ_IsoData","Li","MaxEntropy","Mean","MinError","Minimum","Moments","Otsu","Percentile","RenyiEntropy","Shanbhag","Triangle","Yen"}, style="listBox") threshMethod
#@ File (label = "Output directory", style = "directory") outputDir

// Membrane_staining.ijm
// ImageJ/Fiji macro by Theresa Swayne for Sarah Cardoso, 2023
// Measures membrane staining in 2D multichannel images
// Input: Single- or multi-channel single-plane image
// Output: 
// -- Mean and Integrated Intensity measurements for each cell, "cytoplasm", and "membrane" area
// -- ROIs for each of these compartments 
// How to use this script: Open an image. Run the script. 
// Enter the parameters (see below for details).
// After the cells are thresholded, you will be able to manually separate contiguous cells  
// The cells are first detected using a channel chosen by the user.
// The cytoplasm and membrane are defined using 2 user-chosen parameters: inner margin and width.
// *Inner margin* defines the inner boundary of the band. 
//		The cell outline is shrunk (moved inward) by this amount. 
// 		This smaller area is defined as the cytoplasm.
// *Width* is the thickness of the membrane band in um. 
// TIP: Choose the initial threshold, inner margin and width to minimize inclusion of background in the measurements.


// ---- Setup ----
requires("1.48h");
roiManager("reset");
run("Select None");
run("Clear Results");
run("Input/Output...", "file=.csv copy_row save_column save_row"); 
// get image info
id = getImageID();
title = getTitle();
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);
resultFile = outputDir + File.separator + basename+"_results.csv";
roiFile = outputDir+File.separator+basename+"_ROIs.zip";

// ---- Pre-process images ---- 

// make a copy of the relevant channel
Stack.setChannel(Channel);
maskName = basename+"_mask";
run("Duplicate...", "title=&maskName");
selectWindow(maskName);

// enhance dim areas to improve recognition of cell boundaries
// reduce blocksize to enhance smaller areas of intensity
run("Enhance Local Contrast (CLAHE)", "blocksize=127 histogram=256 maximum=3 mask=*None* fast_(less_accurate)");

// smooth the image to remove noise in cell boundaries
run("Gaussian Blur...", "sigma=3");

// ---- Define cells ----

// threshold the pre-processed image
setAutoThreshold(threshMethod +" dark");
setOption("BlackBackground", true);
run("Convert to Mask");

// close up gaps
run("Options...", "iterations=3 count=1 black do=Close slice");

// allow user to manually separate cells from each other and the image border 
run("Select None");
setTool("line");
run("Line Width...", "line=4"); // line is wide to fully separate cells
setForegroundColor(0, 0, 0);
waitForUser("Use the line ROI tool to draw a line between merged cells, \nthen press F to finalize the line. \nAfter finalizing all lines, click OK.");

// make the cell areas solid
run("Fill Holes");
// erode slightly to avoid missing the membrane edge
run("Options...", "iterations=2 count=1 black do=Erode slice");

// identify cells as distinct regions of the desired size
// (edit the size parameters as needed to exclude artifacts)
// and add the identified cells to the ROI manager

run("Analyze Particles...", "size=500-100000 exclude clear add");

// ---- Define cytoplasm and membrane ----

// rename the cell ROIs with numbers
renameROIs("Cell");

// create the cytoplasm and membrane ROIs for each cell
numCells = roiManager("count"); // initial cell count
innerMargin = 0-innerMargin; // make the value negative

for (i = 0; i < numCells; i++) { // loop through all cells
	cellName = "Cell_"+i;
	index = findRoiWithName(cellName); // find the original cell ROI
	if (index != -1) { // -1 means the name was not found
		roiManager("Select", index);
		run("Enlarge...", "enlarge=&innerMargin"); // shrink the cell to define the cytoplasm
		Roi.setName("Cytoplasm_"+index);
		roiManager("add"); // this ROI will be added at the end of the list
		run("Make Band...", "band=&bandWidth"); // create the membrane ROI based on the cytoplasm + the width
		Roi.setName("Membrane_"+index); 
		roiManager("add"); // this ROI will be added just after the cytoplasm ROI
	}
}

// ---- Measure intensity and save results ----

// set which measurements to make
run("Set Measurements...", "area mean integrated display redirect=None decimal=2");

// duplicate the channel of interest
selectWindow(title);
Stack.setChannel(Channel);
duplicateName = basename+"_copy";
run("Duplicate...", "title=&duplicateName");
selectWindow(duplicateName);

// measure cell compartments and add results to the output file 
for (cell = 0; cell < numCells; cell++) { // loop through cells
	
	// select all 3 ROIs belonging to this cell 
	cellExp = ".*_"+cell; // regular expression to find all ROIs with this cell number
	cellIndices = findRoisWithName(cellExp);
	roiManager("select", cellIndices); 
	
	// measure ROIs belonging to this cell
	roiManager("multi-measure one"); // one row per slice, does not append results
	
	// read results data
	selectWindow("Results");
	lines = split(getInfo(), "\n"); // array containing each row of the table (there's only 1 row plus the headers)
	values = split(lines[1], "\t"); // array containing each value in the data row (results table is tab-separated)
	values[0] = cell; // replace the row number with the cell number

	// separate result values with commas for CSV output
	resultLine = String.join(values, ",");

	// write the data to a file
	if (File.exists(resultFile)==false) { // start the file with headers
		ResultHeaders = "CellNumber,Label,Area_Cell,Mean_Cell,IntDen_Cell,RawIntDen_Cell,Area_Cytoplasm,Mean_Cytoplasm,IntDen_Cytoplasm,RawIntDen_Cytoplasm,Area_Membrane,Mean_Membrane,IntDen_Membrane,RawIntDen_Membrane"; // comma-separated
		File.append(ResultHeaders,resultFile);
		print("Added headings: ",ResultHeaders);
    	}
	File.append(resultLine,resultFile); // add the data
	print("Added results for cell",cell);
}

// --- Save ROIs ---- 
run("Select None");
roiManager("Deselect");
roiManager("save", roiFile);

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

// Functions to find ROIs by name
// thanks to Olivier Burri on forum.image.sc

/* 
 * Returns index of first ROI that matches  
 * the given regular expression 
 */  
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

