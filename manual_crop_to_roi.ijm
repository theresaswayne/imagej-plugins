
// given a set of ROIs (in the manager) and a stack, 
// saves a cropped stack in the image directory for each ROI

path = getDirectory("image");
id = getImageID();
title = getTitle();
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);

selectImage(id); // go to original image
roiManager("Deselect");
run("Select None");
numROIs = roiManager("count");
for(i=0; i<numROIs;i++) // goes to each ROI in turn
	{ 
	selectImage(id); // go to original image
	cropName = basename+i;
	roiManager("Select", i); 
	run("Duplicate...", "title=&cropName duplicate");
	selectWindow(cropName);
	saveAs("tiff", path+getTitle);
	close();
	}	
run("Select None");

