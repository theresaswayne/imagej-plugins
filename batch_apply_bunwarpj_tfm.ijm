//@File(label = "Input directory", style = "directory") inputDir
//@File(label = "Output directory", style = "directory") outputDir
//@String (label = "File suffix", value = ".nd2") fileSuffix
//@File(label = "Transformation file", style = "file") tfmFile

// batch_apply_bunwarpj_tfm.ijm
// ImageJ/Fiji script to apply a transformation to a folder of images
// Theresa Swayne, 2025
// 

// TO USE: Place all input images in the input folder. Must be single-channel!
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

print("Starting processing with transformation file", tfmFile);
processFolder(inputDir, outputDir, fileSuffix, tfmFile);
while (nImages > 0) { // clean up open images
	selectImage(nImages);
	close(); 
}
setBatchMode(false);
print("Finished");


// ---- Functions ----

function processFolder(input, output, suffix, transform) {
	filenum = -1;
	print("Processing folder", input);
	// scan folder tree to find files with correct suffix
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i])) {
			processFolder(input + File.separator + list[i], output, suffix);
		}
		if(endsWith(list[i], suffix)) {
			filenum = filenum + 1;
			processFile(input, output, list[i], filenum, transform);
		}
	}
}


function processFile(inputFolder, outputFolder, fileName, fileNumber, transform) {
	
	path = inputFolder + File.separator + fileName;

	// determine the name of the file without extension
	dotIndex = indexOf(fileName, "."); // limitation -- cannot have >1 dots in the filename
	basename = substring(fileName, 0, dotIndex); 
	extension = substring(fileName, dotIndex);
	
	print("Processing file", fileNumber, "at path" ,path, ", with basename", basename);
	
	outputName = basename + "_registered.tif";
	outputPath = outputFolder + File.separator + outputName;
	
	// open the file
	// run("Bio-Formats", "open=&path");

	call( "bunwarpj.bUnwarpJ_.elasticTransformImageMacro",path, path, transform, outputPath);

		
	// save the output
	//outputName = basename + "_processed.tif";
	//saveAs("tiff", outputFolder + File.separator + outputName);
	//close();

} // end of processFile function


	