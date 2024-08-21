// DRAFT Macro to merge, convert to RGB, and set scale on currently open images


// collect open image names

redImage = findColor("Red");

function findColor(color) { // gets the Title of image in the desired channel
	n = nImages;
	for (i=1; i<=n; i++) {
		selectImage(i);
		imageTitle = getTitle();
		imageId = getImageID();
		if (matches(imageTitle, "(.*)"+color+"(.*)"))
			return(imageTitle);
}


}


run("Merge Channels...", "c1=[A1ROI1_-3_1_1_Stitched[Read 2_Red]_001.tif] c2=[A1ROI1_-3_2_1_Stitched[Read 2_Green]_001.tif] c3=[A1ROI1_-3_3_1_Stitched[Read 2_Blue]_001.tif] create");
//run("Channels Tool...");
Property.set("CompositeProjection", "null");
Stack.setDisplayMode("color");
Stack.setChannel(1);
Stack.setChannel(1);
//run("Brightness/Contrast...");
resetMinAndMax();
selectImage("Composite");
resetMinAndMax();
resetMinAndMax();
resetMinAndMax();
Property.set("CompositeProjection", "Sum");
Stack.setDisplayMode("composite");
run("RGB Color");
rename("RGB");
selectImage("Composite");



/*
 * Processes all open images. If an image matches the provided title
 * pattern, processImage() is executed.
 */
function processOpenImages() {
	n = nImages;
	setBatchMode(true);
	for (i=1; i<=n; i++) {
		selectImage(i);
		imageTitle = getTitle();
		imageId = getImageID();
		if (matches(imageTitle, "(.*)"+pattern+"(.*)"))
			processImage(imageTitle, imageId, output);
	}
	setBatchMode(false);
}

/*
 * Processes the currently active image. Use imageId parameter
 * to re-select the input image during processing.
 */
function processImage(imageTitle, imageId, output) {
	// Do the processing here by adding your own code.
	// Leave the print statements until things work, then remove them.
	print("Processing: " + imageTitle);
	pathToOutputFile = output + File.separator + imageTitle + ".png";
	print("Saving to: " + pathToOutputFile);
}
