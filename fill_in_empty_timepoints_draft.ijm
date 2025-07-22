//@File(label = "Input directory", style = "directory") inputDir
//@File(label = "Output directory", style = "directory") outputDir
//@String (label = "File suffix", value = ".nd2") fileSuffix
//@ int(label="Channel number for less frequent acquisition:", value=1, min=1, max=7, style="spinner") chan
//@ int(label="Slice interval for less frequent acquisition:")  interval

// Fill in the empty channels in a time-lapse series where one channel is captured at a longer interval

// ---- Setup ----

while (nImages>0) { // clean up open images
	selectImage(nImages);
	close();
}
print("\\Clear"); // clear Log window

setBatchMode(true); // faster performance
run("Bio-Formats Macro Extensions"); // support native microscope files



// ---- Run ----

print("Starting");

// Call the processFolder function, including the parameters collected at the beginning of the script

processFolder(inputDir, outputDir, fileSuffix, chan, interval);

// Clean up images and get out of batch mode

while (nImages > 0) { // clean up open images
	selectImage(nImages);
	close(); 
}
setBatchMode(false);
print("Finished");


// ---- Functions ----

function processFolder(input, output, suffix, ch, interv) {

	// this function searches for files matching the criteria and sends them to the processFile function
	filenum = -1;
	print("Processing folder", input);
	// scan folder tree to find files with correct suffix
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i])) {
			processFolder(input + File.separator + list[i], output, suffix); // handles nested folders
		}
		if(endsWith(list[i], suffix)) {
			filenum = filenum + 1;
			processFile(input, output, list[i], filenum, ch, interv); // passes the filename and parameters to the processFile function
		}
	}
} // end of processFolder function


function processFile(inputFolder, outputFolder, fileName, fileNumber, channel, interval) {
	
	// this function processes a single image
	
	path = inputFolder + File.separator + fileName;
	print("Processing file",fileNumber," at path" ,path);	

	// determine the name of the file without extension
	dotIndex = lastIndexOf(fileName, ".");
	basename = substring(fileName, 0, dotIndex); 
	extension = substring(fileName, dotIndex);
	
	print("Processing file at path" ,path", with basename",basename);
	
	// open the file
	run("Bio-Formats", "open=&path");

	run("Split Channels");

	// Address the desired channel only
	
	desiredChannelName = "C&channel-" + filename; 
	selectImage(desiredChannelName);
	
	// simple command options -- note that these change the content (interpolate)
	
	// keep only the slices with content 
	//run("Slice Keeper", "first=1 last=30 increment=5");
	
	// option 1 -- z interval is nominally 5 units so we divide by 5
	//run("Reslice Z", "new=1"); 
	
	// option 2 -- upscale z 5-fold
	//run("Scale...", "x=1.0 y=1.0 z=5 width=947 height=1152 depth=30 interpolation=Bilinear average process create");
	
	// better option-- what Elements does -- copy each image to the 5 (or whatever) subsequent slices
	
	
	numTimepoints = nSlices/interval;
	if (round(numTimepoints) != numTimepoints) { // check for 
		print("Slice count or interval is wrong!";
		continue;
	}

	for (timepoint = 1; timepoint <= numTimepoints; timepoint++) { // loop through 

	firstSlice = timepoint*interval - interval + 1;
	setSlice(timepoint*interval);
	//run("Select All");
	//run("Copy");
	//setSlice(2);
	//run("Paste");
	//setSlice(3);
	//run("Paste");
	
	}
	// Re-merge and save result
	
	// run("Merge Channels...", "c1=bat-cochlea-volume-1.tif c2=bat-cochlea-volume-2.tif create");
	// saveAs("Tiff", "/Users/tcs6/Downloads/scaled 20250123_HCT116_Dis3AID_Med1EGFP_Mtr4 siRNA_video_4 - Denoised.nd2 - C=1.tif kept stack-1.tif");
	

	
	// save the output
	outputName = basename + "_processed.tif";
	saveAs("tiff", outputFolder + File.separator + outputName);
	close();
	

} // end of processFile function
