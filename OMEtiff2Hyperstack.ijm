// @File(label = "Folder with stacks to process:", style = "directory") myDir
//
// DO NOT MOVE OR DELETE THE FIRST FEW LINES! They supply essential parameters.
//
// OMEtiff2Hyperstack.ijm
// ImageJ/Fiji macro by
// E. Laura Munteanu
// Specialized Micrsocopy Shares Resources, Columbia University HICCC
// 2018
// 
// Input: A folder containing the files. Each file is a frame series that concatenated multiple
// z planes and channels in one dimension.
// Output: A folder with  hyperstacks with the Z anf Ch dimensions corect; saves it with same file name.
///////////////////////////////////////////////////// 

dirIn	= myDir + File.separator;
dirOut	= dirIn + "hyperstacks" + File.separator;

// read filenames and open .tiff for batch processing
list = getFileList(dirIn);
for (k = 0; k < list.length; k++) {
	if(endsWith(list[k], "tiff")) {
		file = list[k];
		open(dirIn+list[k]);

///////////////////////////////////////////////////

// read dimentions of stack; s represents nrZ x nrCh
Stack.getDimensions(width, height, ch, s, frames);

// Determine the z dimension by finding a difference greater than 3% in mean intensity
// between adjacent slices. We assume the first frames are the z slices of first channel,
// followed by the z slices of second channel and so on.

// Measure mean intensity in first slice, mean0, that is the mean intensity to be compared with next slice.
Stack.setSlice(1);
getStatistics(area, mean0);

// Measure mean intensity in current slice, starting at second slice and compare with previous slice.
// If there is a difference greater than 3% we are at the beginning of next channel. 
for (i = 1; i < s; i++) {
		Stack.setSlice(i+1);
		getStatistics(area, mean1);
		if ( abs(mean1 - mean0) < 0.05 * mean1 ) {
			mean0 = mean1;
		} else {
			nrZ = i;
			i = s + 1;
		}
}

// calculate number of channels
if ( s/nrZ - round(s/nrZ) == 0)  {
	nrCh = s / nrZ;
} else {
	print("Error in determining first channel");
}

//create hyperstack and save
run("Stack to Hyperstack...", "order=xyzct channels=nrCh slices=nrZ frames=1");
//run("Save");
save(dirOut+file);
close();		
	}
}