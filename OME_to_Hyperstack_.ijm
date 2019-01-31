//@ File (label = "Input directory", style = "directory") inputDir
//@ File (label = "Output directory", style = "directory") outputDir
//@ String (label = "File suffix", value = ".tif") suffix
//@Integer(label = "Z slices (Choose 0 if variable)", value = 1) z
//@Integer(label = "Channels (Choose 0 if variable)", value = 1) c
//@Integer(label = "Timepoints (Choose 0 if variable)", value = 1) t



// DO NOT MOVE OR DELETE THE FIRST FEW LINES! They supply essential parameters.


// OME_to_Hyperstack_.ijm
// ImageJ macro by Theresa Swayne, Columbia University, 2019
// converts batch of OME tiffs from Volocity into hyperstacks
// assumes zct order
// for n dimensions, if n-1 dimensions are constant, one can be variable (e.g. variable time or z)



// Check if enough numbers are supplied -- if not, throw an error

calc_dim = "";

if (z*c*t == 0) { // if any is 0
	if (z == 0) calc_dim = "z";
	if (c == 0) calc_dim = "c";
	if (t == 0) calc_dim = "t";
	
	if ((z == 0 && c == 0) || (z == 0 && t == 0) || (c == 0 && t == 0)) {
		exit("You must specify all but one dimension.\nCheck input parameters.");
	}
	else print("We are guessing the",calc_dim," dimension");
}

processFolder(inputDir, z, c, t, calc_dim);


function processFolder(input, z, c, t, calc_dim) {
	// scan folders/subfolders/files to find files with correct suffix
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(inputDir, outputDir, list[i], z, c, t, calc_dim);
	}
}

function processFile(input, output, file, z, c, t, calc_dim) {
	// carry out processing tasks

	print("Processing: " + input + File.separator + file);
	open(input + File.separator + file);

	id = getImageID();
	title = getTitle();
	dotIndex = indexOf(title, "."); // first dot
	basename = substring(title, 0, dotIndex);
	
	getDimensions(width, height, channels, slices, frames);
	actual_slices = channels * slices * frames;
	
	// Calculate any missing dimensions
	// Check if calculation is correct

	if (calc_dim == "z") {
		z = actual_slices/(c * t);
		print("We calculate that",basename,"has",z,"slices.");
		if (z != floor(z)) {
			exit("Dimensions are incorrect for ",basename,".\nCheck input parameters.");
		}
	}

	if (calc_dim == "c") {
		c = actual_slices/(z * t);
		print("We calculate that",basename,"has",c,"channels.");
		if (c != floor(c)) {
			exit("Dimensions are incorrect for ",basename,".\nCheck input parameters.");
		}
	}

	if (calc_dim == "t") {
		t = actual_slices/(z * c);
		print("We calculate that",basename,"has",t,"frames.");
		if (t != floor(t)) {
			exit("Dimensions are incorrect for ",basename,".\nCheck input parameters.");
		}
	}
	print(basename,"has",c,"channels,",z,"slices, and",t,"frames.");
	run("Stack to Hyperstack...", "order=xyzct channels="+c+" slices="+z+" frames="+t+" display=Grayscale");
	saveAs("tiff", output + File.separator + basename + "_hs.tif");	
	
	while (nImages > 0) { // works on any number of channels
		close();
	}
}


