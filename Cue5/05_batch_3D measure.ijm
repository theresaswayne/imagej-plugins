//@File(label = "Resliced image input directory", style = "directory") imageInputDir
//@File(label = "Segmented image input directory", style = "directory") binaryInputDir
//@File(label = "Output directory", style = "directory") outputDir
//@String (label = "File suffix", value = ".tif") fileSuffix

// ImageJ/Fiji script to process a batch of images
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

// see also https://mcib3d.frama.io/3d-suite-imagej/plugins/3DManager/3D-Manager-macros/

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

processFolder(imageInputDir, binaryInputDir, outputDir, fileSuffix);

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

function processFolder(imginput, bininput, output, suffix) {

	// this function searches for files matching the criteria and sends them to the processFile function
	filenum = -1;
	print("Processing folder", imginput);
	// scan folder tree to find files with correct suffix
	list = getFileList(imginput);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(imginput + File.separator + list[i])) {
			processFolder(imginput + File.separator + list[i], bininput, output, suffix); // handles nested folders
		}
		if(endsWith(list[i], suffix)) {
			filenum = filenum + 1;
			processFile(imginput, bininput, output, list[i], filenum); // passes the filename and parameters to the processFile function
		}
	}
} // end of processFolder function


function processFile(imgInputFolder, binInputFolder, outputFolder, imgFile, fileNumber) {
	
	// this function processes a single image
	
	imgPath = imgInputFolder + File.separator + imgFile;
	print("Processing file",fileNumber," at path" ,imgPath);	

	// determine the name of the file without extension
	dotIndex = lastIndexOf(imgFile, ".");
	//rawBasename = substring(imgFile, 0, dotIndex); 
	//reslIndex = indexOf(rawBasename, "_resliced");
	//basename = substring(rawBasename, 0, reslIndex);
	basename = substring(imgFile, 0, dotIndex);
	extension = substring(imgFile, dotIndex);
	
	print("File basename is",basename);
	
	// open the image file
	run("Bio-Formats", "open=&imgPath");
	
	// Duplicate the image
	dupName = basename;
	// run("Duplicate...", "title="+dupName+" duplicate channels=5");
	run("Duplicate...", "title="+dupName+" duplicate");

	// close the original
	selectWindow(imgFile);
	close();

	// check for the segmented image
	binFile = basename + "_seg.tif";
	
	// open the segmented image
	binPath = binInputFolder + File.separator + binFile;
	if (!(File.exists(binPath))) {
		print("No segmented image found for", basename);
		return; // go to next file in folder
	}
	else {
		run("Bio-Formats", "open=&binPath");
		
		// set up options with redirect
		//run("3D OC Options", "volume nb_of_obj._voxels integrated_density mean_gray_value median_gray_value maximum_gray_value centroid dots_size=5 font_size=10 store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to="+dupName);
		run("3D OC Options", "volume nb_of_obj._voxels integrated_density mean_gray_value median_gray_value maximum_gray_value centroid mean_distance_to_surface median_distance_to_surface bounding_box dots_size=5 font_size=10 store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to="+dupName);
		selectImage(binFile);
		
		// check for objects (if there are none, 3D OC will crash)
		Stack.getStatistics(area, mean, min, max, std, histogram);
		if (max == 0) {
			print("No objects in", basename);
			continue;
		}
		else {
			run("3D Objects Counter", "threshold=1 slice=10 min.=1 max.=723975 statistics");
			// save results
			statsName = "Statistics for " + binFile + " redirect to " + basename;
			selectWindow(statsName);
			saveAs("Results", outputDir + File.separator + basename + "_results.csv");
			run("Close");
		}
	}	

} // end of processFile function


	