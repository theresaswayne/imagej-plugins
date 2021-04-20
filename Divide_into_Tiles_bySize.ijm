#@ int(label="Size of tiles:") boxSize

// Divide_into_Tiles_bySize.ijm
// Theresa Swayne, 2021
// Grid based on BIOP_VSI_reader By Olivier Burri & Romain Guiet, EPFL BIOP 2014-2018

id = getImageID();
title = getTitle();
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);
path = getDirectory("image");


makeGrid(boxSize);

cropAndSave(id, basename, path);

/*
 * Helper function, find ceiling value of float
 */
function ceiling(value) {
	tol = 0.4;
	if (value - round(value) > tol) {
		return round(value)+1;
	} else {
		return round(value);
	}
}

/*
 * Convenience function for adding ROIs to the ROI manager, with the right name
 */
function addRoi(isSave) {
	image = getTitle();
	roinum = roiManager("Count");
	Roi.setName(image+" ROI #"+(roinum+1));
	roiManager("Add");
	if (isSave) {saveRois("Open"); }
}


/*
 * Creates a regular non-overlapping grid around the user's selection in tiles of selectedSize
 */
function makeGrid(selectedSize) {
	//Make grid based on selection or whole image
	getSelectionBounds(x, y, width, height);
	print(width, height)
	
	// Set Color
	color = "red";

	// Calculate how many boxes we will need based on a user-selected size

	// Then we need the calibration, which gives us the REAL pixel size
	getVoxelSize(px,py,pz,unit);


	// Thus we will need
	nBoxesX = ceiling(width/selectedSize);
	nBoxesY = ceiling(height/selectedSize);
	print(nBoxesX, nBoxesY);

	run("Remove Overlay");
	roiManager("Reset");

	for(j=0; j<=nBoxesY; j++) {
		for(i=0; i<=nBoxesX; i++) {
			makeRectangle(x+i*selectedSize, y+j*selectedSize, selectedSize,selectedSize);

			addRoi(false);
		}
	}

	run("Select None");
}

function cropAndSave(id, basename, path) {
	// make sure nothing selected to begin with
	
	roiManager("Deselect");
	run("Select None");
	
	numROIs = roiManager("count");
	for(roiIndex=0; roiIndex < numROIs; roiIndex++) // loop through ROIs
		{ 
		selectImage(id);
		roiNum = roiIndex + 1; // image names starts with 1 like the ROI labels
		cropName = basename+"_tile_"+roiNum;
		roiManager("Select", roiIndex);  // ROI indices start with 0
		run("Duplicate...", "title=&cropName duplicate"); // creates the cropped stack
		selectWindow(cropName);
		saveAs("tiff", path+getTitle);
		close();
		}	
	run("Select None");
}