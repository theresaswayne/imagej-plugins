// measurement method testing
// see if we can select all rois and do regular measure rather than multimeasure
// workaround for multi-measure apparent bug in which whole-image measurements are erased even when append results is checked.


// get ROIs

run("Blobs (25K)");
setOption("BlackBackground", true);
run("Make Binary");
roiManager("reset");
run("Clear Results");
print("analyzing particles");
run("Analyze Particles...", "size=" + 1 + "-" + 1000 + " exclude add");

// try selecting all and measuring

for (trial = 1; trial < 4; trial++) 
	{
	print("selecting all ROIs and measuring");
	numROIs = roiManager("count");
	run("Select None");
	for(i=0; i<numROIs;i++) 
		{ 
		roiManager("Select", i); 
		run("Measure");
		}	
	run("Select None");
	run("Measure"); // measures whole image

	}
selectImage("blobs.gif")
close();
	
