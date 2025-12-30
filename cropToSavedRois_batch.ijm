//@File(label = "Input image directory", style = "directory") inputDir
//@File(label = "Input ROIset directory", style = "directory") roiDir
//@File(label = "Output directory", style = "directory") outputDir
//@String (label = "Image file suffix", value = ".nd2") fileSuffix

// cropToSavedRois_batch.ijm
// ImageJ/Fiji script to process a batch of images and corresponding ROIsets to generate one image for each ROI, with the area outside cleared

// Required input: ROIset must be a Zip file with the same base name
// Image: MyImage.tif (or .nd2, etc)
// Roiset: MyImage.zip

// Theresa Swayne, 2025
//  -------- Suggested text for acknowledgement -----------
//   "These studies used the Confocal and Specialized Microscopy Shared Resource 
//   of the Herbert Irving Comprehensive Cancer Center at Columbia University, 
//   funded in part through the NIH/NCI Cancer Center Support Grant P30CA013696."

// TO USE: Place all input images in the input image folder. 
//			ROI sets can be in the same or a different folder (but not nested in the image folder!). 
// 	Create a folder for the output files. 
//  Run the script in Fiji. 
//	Limitations -- cannot have >1 dots in the filename. 
// 		Each image must have an ROIset.

// ---- Setup ----

while (nImages>0) { // clean up open images
	selectImage(nImages);
	close();
}
print("\\Clear"); // clear Log window

roiManager("reset");

// setBatchMode(true); // faster performance but doesn't work for all functions
run("Bio-Formats Macro Extensions"); // supports native microscope files

// ---- Run ----

print("Starting");

processFolder(inputDir, roiDir, outputDir, fileSuffix);

// Clean up images and get out of batch mode

while (nImages > 0) { // clean up open images
	selectImage(nImages);
	close(); 
}
setBatchMode(false);
print("Finished");


// ---- Functions ----

function processFolder(input, roiInput, output, suffix) {

	// this function searches for files matching the criteria and sends them to the processFile function
	filenum = -1;
	print("Processing folder", input);
	// scan folder tree to find files with correct suffix
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i])) {
			processFolder(input + File.separator + list[i], output, suffix); // handles nested folders
		}
		if(endsWith(list[i], suffix)) {
			filenum = filenum + 1;
			processFile(input, roiInput, output, list[i], filenum); // passes the filename and parameters to the processFile function
		}
	}
} // end of processFolder function


function processFile(inputFolder, roiFolder, outputFolder, fileName, fileNumber) {
	
	// this function processes a single image
	
	// ---------- SETUP
	
	imagePath = inputFolder + File.separator + fileName;
	
	// open the image file
	run("Bio-Formats", "open=&imagePath");
	
	// determine the name of the file without extension
	id = getImageID();
	dotIndex = lastIndexOf(fileName, ".");
	basename = substring(fileName, 0, dotIndex); 
	extension = substring(fileName, dotIndex);

	print("Processing image",fileNumber," at path" ,imagePath, "with basename",basename);	
	
	// open the corresponding ROIset
	//filenameParsed = split(basename, "-");
	roiFile = basename + ".zip"; 
	roiPath = roiFolder + File.separator +roiFile;
	
	roiManager("reset");
	print("Opening ROI", roiPath);
	roiManager("Open", roiPath);
	
	numROIs = roiManager("count");	
	// how much to pad?
	digits = Math.ceil((log(numROIs + 1)/log(10)));
	
	
	// ---------- DOCUMENT ROI LOCATIONS
	
	// save a snapshot
	Stack.getPosition(channel, slice, frame); // how does the user currently have the stack set up
	if (is("composite")) {
		Stack.setDisplayMode("composite"); // this command raises error if image is not composite
		run("Stack to RGB", "keep");
	}
	else {
		run("Select None");
	//	run("Duplicate...", "title=copy duplicate"); // for single-channel non-RGB images; Flatten doesn't create new window
		run("Duplicate...", "title=copy"); // for single-channel non-RGB images; Flatten doesn't create new window
	}
	rgbID = getImageID();
	selectImage(rgbID);
	
	roiManager("Show All with labels");
	Stack.setPosition(channel, slice, frame); // restore the previous setup
	run("Flatten");
	flatID = getImageID();
	selectImage(flatID);
	saveAs("tiff", outputFolder+File.separator+basename+"_ROIlocs.tif");
	
	print("Saved snapshot for image",basename);
	
	// close images
	if (isOpen(flatID)) {
		selectImage(flatID);
		close();
	}
	if (isOpen(rgbID)) {
		selectImage(rgbID);
		close();
	}
	
	// ---------- CROP AND SAVE
	
	// make sure nothing is selected to begin with
	selectImage(id);
	roiManager("Deselect");
	run("Select None");
	
	for(roiIndex=0; roiIndex < numROIs; roiIndex++) // loop through ROIs
		{ 
		selectImage(id);
		roiNum = roiIndex + 1; // so that image names start with 1 like the ROI labels
		roiManager("Select", roiIndex);  // ROI indices start with 0
		// roiName = Roi.getName();
		// print("The name of ROI number",roiNum, "is",roiName);
		roiNumPad = IJ.pad(roiNum, digits);
		cropName = basename+"_roi_"+roiNumPad + ".tif";
		run("Duplicate...", "title=&cropName duplicate"); // creates the cropped stack
		selectWindow(cropName);
		
		if ((selectionType() != 0) && (selectionType() != -1)) {
			run("Clear Outside","stack"); // this works because non-rectangular rois are still active on the cropped image
			run("Select None");// clears the selection that is otherwise saved with the image (although it can be recovered with "restore selection")
		}
		saveAs("tiff", outputFolder+File.separator+cropName);
		print("Saving ROI",roiNumPad,"as",cropName);
		close();
		}
	// ---------- CLEANUP
	
	run("Select None");
	print("Saved",numROIs,"cropped ROIs.");
	selectImage(id);
	close();
	roiManager("Reset");


} // end of processFile function


	