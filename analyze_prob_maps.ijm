// @File(label = "Input directory", style = "directory") input
// @File(label = "Output directory", style = "directory") output

// batch analysis of probability maps
// for a folder of probability map stacks produced by the Trainable Weka Segmentation plugin:
// -- thresholds the desired class
// -- analyzes particles
// -- saves ROI

THRESHOLD_METHOD = "default";
WEKA_CLASS = 2;
MIN_SIZE = 0;
MAX_SIZE = 10000;


run("Input/Output...", "file=.csv save_column"); // saves data as csv, preserves headers, doesn't save row number 


// set up data file
headers = "filename, genotype, initials, experiment, stainNum, fixed, cell number, XPos, YPos, age";
File.append(headers,output  + File.separator+ "Particle_Results.csv");


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

	open(input+File.separator+name);
	
	id = getImageID();
	title = getTitle();
	dotIndex = indexOf(title, ".");
	basename = substring(title, 0, dotIndex);
	roiName = basename + "_ROIs.zip";

	setSlice(2);
	
	setAutoThreshold("Default dark");
	setOption("BlackBackground", true);
	run("Convert to Mask", "method=Default background=Dark black");
	run("Despeckle"); // get rid of any stray particles
	
	roiManager("reset");
	run("Analyze Particles...", "size=" + MIN_SIZE + "-" + MAX_SIZE + " exclude clear add");
	roiManager("Save", output + ); // saved in the output folder

	File.append(imageInfoString,output  + File.separator+ dataName);

	print("Processing: " + input + file);
	print("Saving to: " + output);
}

