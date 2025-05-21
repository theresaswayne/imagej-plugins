//@File(label = "Input directory", style = "directory") inputDir
//@File(label = "Output directory", style = "directory") outputDir
// @String (label = "File suffix", value = ".tif") fileSuffix

// ---- Setup ----

while (nImages>0) { // clean up open images
	selectImage(nImages);
	close();
}

print("\\Clear"); // clear Log window
run("Clear Results");

run("Bio-Formats Macro Extensions"); // support native microscope files
run("3D Manager Options", "volume centroid_(pix) exclude_objects_on_edges_xy distance_between_centers=10 distance_max_contact=1.80 drawing=Contour");
run("CLIJ2 Macro Extensions", "cl_device=[Intel(R) UHD Graphics 630]");


// ---- Run ----

print("Starting");
processFolder(inputDir, outputDir, fileSuffix);

while (nImages > 0) { // clean up open images
	selectImage(nImages);
	close(); 
}

print("Finished");

// ---- Functions ----

function processFolder(input, output, suffix) {
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
			processFile(input, output, list[i], filenum);
		}
	}
}


function processFile(inputFolder, outputFolder, fileName, fileNumber) {
	
	path = inputFolder + File.separator + fileName;
	print("Processing file at path" ,path);	
	
	
	run("CLIJ2 Macro Extensions", "cl_device=[Intel(R) UHD Graphics 630]");

	// parse filename
	dotIndex = indexOf(fileName, "."); // limitation -- cannot have >1 dots in the filename, filename cannot be too long
	basename = substring(fileName, 0, dotIndex); 
	extension = substring(fileName, dotIndex);
	
	//Ext.setId(path);
	print("Processing file",fileName, "with basename",basename);
	
	// keep track of how long this takes
	startTime = getTime();

	// open image
	run("Bio-Formats", "open=&path specify_range color_mode=Default view=Hyperstack c_begin=2 c_end=2 c_step=1");
	title = getTitle();
	
	// reduce size by converting to 8 bit
	
	//run("Brightness/Contrast...");
	resetMinAndMax;
	setOption("ScaleConversions", true);
	run("8-bit");

	// gaussian blur 1 pixel in xy with GPU (do not blur in z)
	image1 = title;
	Ext.CLIJ2_push(image1);
	image2 = "gaussian_blur-"+title;
	sigma_x = 1.0;
	sigma_y = 1.0;
	sigma_z = 0.0;
	Ext.CLIJ2_gaussianBlur3D(image1, image2, sigma_x, sigma_y, sigma_z);
	Ext.CLIJ2_pull(image2);
	blurName = basename + "_gaussian.tif";
	selectImage(image2);
	saveAs("Tiff", outputFolder + File.separator + blurName);
	
	// threshold using otsu method with GPU
	image3 = blurName;
	Ext.CLIJ2_push(image3);
	image4 = "otsu_"+title;
	Ext.CLIJ2_thresholdOtsu(image3, image4);
	Ext.CLIJ2_pull(image4);
	
	// convert the binary image into 0,255 and then into a label image
	selectImage(image4);
	run("Multiply...", "value=255 stack"); // omit?
	
	run("3D Manager");

	selectImage(image4); // this is the 0-255 image
	Ext.Manager3D_Segment(128, 255); // could be 1, 255?
	
	// remove objects smaller than 10 voxels
	run("3D Filter Objects", "descriptor=Volume(pix) min=10 max=1000 keep");
	
	// represent the objects as 3D ROIs
	filterName = "otsu_"+basename+"_filtered";
	selectImage(filterName);
	// selectWindow("RoiManager3D 4.1.7");
	Ext.Manager3D_AddImage;
	
	// measure
	Ext.Manager3D_DeselectAll;
	Ext.Manager3D_Measure;
	
	// save ROIs
	Ext.Manager3D_DeselectAll;
	roiName = basename + "_ROIs.zip";
	Ext.Manager3D_Save(outputFolder + File.separator + roiName);
	
	// save and clean up results
	resultName = basename + "_dead_measurements.csv";
	Ext.Manager3D_SaveResult("M",outputFolder + File.separator + resultName);
	Ext.Manager3D_CloseResult("M");
 
	// clear 3D ROIs
	Ext.Manager3D_Reset();
	
	// clean up images
	while (nImages>0) { // clean up open images
		selectImage(nImages);
		close();
	}
	
	print("Elapsed time " + (getTime() - startTime) + " msec");
	
} // end of process file function