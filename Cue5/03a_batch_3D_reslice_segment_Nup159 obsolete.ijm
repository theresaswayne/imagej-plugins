//@File(label = "Input directory", style = "directory") inputDir
//@File(label = "Output resliced image directory", style = "directory") outputImgDir
//@File(label = "Output segmentation directory", style = "directory") outputSegDir
//@String (label = "File suffix", value = ".tif") fileSuffix
//@int(label="Min threshold:")  minThresh
//@Double (label = "Reslice Z step size (raw data= 0.3)", value = 0.06, stepSize=0.01) reslice

// batch_3D_reslice_segment.ijm
// ImageJ/Fiji script to process a batch of images
// Reslices Z at a spacing specified by the user, for creating isotropic stacks
// Performs 3D segmentation using 3D iterative thresholding
// Saves the resliced image and the 3D mask
// Theresa Swayne, 2025
//  -------- Suggested text for acknowledgement -----------
//   "These studies used the Confocal and Specialized Microscopy Shared Resource 
//   of the Herbert Irving Comprehensive Cancer Center at Columbia University, 
//   funded in part through the NIH/NCI Cancer Center Support Grant P30CA013696."

// TO USE: Place all input images in the input folder.
// 	Create a folder for the output files. 
//  Run the script in Fiji. 
//	Limitation -- cannot have >1 dots in the filename
// 	

// ---- Setup ----

while (nImages>0) { // clean up open images
	selectImage(nImages);
	close();
}
print("\\Clear"); // clear Log window

setBatchMode(true); // faster performance
run("Bio-Formats Macro Extensions"); // support native microscope files


// ---- Run ----

print("Starting");

// Call the processFolder function, including the parameters collected at the beginning of the script

processFolder(inputDir, outputImgDir, outputSegDir, fileSuffix, minThresh, reslice);

// Clean up images and get out of batch mode

while (nImages > 0) { // clean up open images
	selectImage(nImages);
	close(); 
}
setBatchMode(false);
print("Finished");

// save Log
selectWindow("Log");
saveAs("text", outputSegDir + File.separator + "Log.txt");

// ---- Functions ----

function processFolder(input, outputimg, outputseg, suffix, minthresh, reslice) {

	// this function searches for files matching the criteria and sends them to the processFile function
	filenum = -1;
	print("Processing folder", input, "with minimum threshold",minthresh);
	
	// scan folder tree to find files with correct suffix
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i])) {
			processFolder(input + File.separator + list[i], outputimg, outputseg, suffix, reslice); // handles nested folders
		}
		if(endsWith(list[i], suffix)) {
			filenum = filenum + 1;
			processFile(input, outputimg, outputseg, list[i], filenum, minthresh, reslice); // passes the filename and parameters to the processFile function
		}
	}
} // end of processFolder function


function processFile(inputFolder, outputImgFolder, outputSegFolder, fileName, fileNumber, minThreshold, reslice) {
	
	// this function processes a single image
	
	path = inputFolder + File.separator + fileName;
	print("Processing file",fileNumber," at path" ,path);	

	// determine the name of the file without extension
	dotIndex = lastIndexOf(fileName, ".");
	basename = substring(fileName, 0, dotIndex); 
	extension = substring(fileName, dotIndex);
	
	print("File basename is",basename);
	time = getTime();
	
	// open the file
	run("Bio-Formats", "open=&path");
	
	// Look at only channel 5
	dupName = basename + "-c5";
	run("Duplicate...", "title="+dupName+" duplicate channels=5");
	
	// reslice to make isotropic
	// TODO: Make reslice a boolean and take the step size from the xy size
	run("Reslice Z", "new="+reslice);

	selectWindow("Resliced");
	run("3D Iterative Thresholding", "min_vol_pix=4 max_vol_pix=2000 min_threshold="+minThreshold+" min_contrast=0 criteria_method=MSER threshold_method=STEP segment_results=Best value_method=1");
	
	// save the output, if any
	if (isOpen("Objects")) {
		selectWindow("Objects");
		outputName = basename + "_seg.tif";
		saveAs("tiff", outputSegFolder + File.separator + outputName);
	
		// report completion of this image
		print("Segmented image " + basename + " in " + (getTime() - time) + " msec");
	}
	else {
		print("Image " + basename + " did not contain any detected objects.");
	}
	
	// save the resliced image for intensity quantification
	selectWindow("Resliced");
	outputName = basename + "_resliced.tif";
	saveAs("tiff", outputImgFolder + File.separator + outputName);
	
	// clean up
	while (nImages > 0) { // clean up open images
		selectImage(nImages);
		close(); 
	}
	

} // end of processFile function


	