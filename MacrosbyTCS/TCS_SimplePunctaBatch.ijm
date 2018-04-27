//macro for analyzing puncta within cells labeled for Kar2 or Nile Red
//a simpler version that counts gross total puncta and cells in a field, and integrated puncta density
//Theresa Swayne, Pon lab, 2011
// batch version 2012

// SETUP

// ask for folder containing source images. save everything in /tmp
// make the base name for images by stripping the extension if it exists

dir1 = getDirectory("Choose Source Directory ");
// dirName = getDirectory("image");

dir2 = getDirectory("Choose Destination Directory ");
list = getFileList(dir1);
setBatchMode(true);

for (i=0; i<list.length; i++) {	showProgress(i+1, list.length); open(dir1+list[i]);

	rawImageName = getTitle();
	if (endsWith(rawImageName,".tif")) {
		imageName=substring(rawImageName,0,(lengthOf(rawImageName)-4));
	}
	else {
		imageName=rawImageName;
	}	

	run("Set Measurements...", "area mean centroid integrated display redirect=None decimal=2");
	
	// print("The image title is " + rawImageName);
	// print("The new image name is " + imageName);
	
	
	// STEP 1. Identify cells (background and diffuse fluorescence provides cell shape)
	// NOTE: may want to enhance contrast, subtr bkgd in future.
	
	selectWindow(imageName+".tif");
	getStatistics(area, ImgMean, min, ImgMax, ImgStd);
	
	// ----------- SEGMENTATION OF CELLS -----------
	
	setAutoThreshold("Huang dark");
	getThreshold(lower, upper);
	
	// may also want to use local thresholding on this part
	
	run("Convert to Mask"); // this makes an 8 bit image
	selectWindow(imageName+".tif");
	run("Open"); // 1 time, 1 pixel
	run("Watershed");
	run("Analyze Particles...", "size=700-Infinity circularity=0.7-1.0 show=Masks exclude summarize");
	
	// note that the analyzed "cells" have a mean of 255 because this is done on the binary image
	
	selectWindow("Mask of "+imageName+".tif");
	saveAs("Tiff", dir2+imageName+" cells.tif"); // this is also an 8-bit image
	
	selectWindow(imageName+" cells.tif");
	// setAutoThreshold("Default");
	run("Create Selection");
	roiManager("Add"); // the cells are the 1st ROI in the list, number 0
	
	selectWindow(imageName+" cells.tif");
	close();
	
	// STEP 2. Select and measure just the detected cells on the original image.
	
	selectWindow(imageName+".tif");
	run("Revert");
	roiManager("Select", 0); // this should be the 1st and only roi in the list
	
	// measure mean of actual cells
	getStatistics(area, CellMean, min, CellMax, CellStd);
	
	
	// ------------- SEGMENTATION OF PUNCTA -----------
	
	punctaThresh=CellMean+2*CellStd;
	
	print("Name \t ImgMean \t ImgSD \t CellMean \t CellSD \t CellThresh \t PunctaThresh");
	print(imageName+"\t"+ImgMean+"\t"+ImgStd+"\t"+CellMean+"\t"+CellStd+"\t"+lower+"\t"+punctaThresh);
		
	// STEP 3. Threshold and measure puncta.
	
	setThreshold(punctaThresh,ImgMax);		// Threshold for puncta	run("Analyze Particles...", "size=12-1000 circularity=0.00-1.00 show=Masks exclude summarize");
	selectWindow("Mask of "+imageName+".tif");
	saveAs("Tiff", dir2+imageName+" puncta.tif");
	run("Create Selection");
	roiManager("Add"); // the puncta are the 2nd ROI in the list, number 1
	close();
	
	selectWindow("Summary");
	saveAs("Text", dir2+imageName+" Summary.xls"); 
	
	// save an image of the ROIs on the cells for evaluation purposes
	
	selectWindow(imageName+".tif");
	run("Revert");
	setOption("Show All", true);
	run("Flatten");
	saveAs("Tiff", dir2+imageName+" overlay.tif");
	
	// STEP 4. CLEANUP
	
	roiManager("reset");
	selectWindow(imageName+".tif");
	close();
	selectWindow(imageName+" overlay.tif");
	close();
	selectWindow("Log");
	saveAs("Text", dir2+imageName+" Log.xls"); 
	// print("\\Clear");
	// run("Close");
	run("Clear Results");	if (isOpen("Results")) {	          selectWindow("Results");	          run("Close");	      }
	// if (isOpen("Summary")) {	//          selectWindow("Summary");	//          run("Close");	//      }
}
