// @File(label = "Input directory", style = "directory") input
// @File(label = "Output directory", style = "directory") output
// @String(label = "File suffix", value = ".tif") suffix


// batch analysis of label images 
// for a folder of label images produced by the Trainable Weka Segmentation plugin:
// -- thresholds the desired class
// -- analyzes particles
// -- saves ROI

THRESHOLD_METHOD = "default";
WEKA_CLASS = 2;
MIN_SIZE = 0;
MAX_SIZE = 10000000;

run("Set Measurements...", "area centroid display redirect=None decimal=3");

run("Input/Output...", "file=.csv save_column"); // saves data as csv, preserves headers, doesn't save row number 


// set up data file
//headers = "filename, data";
//File.append(headers,output  + File.separator+ "Particle_Results.csv");


// process images
processFolder(input);

// save data
selectWindow("Summary");
saveAs("Results", output + File.separator+"Particle_Results.csv");

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

	roiManager("reset");
	run("Select None");
	setThreshold(0.5000, 1.5000);
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Despeckle"); // get rid of stray particles

	// set scale on image
	run("Set Scale...", "distance=1 known=2.5595 pixel=1 unit=um");
	
	run("Analyze Particles...", "size=" + MIN_SIZE + "-" + MAX_SIZE +" summarize add");

	if(roiManager("count") != 0)
		roiManager("Save", output + File.separator + roiName); // saved in the output folder

	close();

//	print("Processing: " + input + file);
//	print("Saving to: " + output);
}

