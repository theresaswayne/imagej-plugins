// illustrates how to measure all ROIs in manager, then measure whole image 
// workaround for multi-measure apparent bug in which whole-image measurements are erased even when Append Results is checked.

// get ROIs
run("Blobs (25K)");
setOption("BlackBackground", true);
run("Make Binary");
roiManager("reset");
run("Clear Results");
print("analyzing particles");
run("Analyze Particles...", "size=" + 1 + "-" + 1000 + " exclude add");

// select each and measure in turn
for (trial = 1; trial < 4; trial++)  // accumulate several sets of measurements to mimic a real experiment
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
	run("Measure"); // measure whole image
	}

selectImage("blobs.gif")
close();

