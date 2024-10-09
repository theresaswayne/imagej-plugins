// @File(label = "Input folder:", style = "directory") inputDir
// @File(label = "Output folder:", style = "directory") outputDir
// @String (label = "File suffix", value = ".nd2") fileSuffix
// @int(label= "Channel to analyze", style = "spinner", val = 1) channelNum


//analyze_protrusions.ijm
// Theresa Swayne for Xu Zhang, 2024
// identifies processes in 2d fluorescence images and determines length and other parameters


// TO USE: Run the macro and specify folders for input and output.
// If images are multichannel, select the channel to use for analysis.


// ---- Setup ----
print("\\Clear"); // clears Log window
roiManager("reset");
run("Clear Results");
setOption("ScaleConversions", true); // ensures good pixel value?
run("Set Measurements...", "area centroid shape feret's display redirect=None decimal=3");

setBatchMode(true);
run("Bio-Formats Macro Extensions"); // support native microscope files

// ---- Run ----
processFolder(inputDir, outputDir, fileSuffix, channelNum);
print("Finished");

// ---- Functions ----

function processFolder(input, output, suffix, channel) {
	// function to scan folder tree to find files with correct suffix
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i], output, suffix, channel);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i], channel);
	}
}

function processFile(input, output, file, channel) {

	// function to process a single image
	
	print("Processing channel " +  channel + " of " + input + File.separator + file);
	
	path = input + File.separator + file;

	
	// ---- Open image and get information ----
	run("Bio-Formats", "open=&path");
	id = getImageID();
	title = getTitle();
	dotIndex = indexOf(title, ".");
	basename = substring(title, 0, dotIndex);
	extension = substring(title, dotIndex);
	getDimensions(width, height, channels, slices, frames);
	print("Processing",title, "with basename",basename);
	
	// ---- Prepare images ----
	if (channels > 1) {
	
		run("Split Channels");
		img = "C"+channel+"-"+title;
		
	}
	
	else {
		img = title;
	}	
	
//	run("8-bit"); // enables local threshold works?
//	
//	// ---- Segmentation ----
//	
//	// apply a local threshold to identify cells and processes
//	run("Auto Local Threshold", "method=Phansalkar radius=15 parameter_1=0 parameter_2=0 white");
//	
//	// apply a filter to enhance tube-like structures
//	run("Frangi Vesselness", "input=[1.nd2 - C=1] dogauss=true spacingstring=[1, 1] scalestring=1,2");
//	
//	// apply a global threshold to preserve the most tube-like structures
//	setAutoThreshold("Percentile dark");
//	setOption("BlackBackground", false);
//	run("Convert to Mask");
//	
//	// identify particles for purposes of filtering
//		
//	run("Analyze Particles...", "size=150-Infinity circularity=0.00-0.50 show=[Count Masks] display clear summarize add");
//	
//	selectImage("Count Masks of 1 2 percentile.tif");
//	run("Skeletonize (2D/3D)");
//	
//	
//	run("Analyze Particles...", "size=150-Infinity circularity=0.00-0.50 show=Masks display clear summarize add");
//	
//	run("Skeletonize (2D/3D)");
//	
//	run("Analyze Skeleton (2D/3D)", "prune=none show display");
//	
//	saveAs("Results", "/Users/theresaswayne/Desktop/Xu Zhang protrusions/Branch information.csv");
//	
//	selectWindow("Results");
//	selectWindow("Summary");
//	selectWindow("Branch information.csv");
//	
//	selectImage("Tagged skeleton");
//	setAutoThreshold("Percentile dark");
//	
//	selectImage("Mask of 1 2 percentile.tif");
//	run("Fill Holes");
//	
//	run("Skeletonize (2D/3D)");
//	run("Analyze Skeleton (2D/3D)", "prune=none show display");
//	selectImage("Maskof12percentilefhskel2d3d-labeled-skeletons");
//	saveAs("Results", "/Users/theresaswayne/Desktop/Xu Zhang protrusions/Branch information fh.csv");
//	selectImage("Tagged skeleton");
//	
	// ---- Save results ---- 
	

	saveName = basename+"_output.tif";
	selectImage(img);
	saveAs("tiff", output + File.separator + saveName);
	print("Saving "+saveName+"to: " + output);

	// clean up open images
	while (nImages>0) {
	selectImage(nImages);
	close();
	}
}

