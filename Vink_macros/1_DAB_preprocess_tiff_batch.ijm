// @File(label = "Input directory", style = "directory") input
// @File(label = "Output directory", style = "directory") output
// @String(label = "File suffix", value = ".tif") suffix
// @String(label = "Objective Lens", choices={"4x", "20x", "Other"}, style="listBox") mag
// @String(label = "If Other, pixel size in um", value = "0") manPixSize

// Note: DO NOT DELETE OR MOVE THE FIRST FEW LINES -- they supply essential parameters.

// 1_DAB_preprocess_tiff_batch.ijm
// ImageJ/Fiji macro
// Theresa Swayne, tcs6@cumc.columbia.edu, 2018

// Input: a folder of RGB TIF images of hematoxylin and DAB
// Corrects image illumination, color, and scale.
// Deconvolves colors using "H DAB" scheme.
// Output: 	1) RGB TIF corrected for background, color balance, and scale
//     		2) grayscale TIFs of hematoxylin and DAB components

// Usage: Run the macro.

// setup
startTime = getTime();
setBatchMode(true);

n = 0; // number of images

// determine scale factor
if (mag=="4x") {
	pixPerMicron = 2.5595;
	print("4x objective; scale",pixPerMicron,"pixels per micron");
	}
else if (mag == "20x") {
	pixPerMicron = 1.9535;
	print("20x objective; scale",pixPerMicron,"pixels per micron");
	}
else if (mag=="other" && manPixSize != 0) {
	pixPerMicron = 1/manPixSize;
	print("Manual pixel size entered; scale",pixPerMicron,"pixels per micron");
	}
else {
	showMessage("No scale selected! Please re-run the macro and provide an objective lens or scale.");
	exit;
	}
      
processFolder(input); // starts the actual processing 

setBatchMode(false); 
endTime = getTime();
elapsedTime = (endTime-startTime)/1000;
print("Finished processing",n,"images in",elapsedTime,"seconds.");

function processFolder(dir1) 
	{ // recursively goes through folders and finds images that match file suffix
	list = getFileList(dir1);
	for (i=0; i<list.length; i++) 
		{
		// print("Preparing to process",list[i]);
		if (endsWith(list[i], "/"))
			processFolder(dir1++File.separator+list[i]);
		else if (endsWith(list[i], suffix))
			processImage(dir1, list[i]);
		}
	} // end processFolder

function processImage(dir1, name) 
	{ // processes images found by processFolder
	open(dir1+File.separator+name);
	n++;
	print("Processing image", n, ":", name); // log of image number and names

	// get image name
	id = getImageID();
	origTitle = getTitle();
	
	name = File.getName(input);
	//dotIndex = indexOf(name, ".");
	//basename = substring(name, 0, dotIndex);
	basename = File.nameWithoutExtension;
	rgbName = basename+"_corrected.tif";
	
	// subtract background
	run("Subtract Background...", "rolling=300 light");
	
	// correct color
	run("BIOP SimpleColorBalance");
	
	// save RGB corrected image, keeping original scale
	saveAs ("tiff", output+File.separator+rgbName);
		
	// split colors
	selectWindow(rgbName);
	run("Colour Deconvolution", "vectors=[H DAB] hide");
	
	// save hematoxylin image -- will be used to measure total area
	selectWindow(rgbName+"-(Colour_1)");
	run("Set Scale...", "distance=1 known=&pixPerMicron pixel=1 unit=um");
	saveAs ("tiff", output+File.separator+basename+"_H.tif");

	// save DAB image -- will be used to detect antibody staining
	selectWindow(rgbName+"-(Colour_2)");
	run("Set Scale...", "distance=1 known=&pixPerMicron pixel=1 unit=um");
	saveAs ("tiff", output+File.separator+basename+"_DAB.tif");
	
	// close any images remaining open
	while (nImages > 0) { // works on any number of channels
		close();
		}
		
	} // end processImage


