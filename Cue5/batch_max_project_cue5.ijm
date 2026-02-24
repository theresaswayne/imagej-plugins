//@File(label = "Input directory", style = "directory") inputDir
//@File(label = "Output directory", style = "directory") outputDir
//@String (label = "File suffix", value = ".tif") fileSuffix

// batch_max_project.ijm
// ImageJ/Fiji script to max project a batch of images for display
// Theresa Swayne, 2025-26

// selects ch4-5 for display and adjusts contrast

//  -------- Suggested text for acknowledgement -----------
//   "These studies used the Confocal and Specialized Microscopy Shared Resource 
//   of the Herbert Irving Comprehensive Cancer Center at Columbia University, 
//   funded in part through the NIH/NCI Cancer Center Support Grant P30CA013696."

// TO USE: Place all input images in the input folder.
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

run("Collect Garbage"); // clear memory
	
setBatchMode(true); // faster performance
run("Bio-Formats Macro Extensions"); // support native microscope files


// ---- Run ----

print("Starting");

// Call the processFolder function, including the parameters collected at the beginning of the script

processFolder(inputDir, outputDir, fileSuffix);

// Clean up images and get out of batch mode

while (nImages > 0) { // clean up open images
	selectImage(nImages);
	close(); 
}
setBatchMode(false);
print("Finished");
run("Collect Garbage"); // clear memory

// ---- Functions ----

function processFolder(input, output, suffix) {

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
			processFile(input, output, list[i], filenum); // passes the filename and parameters to the processFile function
		}
	}
} // end of processFolder function


function processFile(inputFolder, outputFolder, fileName, fileNumber) {

	// this function processes a single image
	run("Collect Garbage"); // clear memory
	run("Fresh Start"); // closes all images, clears ROIs and results to solve memory leak
	// see https://forum.image.sc/t/memory-not-clearing-over-time/2137/45 
	//   and https://forum.image.sc/t/fresh-start-macro-command-in-imagej-fiji/43102/7
	path = inputFolder + File.separator + fileName;
	print("Processing file",fileNumber," at path" ,path);	

	// determine the name of the file without extension
	dotIndex = lastIndexOf(fileName, ".");
	basename = substring(fileName, 0, dotIndex); 
	extension = substring(fileName, dotIndex);
	
	print("Processing file at path" ,path,", with basename",basename);
	
	// open the file
	run("Bio-Formats", "open=&path virtual");

	// move to the middle of the stack
	Stack.setPosition(3,11,1);

	// colorize ch4 (deconvolved Nup159) = green and ch5 (decon Erg6) = red, plus trans in grey
	// set contrast to min/max
	Stack.setDisplayMode("color");
	Stack.setChannel(3);
	run("Grays");
	resetMinAndMax;
	Stack.setChannel(4);
	run("Red");
	resetMinAndMax;
	Stack.setChannel(5);
	resetMinAndMax;
	run("Green");
	
	// show the overlay of only channels 4 and 5
	Property.set("CompositeProjection", "Sum");
	Stack.setDisplayMode("composite");
	Stack.setActiveChannels("00011");
	
	run("Z Project...", "projection=[Max Intensity]");
	
	selectWindow("MAX_"+fileName);

	// save the output
	outputName = basename + "-MaxIP.tif";
	saveAs("tiff", outputFolder + File.separator + outputName);
	close();
	run("Collect Garbage"); // clear memory

} // end of processFile function


	