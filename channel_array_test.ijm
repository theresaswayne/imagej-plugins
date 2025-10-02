//@File(label = "Input directory", style = "directory") inputDir
//@File(label = "Output directory", style = "directory") outputDir
//@String (label = "File suffix", value = ".nd2") fileSuffix
//@Boolean(label="Channels to save: Channel 1") C1
//@Boolean(label="Channel 2") C2
//@Boolean(label="Channel 3") C3
//@Boolean(label="Channel 4") C4
//@Boolean(label="Channel 5") C5
//@Boolean(label="Channel 6") C6
//@Boolean(label="Channel 7") C7

// channel_array_test.ijm
// Theresa Swayne, 2025
//  -------- Suggested text for acknowledgement -----------
//   "These studies used the Confocal and Specialized Microscopy Shared Resource 
//   of the Herbert Irving Comprehensive Cancer Center at Columbia University, 
//   funded in part through the NIH/NCI Cancer Center Support Grant P30CA013696."

//	Limitation -- cannot have >1 dots in the filename
// 	

// ---- Setup ----

while (nImages>0) { // clean up open images
	selectImage(nImages);
	close();
}
print("\\Clear"); // clear Log window

//setBatchMode(true); // faster performance
run("Bio-Formats Macro Extensions"); // support native microscope files

// set up which channels will be used
channelList = newArray(7);
print("Original array");
Array.print(channelList);

//channelList = [C1, C2, C3, C4, C5, C6, C7];
channelList[0] = C1;
channelList[1] = C2;
channelList[2] = C3;
channelList[3] = C4;
channelList[4] = C5;
channelList[5] = C6;
channelList[6] = C7;
print("Populated array");
Array.print(channelList);


// assemble channel range
// find the start, end, and step
//Array.getStatistics(channelList, min, max, mean, std);

selectedChannels = newArray(); 

for (i = 0; i < 7; i++) {

	if (channelList[i] == 1) {
		chan = i+1;
		selectedChannels = Array.concat(selectedChannels, chan);
		}
	}

print("Selected channels");
Array.print(selectedChannels);

// find the start and end channel
Array.getStatistics(selectedChannels, start, end, mean, stdDev);


// ---- Run ----

print("Starting");

// Call the processFolder function, including the parameters collected at the beginning of the script

//processFolder(inputDir, outputDir, fileSuffix, numericalParameter);

// Clean up images and get out of batch mode

while (nImages > 0) { // clean up open images
	selectImage(nImages);
	close(); 
}
setBatchMode(false);
print("Finished");


// ---- Functions ----

function processFolder(input, output, suffix, param) {

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
			processFile(input, output, list[i], filenum, param); // passes the filename and parameters to the processFile function
		}
	}
} // end of processFolder function


function processFile(inputFolder, outputFolder, fileName, fileNumber, parameter) {
	
	// this function processes a single image
	
	path = inputFolder + File.separator + fileName;
	print("Processing file",fileNumber," at path" ,path);	

	// determine the name of the file without extension
	dotIndex = lastIndexOf(fileName, ".");
	basename = substring(fileName, 0, dotIndex); 
	extension = substring(fileName, dotIndex);
	
	print("Processing file at path" ,path,", with basename",basename);
	
	// open the file
	run("Bio-Formats", "open=&path");

	// ---- Insert your processing steps here! ---- 
	
	// save the output
	outputName = basename + "_processed.tif";
	saveAs("tiff", outputFolder + File.separator + outputName);
	close();
	

} // end of processFile function


			
			