// Matheus Viana - vianamp@gmail.com - 7.29.2013
// ==========================================================================

// This macro is used to crop cells from microscope frames that in general contains
// more than one cell.
// 1. Use the macro GenFramesMaxProjs.ijm to generate the file MaxProjs.tiff
// 2. Use the stack MaxProjs.tiff to drawn ROIs around the cells that must be
//    analysed.
// 3. Save the ROIs as RoiSet.zip

// Selecting the folder that contains the TIFF frame files plus the RoiSet.zip and
// MaxProjs.tiff files.

// Defining the size of the singl cell images:
_xy = 200;

_RootFolder = getDirectory("Choose a Directory");

// Creating a directory where the files are saved
File.makeDirectory(_RootFolder + "cells");

setBatchMode(true);
// Prevent generation of 32bit images
run("RandomJ Options", "  adopt progress");

run("ROI Manager...");
roiManager("Reset");
roiManager("Open",_RootFolder + "RoiSet.zip");

open("MaxProjs.tif");
MAXP = getImageID;

// For each ROI (cell)

for (roi = 0; roi < roiManager("count"); roi++) {
			
	roiManager("Select",roi);
	_FileName = getInfo("slice.label");
	_FileName = replace(_FileName,".tif","@");
	_FileName = split(_FileName,"@");
	_FileName = _FileName[0];

	open(_FileName + ".tif");
	ORIGINAL = getImageID;

	run("Restore Selection");

	newImage("CELL","16-bit Black",_xy,_xy,nSlices);
	CELL = getImageID;

	// Estimating the noise distribution around the ROI
	max_ai = 0;
	for (s = 1; s <= nSlices; s++) {
		selectImage(MAXP);
		
		selectImage(ORIGINAL);
		setSlice(s);
		run("Restore Selection");
		run("Make Band...", "band=5");
		getStatistics(area, mean, min, max, std);
		run("Restore Selection");
		run("Copy");
		
		selectImage(CELL);
		setSlice(s);
		run("Select None");		
		run("Add...", "value=" + mean + " slice");
		run("Add Specified Noise...", "slice standard=" + 0.5*std);
		run("Paste");
		
		getStatistics(area, mean, min, max, std);
		if (mean>max_ai) {
			max_ai = mean;
			slice_max_ai = s;
		}
		
	}
	
	run("Select None");
	resetMinAndMax();

	save(_RootFolder + "cells/" + _FileName + "_" + IJ.pad(roi,3) + ".tif");

	selectImage(CELL); close();
	selectImage(ORIGINAL); close();

}

setBatchMode(false);