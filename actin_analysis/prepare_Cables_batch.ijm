// @File(label = "Input directory", style = "directory") inputdir
// @File(label = "Output directory", style = "directory") outputdir
// @String(label = "File suffix", value = ".tif") suffix
// @Integer(label="Slices to delete from beginning:",value=0,persist=false) trimTop
// @Integer(label="Slices to delete from end:",value=0,persist=false) trimBottom

// Note: DO NOT DELETE OR MOVE THE FIRST FEW LINES -- they supply essential parameters.

// IJ1 macro to prepare images for 3D analysis in plugins such as BoneJ, SimpleNeuriteTracer
//  1) (Optional) Deletes a specified # slices from beginning and end of stack, e.g. if blur artifacts are present
//	2) Makes voxels isotropic (same xyz size) by reslicing in Z direction
//  3) Pads with blank slices at beginning and end.
// Matches bit depth of input image.
// Input: folder of single-channel z stacks with z spacing <> xy spacing
// Output: processed stacks.

// TO USE THIS MACRO: 
// 	Place your images in a folder.
//	Create a separate output folder to store the results.
//	Open this file in Fiji and click Run.

// T. Swayne, for Pon lab, 2018


// ---- Setup

run("Bio-Formats Macro Extensions"); // enables access to macro commands
setBatchMode(true); 
n = 0;

// ---- Commands to run the processing functions

processFolder(inputdir, suffix); // actually do the analysis
showMessage("Finished.");
setBatchMode(false);

// ---- Function for processing folders
function processFolder(inputdir, suffix) 
	{
	list = getFileList(inputdir);
	for (i=0; i<list.length; i++) 
		{
	    if(File.isDirectory(inputdir + File.separator + list[i])) {
			processFolder("" + inputdir +File.separator+ list[i]); }
	    else if (endsWith(list[i], suffix)) {
	       	processImage(inputdir, list[i]); } 
		}
	}

// ------- Function for processing individual files

function processImage(inputdir, name) 
	{
	// ---- Open image and get name, info
	open(inputdir + File.separator + name);
	print("processing image", name);
	dotIndex = indexOf(name, ".");
	basename = substring(name, 0, dotIndex);
	processedName = name + "_isotrop_pad.tif";

	getVoxelSize(voxwidth, voxheight, depth, unit);
	getDimensions(stackwidth, stackheight, channels, slices, frames);
	origBitDepth = bitDepth(); 

	// ---- Trim slices at beginning and end

	// check for illegal values
	if ((trimTop + trimBottom) > slices) {
		showMessage("You tried to delete more slices than there are in the stack.");
		exit;
		}

	subStart = trimTop + 1;
	subEnd = slices - trimBottom;
	run("Make Substack...", "  slices="+subStart+"-"+subEnd);
	rename("Substack");
	selectWindow("Substack");

	// make voxels isotropic
	run("Reslice Z", "new="+voxwidth);
	
	// pad with blank slices at beginning and end
	newImage("blankSlice", origBitDepth+"-bit black", stackwidth, stackheight, 1);
	run("Concatenate...", "  title=&processedName image1=blankSlice image2=[Resliced] image3=blankSlice");
	
	// set scale of concatenated image
	selectWindow(processedName);
	setVoxelSize(voxwidth, voxheight, voxwidth, unit);

	// save processed image
	saveAs("tiff", outputdir + File.separator + processedName);
	
	// clean up
	while (nImages > 0) {
		close(); }
	} // end processImage function
	
