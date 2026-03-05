//@ int(label="Upper left X:") xStart
//@ int(label="Upper left Y:") yStart
//@ int(label="Size in X:") xSize
//@ int(label="Size in Y:") ySize
//@File(label = "Input file", style = "file") inputFile
//@File(label = "Output directory", style = "directory") outputDir

// save_single_tile_low_memory.ijm
// ImageJ/Fiji script to open a piece of a file for easier processing
// Does not require the entire image to be loaded into memory
// Theresa Swayne, 2026
// 

// TO USE: Create a folder for the output file. 
// 	Run the script in Fiji. 
//	Enter the desired parameters (you can get these by Analyze > Set measurements > Bounding Box)
//  Limitation -- cannot have >1 dots in the filename
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
run("Fresh Start");
processFile(inputFile, outputDir, xStart, yStart, xSize, ySize);
while (nImages > 0) { // clean up open images
	selectImage(nImages);
	close(); 
}
setBatchMode(false);
print("Finished");


function processFile(inputFile, outputFolder, xStart, yStart, xSize, ySize) {
	
	path = inputFile;
	print("Processing file at path" ,path);	

	dotIndex = indexOf(inputFile, "."); // limitation -- cannot have >1 dots in the filename
	basename = substring(inputFile, 0, dotIndex); 
	extension = substring(inputFile, dotIndex);
	
	// ---- Open image metadata only to get information ----
	Ext.setId(path);
	//run("Bio-Formats", "open=&path display_metadata view=[Metadata only] stack_order=Default");
	//title = getTitle();
	
	//getDimensions(width, height, channels, slices, frames);
	Ext.getSizeX(width);
	Ext.getSizeY(height);
	
	print("Processing file",inputFile, "with basename",basename);
	
	// open the region with crop on import makeRectangle(x+i*selectedSize, y+j*selectedSize, selectedSize,selectedSize);
	print("Creating tile at",xStart,",",yStart);
	run("Bio-Formats", "open=&path crop x_coordinate_1=&xStart y_coordinate_1=&yStart width_1=&xSize height_1=&ySize");
	// save the region -- basename_count_padded to 4 digits.tif
	tileName = basename + "_crop";
	saveAs("tiff", outputFolder + File.separator + tileName);
	close();

} // process file


	