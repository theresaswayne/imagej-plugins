// renumberROIs.ijm
// ImageJ/Fiji macro by Theresa Swayne, tcs6@cumc.columbia.edu, 2017
// Input: a set of ROIs in the ROI manager 
// Output: a set of ROIs where each is renumbered with the original number +1 

// ---- Setup ----

IJ.log("\\Clear");
//path = getDirectory("image");
//id = getImageID();
//title = getTitle();
//dotIndex = indexOf(title, ".");
//basename = substring(title, 0, dotIndex);

// make sure nothing selected to begin with
//selectImage(id);
roiManager("Deselect");
//run("Select None");

numROIs = roiManager("count");


for(i=0; i<numROIs;i++) // loop through ROIs
	{ 
	roiManager("Select", i);
	roiNum = i + 1;
	roiManager("Rename", roiNum);
	}	
	
// Save ROI set

roiManager("Deselect"); 


