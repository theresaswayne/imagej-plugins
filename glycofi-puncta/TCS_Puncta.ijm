//macro for analyzing inclusions within cells labeled for Kar2 or Nile Red
//Theresa Swayne, Pon lab, 2011
//ROI mgr loop code from Elizabeth Crowell

// SETUP

// start with an open image. save everything in /tmp
// make the base name for images by stripping the extension if it exists

dirName = getDirectory("temp");
rawImageName = getTitle();
if (endsWith(rawImageName,".tif")) {
	imageName=substring(rawImageName,0,(lengthOf(rawImageName)-4));
}
else {
	imageName=rawImageName;
}

run("Set Measurements...", "area mean centroid integrated display redirect=None decimal=2");

 print("The image title is " + rawImageName);
 print("The new image name is " + imageName);


// STEP 1. Identify cells (background and diffuse fluorescence provides cell shape)

// save a copy of the raw image in the tmp folder

selectWindow(imageName+".tif");
copyImageName=imageName+" raw.tif";
run("Duplicate...", "title=&copyImageName");
selectWindow(copyImageName);
saveAs("Tiff",dirName+copyImageName);
close();

// make the thresholded image (of cells) and save it
// get the mean and SD of the image

// NOTE: may want to subtr bkgd in future.

selectWindow(imageName+".tif");
getStatistics(area, mean, min, max, std);
print("The regular mean is "+mean);
getRawStatistics(area, mean, min, max, std);
print("The raw mean is "+mean);

// raw stats should work for 16bit images

// ----------- SEGMENTATION OF CELLS -----------

setAutoThreshold("Default dark");
getThreshold(lower, upper);

// ------------- SEGMENTATION OF PUNCTA -----------

// inclusionThresh=lower+2*std;
// replaced with an artificial threshold while using test image

inclusionThresh=63000;

// Save thresholded image

print("Mean "+mean+", SD "+std+", cell thresh="+lower+", inclusion thresh="+inclusionThresh);

run("Convert to Mask");
saveAs("Tiff", dirName+imageName+" thr.tif");

// find cell-like particles, and add each cell to roi mgr

// TO ADD: Save the image with cells numbered.
// TO ADD: Rename ROIs to cell number

selectWindow(imageName+" thr.tif");
run("Analyze Particles...", "size=500-Infinity circularity=0.7-1.0 show=Masks display exclude add summarize");
selectWindow("Mask of "+imageName+" thr.tif");
saveAs("Tiff", dirName+imageName+" cells.tif");
selectWindow("Results");
run("Clear Results");

// selectWindow("Summary");
// saveAs("Text", dirName+imageName+" cells summary.xls");
// this info may be redundant with the cells' individual measurements


roiManager("Save", dirName+imageName+" cells RoiSet.zip");
selectWindow(imageName+" thr.tif");
close();

// STEP 2. For each cell, threshold again and measure inclusions.

open(dirName+imageName+" raw.tif");
selectWindow(imageName+" raw.tif");

// roiManager("Open", dirName+imageName+" cells RoiSet.zip");

 length = roiManager("count");  // Get the length of the ROI manager list.


	  run("Duplicate...", "title=temp");   // Make a separate image containing only the ROI.
	  titleString="cell "+(j+1);
	  print("Title string = "+titleString);
	  
	  selectImage("temp");
	  rename(titleString);
	  
      run("Select None");                   // Deselect everything.




selectWindow("Summary");
saveAs("Text", dirName+imageName+" Summary .xls"); // the summary builds each time so just save the last time.