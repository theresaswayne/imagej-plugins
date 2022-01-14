#@ int(label="Size of tiles in pixels:") boxSize
#@ File (label = "Output directory", style = "directory") path
 
// Divide_into_Tiles_bySize.ijm
// Theresa Swayne, 2021
// Grid based on BIOP_VSI_reader By Olivier Burri & Romain Guiet, EPFL BIOP 2014-2018
// Usage: Open an image and run the macro. Output and ROI set are saved in user-designated folder.

id = getImageID();
title = getTitle();
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);
print(path);

setBatchMode(true); // greatly increases speed and prevents lost tiles

// path = getDirectory("image");
// ? TODO: Set measurements, measure, save table

makeGrid(boxSize);

cropAndSave(id, basename, path);

// cropMeasureSave(id, basename, path);

setBatchMode(false);
/*
 * Helper function, find ceiling value of float
 */
function ceiling(value) {
	tol = 0.2; // this becomes the fraction of box size below which an edge tile is not created  
	if (value - round(value) > tol) {
		return round(value)+1;
	} else {
		return round(value);
	}
}

/*
 * Convenience function for adding ROIs to the ROI manager, with the right name
 */
function addRoi() {
	image = getTitle();
	roinum = roiManager("Count");
	Roi.setName(image+" ROI #"+(roinum+1));
	roiManager("Add");
}


/*
 * Creates a regular non-overlapping grid around the user's selection in tiles of selectedSize
 * and saves the ROI set
 */
function makeGrid(selectedSize) {
	//Make grid based on selection or whole image
	getSelectionBounds(x, y, width, height);
	
	// Set Color
	color = "red";

	// Calculate how many boxes we will need based on the user-selected size 
	// --  note that thin edges will not be converted based on tolerance in ceiling function
	nBoxesX = ceiling(width/selectedSize);
	nBoxesY = ceiling(height/selectedSize);
	
	run("Remove Overlay");
	roiManager("Reset");

	for(j=0; j< nBoxesY; j++) {
		for(i=0; i< nBoxesX; i++) {
			makeRectangle(x+i*selectedSize, y+j*selectedSize, selectedSize,selectedSize);

			addRoi();
		}
	}

	run("Select None");
	roiManager("save", path+File.separator+"ROIs.zip");
}

function cropAndSave(id, basename, path) {
	// make sure nothing selected to begin with
	
	roiManager("Deselect");
	run("Select None");
	
	numROIs = roiManager("count");
	// how much to pad?
	digits = 1 + Math.ceil((log(numROIs)/log(10)));
	//print("digits",digits);
	for(roiIndex=0; roiIndex < numROIs; roiIndex++) // loop through ROIs
		{ 
		selectImage(id);
		roiNum = roiIndex + 1; // image names starts with 1 like the ROI labels
		roiNumPad = IJ.pad(roiNum, digits);
		//print("padded number",roiNumPad);
		cropName = basename+"_tile_"+roiNumPad;
		//print("cropped name",cropName);
		roiManager("Select", roiIndex);  // ROI indices start with 0
		run("Duplicate...", "title=&cropName duplicate"); // creates the cropped stack
		selectWindow(cropName);
		saveAs("tiff", path+File.separator+getTitle);
		close();
		}	
	run("Select None");
}


function cropMeasureSave(id, basename, path) {
	// make sure nothing selected to begin with
	
	roiManager("Deselect");
	run("Select None");

	cutoffMean = 2; // minimum mean value to be considered
	
	numROIs = roiManager("count");
	// how much to pad?
	digits = Math.ceil((log(numROIs)/log(10)));
	//print("digits",digits);

	for(roiIndex=0; roiIndex < numROIs; roiIndex++) // loop through ROIs
		{ 
		selectImage(id);
		roiNum = roiIndex + 1; // image names starts with 1 like the ROI labels
		roiNumPad = IJ.pad(roiNum, digits);
		//print("padded number",roiNumPad);
		cropName = basename+"_tile_"+roiNumPad;
		//print("cropped name",cropName);
		roiManager("Select", roiIndex);  // ROI indices start with 0
		run("Duplicate...", "title=&cropName duplicate"); // creates the cropped stack
		selectWindow(cropName);
		// measure
		getStatistics(area, mean, min, max, std);
		if(mean > cutoffMean) {
			saveAs("tiff", path+File.separator+getTitle); }
		close();
		}
	run("Select None");
}