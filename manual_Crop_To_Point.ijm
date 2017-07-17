// @File(label = "Image to crop:") sourceimage
// @File(label = "Output folder:", style = "directory") outputdir

// Note: DO NOT DELETE OR MOVE THE FIRST 2 LINES -- they supply essential parameters.
// manual_Crop_To_Point.ijm
// ImageJ/Fiji macro by Theresa Swayne, tcs6@cumc.columbia.edu, 2017
// Input: A stack (or single plane) image. User is prompted to select points.
// Output: A stack (or single plane) corresponding to 200x200 pixels (CROPSIZE parameter) centered on each point.
// 		Output images are named with the original filename and a subscript from 0 to the number of ROIs, 
//		and are saved in the output directory.
//		Non-rectangular ROIs are cropped to their bounding box.
// 		If the LUTNAME parameter is set, the cropped images will have that LUT.  
//		An ROIset is saved showing the points on the original image.
// Usage: Adjust CROPSIZE and LUTNAME as desired. Open an image. 
//		Then run the macro. 
// Limitations: If the point is < 200 pixels from an edge the output image is not 200x200,  
// 		but only goes to the edge of the image.

// adjustable parameters
LUTNAME = "Fire"; // the LUT of the cropped image. For no change (or for multichannel images) use ""
CROPSIZE = 200; // // maximum width and height of the final cropped image, in pixels

// get file info 
open(sourceimage);
id = getImageID();
title = getTitle();
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);
roiName = basename + "_roiset.zip"; 
// dataName = basename + "_data.csv"

// setup
selectImage(id);
roiManager("Reset");
run("Select None");
setTool("point");
run("Point Tool...", "type=Hybrid color=Yellow size=Medium add label");

// collect points
waitForUser("Mark cells", "Click on all of your cells, then click OK");

// adjust LUT for ease of visualization
if (LUTNAME != "") 
	{
	run(LUTNAME);
	}

numROIs = roiManager("count");
for(i=0; i<numROIs;i++) // loop through ROIs
	{ 
	selectImage(id); 
	cropName = basename+"_"+i; // this becomes the name of the cropped image
	roiManager("Select", i); 
	Roi.getCoordinates(x, y); // arrays
	run("Specify...", "width=200 height=200 x="+x[0]+" y="+y[0]+" slice=1 centered"); // makes new rectangle ROI centered on the point
	run("Duplicate...", "title=&cropName duplicate"); // creates the cropped stack
	selectWindow(cropName);
	saveAs("tiff", outputdir + File.separator + getTitle);
	close();
	}	
run("Select None");

// save ROIs to show location of each cell within the field
roiManager("save",outputdir+File.separator+roiName);
