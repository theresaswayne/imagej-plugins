// @File(label = "Input folder", style = "directory") input
// @File(label = "Output folder", style = "directory") output
// @File(label="Saved ROI", description="Select the ROI file") roifile
// @String(label = "Input file suffix", value = ".nd2") suffix

// setup
roiManager("reset");
run("Bio-Formats Macro Extensions"); // required to open ND2 files

// open ROI
roiManager("Open", roifile);

setBatchMode("true");
// process images
processFolder(input);

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
			processFile(input, output, list[i]);
		}
	}
}

function processFile(input, output, file) {
	// process each file

	path = input + File.separator + file;
	// open(input + File.separator + file); // works for native IJ files
	run("Bio-Formats", "open=path color_mode=Default view=Hyperstack stack_order=XYCZT");
	// run("Bio-Formats", "open=path autoscale color_mode=Default view=Hyperstack stack_order=XYCZT");
	title = getTitle();
	dotIndex = indexOf(title, ".");
	basename = substring(title, 0, dotIndex);
	
	// select ROI
	roiManager("Select", 0);
	run("Crop");
	
	saveAs("Tiff",  output + File.separator + basename+"_crop.tif");
	close();
	print("Processing: " + input + file);
	print("Saving to: " + output);
}


