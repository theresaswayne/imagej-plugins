#@ File (label = "Select folder 1 - DAPI IN", style = "directory") input
#@ File (label = "Select folder 2 - DAPI OUT ", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix

setBatchMode(true);
processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {

	open(input + File.separator + file);
	setAutoThreshold("Default dark");
	//run("Threshold…");
	setThreshold(80, 254);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Analyze Particles...", "size=200-1700 circularity=0.35-1.00 show=Masks exclude clear in_situ");
	run("Fill Holes");
	saveAs("Tiff", output + File.separator + file);
	print("Processing: " + input + File.separator + file);
	print("Saving to: " + output);

}
