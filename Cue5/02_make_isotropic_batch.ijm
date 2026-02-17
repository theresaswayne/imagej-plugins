// @File(label = "Input directory", style = "directory") inputdir
// @File(label = "Output directory", style = "directory") outputdir
// @String(label = "File suffix", value = ".tif") suffix
//@ int(label="Channel to process:")  chan
//@Double (label = "Reslice Z step size", value = 0.0645, stepSize=0.01) reslice

// Note: DO NOT DELETE OR MOVE THE FIRST FEW LINES -- they supply essential parameters.

// IJ1 macro to prepare images for 3D analysis
// Can be used to make voxels isotropic (same xyz size) by reslicing in Z direction
// Input: folder of multi-channel z stacks with z spacing <> xy spacing
// Output: single-channel processed stacks.

// TO USE THIS MACRO: 
// 	Place your images in a folder.
//	Create a separate output folder to store the results.
//	Open this file in Fiji and click Run.

// T. Swayne, for Pon lab, 2018, updated 2026
//  -------- Suggested text for acknowledgement -----------
//   "These studies used the Confocal and Specialized Microscopy Shared Resource 
//   of the Herbert Irving Comprehensive Cancer Center at Columbia University, 
//   funded in part through the NIH/NCI Cancer Center Support Grant P30CA013696."


// ---- Setup

run("Bio-Formats Macro Extensions"); // enables access to macro commands
setBatchMode(true); 
n = 0;

// ---- Commands to run the processing functions

processFolder(inputdir, outputdir, suffix, chan, reslice); // actually do the analysis
showMessage("Finished.");
setBatchMode(false);

// ---- Function for processing folders
function processFolder(inputdir, outputdir, suffix, chan, reslice) 
	{
	list = getFileList(inputdir);
	for (i=0; i<list.length; i++) 
		{
	    if(File.isDirectory(inputdir + File.separator + list[i])) {
			processFolder("" + inputdir +File.separator+ list[i]); }
	    else if (endsWith(list[i], suffix)) {
	       	processImage(inputdir, list[i], outputdir, suffix, chan, reslice); } 
		}
	}

// ------- Function for processing individual files

function processImage(inputdir, name, outputdir, suffix, chan, reslice) 
	{
	// ---- Open image and get name, info
	open(inputdir + File.separator + name);
	print("processing image", name);
	dotIndex = indexOf(name, ".");
	basename = substring(name, 0, dotIndex);

	getVoxelSize(voxwidth, voxheight, depth, unit);
	getDimensions(stackwidth, stackheight, channels, slices, frames);
	origBitDepth = bitDepth(); 
	
	// select the channel of interest
	if (chan > channels) { // error in selection
		showMessage("That channel does not exist in this data!");
		continue; 
		}
	else {
		
		dupName = basename + "-c"+chan;
		run("Duplicate...", "title="+dupName+" duplicate channels="+chan);
	
		// make voxels isotropic
		//run("Reslice Z", "new="+voxwidth);
		run("Reslice Z", "new="+reslice);
		
		processedName = dupName + "_resliced.tif";
		rename(processedName);
		
		selectWindow(processedName);
		//setVoxelSize(voxwidth, voxheight, voxwidth, unit);
	
		// save processed image
		saveAs("tiff", outputdir + File.separator + processedName);
		
		// clean up
		while (nImages > 0) {
			close(); }
			}
	
	} // end processImage function
	
