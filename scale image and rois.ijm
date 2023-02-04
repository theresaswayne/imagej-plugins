//@ File(label = "Image folder:", style = "directory") imageDir
//@ File(label = "ROIs folder:", style = "directory") roiDir
//@ File(label = "Output folder:", style = "directory") outputDir
// @String(label = "Input image suffix", value = ".tif") suffix

// scale image and rois.ijm
// opens each of a folder of images and a corresponding set of ROIs.
// bins 2x2 and scales down ROIs, and saves results.

// note -- do  not nest the image, ROI, or output folders.
// note -- if an roi file is missing, the macro will quit
// TODO: skip file and alert user if the roi is not found

// setup
roiManager("reset");
run("Bio-Formats Macro Extensions"); // required to open ND2 files
setBatchMode("true");

// process images
processFolder(imageDir);

// clean up
setBatchMode("false");

function processFolder(input) {
// scan folders/subfolders/files to find files with correct suffix

	list = getFileList(input);
	list = Array.sort(list);
	for (i=0; i < list.length; i++) {
		if (File.isDirectory(input + File.separator + list[i])) {
			processFolder(input + File.separator +  list[i]);
		}
		if (endsWith(list[i], suffix)) {
			processFile(input, roiDir, outputDir, list[i]);
		}
	}
}

function processFile(input, roi, output, file) {
	// process each file

	imagepath = input + File.separator + file;
	// open(input + File.separator + file); // works for native IJ files
	run("Bio-Formats", "open=imagepath color_mode=Default view=Hyperstack stack_order=XYCZT");
	title = getTitle();
	dotIndex = indexOf(title, ".");
	basename = substring(title, 0, dotIndex);
	
	// open ROI file
	roiManager("reset");
	roiname = basename + "_ROIs.zip";
	roipath = roi + File.separator + roiname;
	roiManager("open", roipath);
	
	// sum adjacent pixels
	selectWindow(title);
	binname = basename + "_bin";
	run("Duplicate...", "title=&binname duplicate");
	selectWindow(binname);
	run("32-bit");
	run("Bin...", "x=2 y=2 z=1 bin=Sum");
	
	// select all ROIs and scale them
	numROIs = roiManager("count");
	roiManager("deselect"); // select all
	RoiManager.scale(0.5, 0.5, false); // 'Centered' box is unchecked
	
	// save image and ROIs
	selectWindow(binname);
	run("Remove Overlay");
	saveAs("Tiff",  output + File.separator + binname + ".tif");
	roiManager("deselect");
	roiManager("save", output  + File.separator + basename + "_scaledROIs.zip");
	close("*"); // all image windows
	print("Processing: " + input + file);
	print("Saving to: " + output);
}



