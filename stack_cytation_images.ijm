// @File(label = "Input folder:", style = "directory") inputDir
// @File(label = "Output folder:", style = "directory") outputDir
// @int(label = "# of timepoints:",style = "slider", min=1, max = 100) numTimepoints


// stack_cytation_images.ijm
// Theresa Swayne for Gina Finan, 2024
// Generates stacks from individual positions and channels within a Cytation experiment where all images are in the same folder 


// TO USE: Run the macro and specify folders for input and output, and select the # timepoints.
// The macro loads files in groups of n where n is the number of timepoints. So all files in the experiment must be in the folder. There can be no partial groups.

// see https://forum.image.sc/t/solved-merge-files-from-incucyte-96-well-plate-with-specific-name/71352


// ---- Setup ----

while (nImages>0) { // clean up open images
	selectImage(nImages);
	close();
}


setBatchMode(true); // faster performance
//run("Bio-Formats Macro Extensions"); // support native microscope files


// ---- Run ----

// get number of images

list = getFileList(inputDir);
list = Array.sort(list);
numFiles = list.length; // note it could include some extra files like DS Store
numStacks = floor(numFiles/numTimepoints);
print("The folder contains",numFiles,"files that will be made into",numStacks,"of",numTimepoints,"timepoints.");


// Open files by start and count

// TODO: Loop over numStacks

File.openSequence(inputDir, "start=26 step=1 count=25 scale=50");


// ALT: open image by file list index
// ALT: open using this command from a few years ago 	
// run("Image Sequence...", "open=inDir number=11 starting=i sort"); //read images and make stacks

// get image info

id = getImageID();
title = getTitle(); // TODO -- get actual image name -- better done with the array
dotIndex = indexOf(title, ".");
baseEnd = dotIndex-4; // remove the timepoint
basename = substring(title, 0, baseEnd);
extension = substring(title, dotIndex);
getDimensions(width, height, channels, slices, frames);
print("Processing",title, "with basename",basename);




// save original file (remove this later)

print("Saving to " + outputDir);

origName = basename+".tif";
selectImage(id);
saveAs("tiff", outputDir + File.separator + origName);
	

// TODO: run correction and save


// clean up open images and tables
while (nImages>0) {
selectImage(nImages);
close();
}

setBatchMode(false);

print("Finished");

