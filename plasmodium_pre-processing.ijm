//@File(label = "Input directory", style = "directory") inputDir
//@File(label = "Output directory", style = "directory") outputDir
//@String (label = "File suffix", value = ".nd2") fileSuffix
//@File(label = "Weka classifier", style = "file") classifier

// plasmodium_pre-processing.ijm
// ImageJ/Fiji script to batch process plasmodium images:
//	  extract a single slice from a multichannel z-stack, 
//    detect the RBC area using a Weka model, 
//    and perform binary processing on the classified image
//    Output is a binary mask that can be used in a CellProfiler pipeline  
// by Theresa Swayne for Kharizta Wiradiputri, David Fidock's lab, 2025
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

//setBatchMode(true); // faster performance
run("Bio-Formats Macro Extensions"); // support native microscope files


// ---- Run ----

print("Starting");

// Call the processFolder function, including the parameters collected at the beginning of the script

processFolder(inputDir, outputDir, fileSuffix, classifier);

// Clean up images and get out of batch mode

while (nImages > 0) { // clean up open images
	selectImage(nImages);
	close(); 
}
setBatchMode(false);
print("Finished");


// ---- Functions ----

function processFolder(input, output, suffix, classifier) {

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
			processFile(input, output, list[i], filenum, classifier); // passes the filename and parameters to the processFile function
		}
	}
} // end of processFolder function


function processFile(inputFolder, outputFolder, fileName, fileNumber, classifier) {
	
	// this function processes a single image
	
	path = inputFolder + File.separator + fileName;
	print("Processing file",fileNumber," at path" ,path);	

	// determine the name of the file without extension
	dotIndex = lastIndexOf(fileName, ".");
	basename = substring(fileName, 0, dotIndex); 
	extension = substring(fileName, dotIndex);
	
	print("Processing file at path" ,path, ", with basename",basename);
	
	// open the file
	run("Bio-Formats", "open=&path");

	// select slice 8 in the phase channel
	Stack.setPosition(3,8,1);
	sliceName = basename+"-phase_z8.tif";
	run("Duplicate...", "title="+sliceName);

	selectImage(sliceName);
	
	// run trainable weka pre-trained model

	run("Trainable Weka Segmentation");

	// wait for the plugin to load
	wait(3000);
	selectWindow("Trainable Weka Segmentation v4.0.0");
	call("trainableSegmentation.Weka_Segmentation.loadClassifier", classifier);
	call("trainableSegmentation.Weka_Segmentation.getResult");
	wait(3000);
	
	selectWindow("Classified image");
	setThreshold(1, 255, "raw");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Fill Holes");
	run("Options...", "iterations=1 count=1 black do=Open");
	run("Watershed");
	
	// save the output
	outputName = basename + "_classified.tif";
	saveAs("tiff", outputFolder + File.separator + outputName);
	close();
	
	selectWindow("Trainable Weka Segmentation v4.0.0");
	close();
		
} // end of processFile function


