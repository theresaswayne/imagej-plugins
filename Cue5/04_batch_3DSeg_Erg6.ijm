//@File(label = "Input directory", style = "directory") inputDir
//@File(label = "Output directory", style = "directory") outputDir
//@String (label = "File suffix", value = ".tif") fileSuffix
//@ int(label="Local difference (higher is less stringent):", value = 700)  localDiff

// batch_3DSeg.ijm
// ImageJ/Fiji script to process a batch of images
// Applies 3D spot thresholding using 3D Suite 
// Saves the 3D mask
// Theresa Swayne, 2025
//  -------- Suggested text for acknowledgement -----------
//   "These studies used the Confocal and Specialized Microscopy Shared Resource 
//   of the Herbert Irving Comprehensive Cancer Center at Columbia University, 
//   funded in part through the NIH/NCI Cancer Center Support Grant P30CA013696."

// TO USE: Place all input images (single-channel resliced images) in the input folder.
// 	Create a folder for the output files. 
// 	Place your desired processing steps in the processFile function.
// 	Collect any desired parameters in the script parameters at the top. 
//		See ImageJ wiki for more script parameter options.
//		Remember to pass your parameters into the processFolder and processFile functions!
//  Run the script in Fiji. 
//	Limitation -- cannot have >1 dots in the filename
// 	

// ---- Setup ----

while (nImages>0) { // clean up open images
	selectImage(nImages);
	close();
}
print("\\Clear"); // clear Log window

//setBatchMode(true); // faster performance
run("Bio-Formats Macro Extensions"); // support native microscope files


// ---- Run ----

print("Starting");

// Call the processFolder function, including the parameters collected at the beginning of the script

processFolder(inputDir, outputDir, fileSuffix, localDiff);

// Clean up images and get out of batch mode

while (nImages > 0) { // clean up open images
	selectImage(nImages);
	close(); 
}
setBatchMode(false);
print("Finished");

// save Log
selectWindow("Log");
saveAs("text", outputDir + File.separator + "Log.txt");

// ---- Functions ----

function processFolder(input, output, suffix, locdiff) {

	// this function searches for files matching the criteria and sends them to the processFile function
	filenum = -1;
	print("Processing folder", input, "with local difference",locdiff);
	
	// scan folder tree to find files with correct suffix
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i])) {
			processFolder(input + File.separator + list[i], output, suffix); // handles nested folders
		}
		if(endsWith(list[i], suffix)) {
			filenum = filenum + 1;
			processFile(input, output, list[i], filenum, locdiff); // passes the filename and parameters to the processFile function
		}
	}
} // end of processFolder function


function processFile(inputFolder, outputFolder, fileName, fileNumber, localDiff) {
	
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
	
	// rename generically
	rename("orig");

	// generate seeds by finding local maxima
	run("3D Maxima Finder", "minimmum=400 radiusxy=3 radiusz=2 noise=250");

	
	// find spots using the seeds
	run("3D Spot Segmentation", "seeds_threshold=0 local_background=0 local_diff="+localDiff+" radius_0=0 radius_1=0 radius_2=0 weigth=0 radius_max=0 sd_value=0 local_threshold=Diff seg_spot=Classical watershed volume_min=20 volume_max=1200 seeds=peaks_orig spots=orig radius_for_seeds=2 output=[Label Image] verbose");
	
	// save the output, if any
	if (isOpen("Index")) {
		selectWindow("Index");
		outputName = basename + "_seg.tif";
		saveAs("tiff", outputFolder + File.separator + outputName);
	
		selectWindow("peaks_orig");
		seedsName = basename + "_seeds.tif";
		saveAs("Tiff",  outputFolder + File.separator + seedsName);
		
		// report completion of this image
		print("Segmented image " + basename + " in " + (getTime() - time) + " msec");
	}
	else {
		print("Image " + basename + " did not contain any detected objects.");
	}
	
	// clean up
	while (nImages > 0) { // clean up open images
		selectImage(nImages);
		close(); 
	}
	

} // end of processFile function


	