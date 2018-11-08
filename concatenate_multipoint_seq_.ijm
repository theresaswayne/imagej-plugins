//@ File (label = "Input directory", style = "directory") inputDir
//@ File (label = "Output directory", style = "directory") outputDir

//@ String (label = "Output file base name") outputBase
//@ Integer (label = "Number of XY positions") numPos
//@ Integer (label = "Number of sequence steps per position") seqSteps

// concatenate_multipoint_seq.ijm
// IJ1 macro by Theresa Swayne, Columbia University, 2018
// For Sharon Fleischer, Vunjak-Novakovic lab

// Purpose: Generate time-lapse movies from ND sequence acquisitions.
// Details: Nikon's Multipoint Sequence time-lapse acquisition produces a set of ND2 files in numerical order. 
// 		Each timepoint may include multiple XY positions and multiple steps per position. 
// 		This macro will merge all the files from each position into a single time-lapse movie.

// Input: A set of ND2 files named in order, stored in one directory.  
//		The files must be named like test001.nd2, test002.nd2... test999.nd2. The number of digits is flexible, but it must be the same for all files in the dataset. 
//		Some of the sequence steps may themselves be time-lapse series. 
//		User must provide the number of XY positions, the number of sequence steps per position, and an output file name and folder. 

// Output: A set of N time-lapse series tiffs, containing the timepoints fused together in order (where N = number of XY positions in the experiment)

// Limitations: 
//		The files must be named in ALPHABETICAL order with leading zeros: test001, test002... test999. Number of digits must be the same for all files. 
// 		You can't analyze velocities with these movies because the time-lapse intervals are not constant. 
// 		No extraneous files can be in the input directory.
//		This is tested on multichannel series, but has not been tested with z series.

run("Bio-Formats Macro Extensions"); // required to open ND2 files

list = getFileList(inputDir); // files in the folder
list = Array.sort(list); // in alphabetical, not numerical order! 
numFiles = list.length;
//print("there are",numFiles,"files");

filesPerTime = numPos * seqSteps;

if (numFiles%filesPerTime == 0) {
	t = numFiles/filesPerTime; // calculate number of timepoints
	print("There are ",numPos,"positions,",seqSteps,"steps in the sequence, and",t,"timepoints for a total of",numFiles," images." );
}
else { // print warning if # files is wrong
	exit("There are "+numFiles+" files in the directory but we need a multiple of "+filesPerTime+".\nCheck input parameters.");
}


for (pos = 1; pos < numPos+1; pos++) { // loop through positions

	firstFileIndex = (pos-1)*seqSteps; // starting at 0 because the list position is the file number minus 1
	print("About to process position",pos," which starts at file",firstFileIndex, "called",list[firstFileIndex]);
	processPosition(inputDir, outputDir, list, pos); // first file in the timepoint
}


function processPosition(input, output, fileList, pos) { 

	// function to process an XY position
	// input, output: directories
	// fileList: list of files in the input directory
	// pos: the position number (starting at 1)
	// opens all images for that position, concatenates, and saves
	
	print("Processing position",pos);
	
	firstFileIndex = (pos-1)*seqSteps; // starting at 0 because the list position is the file number minus 1

	// open all the files for the position
	for (time = 0; time < t; time++) {

		for (seq = 0; seq < seqSteps; seq++) {

			fileIndex = firstFileIndex + (time * filesPerTime) + seq;
			file = fileList[fileIndex];
			print("Processing file",fileIndex,"called",file);
			path = input + File.separator + file;
		    run("Bio-Formats", "open=path autoscale color_mode=Default view=Hyperstack stack_order=XYCZT");
			}

	}
	outputName = outputBase+"_XY_"+pos+".tif";
	run("Concatenate...", "all_open title="+outputName+" open"); // concats all files in order of opening, 4D style, not keeping original
	print("Saving to: " + output);
	saveAs("Tiff", outputDir + File.separator + outputName);   
	close();

}