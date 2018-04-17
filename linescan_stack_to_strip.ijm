//@ File (label = "Input directory", style = "directory") input
//@ File (label = "Output directory", style = "directory") output
//@ String (label = "File suffix", value = ".nd2") suffix
//@ String (label = "Time axis on output", choices={"Top to bottom", "Left to right"}, style="listBox") orientation

// linescan_stack_to_strip.ijm
// ImageJ macro by Theresa Swayne, 2018
// Input: A folder of Linescan images each collected by NIS Elements as a stack of frames, 
//		with time running from top to bottom
// Output: For each dataset, a single TIFF image containing the whole time course, oriented as chosen by the user 
// Requires Bio-Formats (built into Fiji)


run("Bio-Formats Macro Extensions"); // allows use of ND2 files
setBatchMode(true); // about 50% faster
// startTime = getTime(); // for testing

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
	path = input + File.separator + file;
	// print("Processing: " + path);
    run("Bio-Formats", "open=path autoscale color_mode=Default view=Hyperstack stack_order=XYCZT");
    basename=File.nameWithoutExtension;
	montageName = basename + "_montage.tif";
	
	// get number of slices
	getDimensions(width, height, channels, slices, frames);

	// if not, skip and give dialog 
	if (frames == 1) {
		showMessage("Time series required","Skipping "+file);
		close();
		return;
	}
	
	// arrange montage according to desired orientation
	if (orientation == "Top to bottom") {
		run("Make Montage...", "columns=1 rows=&frames scale=1"); }
	else { 	// left to right
		run("Rotate 90 Degrees Left"); // put time 0 on the left
		run("Make Montage...", "columns=&frames rows=1 scale=1");
		}

	// save and close
	// print("Saving to: " + output);
	saveAs("tiff", output + File.separator + montageName);
	close();
	selectWindow(file);
	close();
}
// endTime = getTime(); // for testing
// print("Processed in", endTime-startTime, "ms");
setBatchMode(false);
print("Finished.")


