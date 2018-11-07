//@ File (label = "Input file", style = "file") inputFile
//@ File (label = "Output directory", style = "directory") outputDir

//@ String (label = "Output file name") outputName
//@ String (label = "Number of XY positions") pos
//@ String (label = "Number of sequence steps per position") seqSteps

// concatenate_multipoint_seq.ijm
// IJ1 macro by Theresa Swayne, Columbia University, 2018
// For Sharon Fleischer, 

// Nikon's Multipoint Sequence acquisition produces a set of ND2 files in numenrical order.
// Given a set of ND2 files this macro will merge all the files from each timepoint into a single time-lapse movie.
// Input: A time-lapse set of files from n positions, each encompassing s steps, repeated for t timepoints, named in numerical order, no gaps, and all in one directory.  
// 	Some of the sequence steps may themselves be time-lapse images. We expect channels but not z.
// Output: A set of n files containing the timepoints fused together in order (n = number of positions in the experiment)
// Limitations: 
//		You can't analyze velocities because the time-lapse intervals are not constant. 
// 		No extraneous files can be in the directory.


setBatchMode(true);
run("Bio-Formats Macro Extensions");


processFolder(inputFile);

// function to scan folders/subfolders/files 
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list); // TODO: verify it's in numerical order

	filesPerTimepoint = pos*seqSteps
	t = list.length/filesPerTimepoint // calculate number of timepoints
	

	// TODO: throw error if # files is wrong
	
	for (i = 0; i < pos; i++) { // loop through positions

		firstFileIndex = i*seqsteps; // starting at 0 because the list position is file number - 1
		processFile(input, output, list[firstFileIndex]); // first file in the timepoint
	}
}

function processFile(input, output, file) {
	// Do the processing here by adding your own code.
	// Leave the print statements until things work, then remove them.
	print("Processing: " + input + File.separator + file);

	// loop over timepoints
	for (ti = 0; ti < t; ti++) {

	// run("Concatenate...", "  title=[conc 4d] keep open image1=HUVECs-Rac001.nd2 image2=HUVECs-Rac002.nd2");
	// Open first file index  for that point fi =  s*pi (0, s, 2s...)
	// loop si from 1 to s (last is s-1) // within a timepoint
	//  Append file index i + si
	//  Now you have 1 timepoint 1 pos 

	// Loop ti over timepoints // gather each timepoint for that point
	//   loop si from 0 to s (last is s-1) // within a timepoint
	//        Append file index  fi =  (ti-1)*(s*p) + si

	}
 
	
	print("Saving to: " + output);
	// saveAs("Tiff", dir2+File.separator+name+"_"+seriesname+"_MIP_"+j+".tif");    
}

// *why did elements find extra channels?

// Sort file names numerically (is this poss in python)

