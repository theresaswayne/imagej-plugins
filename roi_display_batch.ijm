// @File(label = "Image input directory", style = "directory") input
// @File(label = "ROI input directory", style = "directory") rois
// @File(label = "Output directory", style = "directory") output
// @String(label = "File suffix", value = ".tif") suffix

// roi_display_batch.ijm
// Theresa Swayne, Columbia University, 2017
// IJ1 macro that loads a previously saved ROIset and flattens it on a similarly named image, optionally using a multi-hue LUT to show variable cell intensity
// input: single-channel image, and a saved ROIset with appropriate filename in same directory 
// usage: open the image then run the macro. 


// process images
processFolder(input);

function processFolder(input) {
// scan folders/subfolders/files to find files with correct suffix

	list = getFileList(input);
	list = Array.sort(list);
	for (i=0; i < list.length; i++) {
		if(File.isDirectory(input + list[i]))
			processFolder("" + input + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
// process each file

	open(input+File.separator+file);
	
	id = getImageID();
	title = getTitle();
	dotIndex = indexOf(title, ".");
	basename = substring(title, 0, dotIndex);
	roiName = basename + "_ROIs.zip";
	overlayName = basename + "_overlay.tif";

	run("Select None");
	run("Remove Overlay");
	//run("16 colors"); // optional colorization

	roiManager("reset");
	if(File.exists(rois+File.separator+roiName)) {
		roiManager("Open",rois+File.separator+roiName);
		roiManager("Show All without labels");
		run("Flatten");
		roiManager("Show None");
		roiManager("reset");
		selectWindow(basename+"-1.tif");
		saveAs("tiff", output + File.separator + overlayName);
		close(); // overlay
	}

	close(); // original

//	print("Processing: " + input + file);
//	print("Saving to: " + output);
}
