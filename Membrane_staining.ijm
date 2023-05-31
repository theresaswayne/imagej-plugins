#@ int(label="How far inside cell outline to create membrane band? (pixels)") innerMargin
#@ int(label="Width of membrane band (pixels)") bandWidth
#@ int(label="Channel for analysis") Channel
#@ string(label="Thresholding method", choices={"None","Default","Huang","Intermodes","IsoData","IJ_IsoData","Li","MaxEntropy","Mean","MinError","Minimum","Moments","Otsu","Percentile","RenyiEntropy","Shanbhag","Triangle","Yen"}, style="listBox") threshMethod
#@ File (label = "Output directory", style = "directory") outputDir

// Membrane_staining.ijm
// ImageJ/Fiji macro by Theresa Swayne for Sarah Cardoso, 2023
// Measures membrane staining in 2D multichannel images
// Input:
// Output: 
// How to use this script: Open an image. Run the script. Enter the parameters.
// The cells are first detected using one channel, and then the membrane is defined as a band folowing the cell contour.
// The size and position of the band are defined by 2 parameters, inner margin and width.
// *Inner margin* defines the inner boundary of the band. The cell outline is shrunk (moved inward) by this many pixels.
// *Width* is the thickness of the band in pixels. 
// The cells are thresholded and the mean pixel intensity above threshold is measured in the whole cell, the shrunken (cytoplasmic) area, and the membrane band



// ---- Setup ----

roiManager("reset");
// get image info
id = getImageID();
title = getTitle();
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);

// ---- Pre-process images ---- 
//
//Make a copy of the image for processing
Stack.setChannel(Channel);
duplicateName = title+"_copy";
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

//If cells are merged together after thresholding, draw a line to separate them: 

run("Select None");
setLineWidth(3); // line is 3 pixels wide to fully separate cells
setTool("line");
setForegroundColor(0, 0, 0);
waitForUser("Use the line ROI tool to draw a line between merged cells, \nthen press F to finalize the line. \nAfter finalizing all lines, click OK.");
run("Fill Holes");

//Define cells: Analyze > Analyze Particles 

run("Analyze Particles...", "size=100-10000 display exclude clear add");

// ---- Define cell membrane ----

//For each cell ROI in the ROI Manager: 


// go through the list of cells and create the cytoplasm and membrane ROIs
numRois = roiManager("count");
for (index = 1; index < numRois; index++) {
	roiManager("Select", index);
	// rename for cell index, shrink and add a new ROI (inner index)
	// Edit > Selection > Enlarge > enter a negative number 
	// make band and add a new ROI (band index)
	// Edit > Selection > Make Band > enter the desired width 
	}

// loop through the ROIs and measure on the original image, creating 3 arrays for the different cell regions

// create a results table with a column for each cell region and a row for each cell


// save the ROIs for tissue area and the tiles inside it
run("Select None");
roiManager("Deselect");
roiManager("save", outputDir+File.separator+imageName+"_ROIs.zip");
}


// ---- Measure intensity ----

//Set up measurements: Analyze > Set Measurements, check Area, Mean, Display Label, Limit to Threshold 

//Threshold the original image:  

//click on the original image 

//Image > Adjust > Threshold, select Default, or Otsu, or experiment to find the best option to detect positive staining 

//Do NOT click Apply 

//For each band ROI in the Manager: 

//Select the band ROI in the Manager to activate it on the original image 

//Measure intensity: Press M or Analyze > Measure. 

//Alternatively, in the ROI Manager, click More >> MultiMeasure to automatically measure all ROIs.  

// ---- Save results ----

// Save the results table or copy/paste results into your preferred analysis software. 

// ---- Clean up ----
