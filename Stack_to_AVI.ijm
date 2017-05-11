// @File(label = "Input directory", style = "directory") input
// @File(label = "Output directory", style = "directory") output
// @String(label = "File suffix", value = ".nd2") suffix

// Stack_to_AVI.ijm
// ImageJ/Fiji macro to convert z stacks to AVI
// Theresa Swayne, tcs6@cumc.columbia.edu, 2017
// Input: a folder of z stacks
// Output: for each stack, 2 AVIs: stepthrough and rotating max projection on Y axis
// The contrast is adjusted to min-max for each channel (like pressing Reset on B/C window)
// Requires: Bio-Formats (included in Fiji)
// Usage:  
// 		1) Place all your z stacks in a folder.  
// 		2) Create another folder for output. 
//		3) Open this script in Fiji. Click the "Run" button at the bottom left of the script window. 

run("Bio-Formats Macro Extensions");
setBatchMode(true);
processFolder(input);
setBatchMode(false);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder("" + input + File.separator +  list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {

	print("Processing: " + input + File.separator + file);

	Ext.openImagePlus(input+File.separator+file) // using bio-formats extensions without dialog -- uses default options

	// get image info
	Stack.getDimensions(width, height, channels, slices, frames);
	getVoxelSize(vWidth, vHeight, vDepth, unit);
	title = getTitle();
	basename = substring(title, 0,lengthOf(title)-3);
	print(title,basename);

	// filenames for saving
	saveStepsPath = output + File.separator + basename + "_stack.avi";
	saveRotPath = output + File.separator + basename + "_rot.avi";

	// reset contrast for each channel
	for (i=0; i < channels; i++) {
		Stack.setChannel(i);
		resetMinAndMax(); // set contrast to min and max pixel values in that channel
	}

	// view all channels
	Stack.setDisplayMode("composite");

	// make stepthrough
	print("Saving stepthrough to: " + output);
	run("AVI... ", "compression=JPEG frame=5 save=&saveStepsPath");

	// make projections 
	run("3D Project...", "projection=[Brightest Point] axis=Y-Axis slice=&vDepth initial=0 total=360 rotation=10 lower=1 upper=255 opacity=0 surface=0 interior=0 interpolate");
	print("Saving rotation to: " + output);
	run("AVI... ", "compression=JPEG frame=5 save=&saveRotPath");
	close(); // projection
	close(); // original
}
