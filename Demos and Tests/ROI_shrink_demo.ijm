// ROI_shrink_demo.ijm
// IJ1 macro to cycle through ROI Manager and shrink each ROI by a specified amount 
// usage:  have ROI Mgr open with ROIs, run macro
// input: ROIs in ROI Manager
// output: new ROIs in ROI Manager

numROIs = roiManager("count");

shrinkFactor = -0.5; // scaled units

for (index = 0; index < numROIs; index++) {
	roiManager("Select", index);
	run("Enlarge...", "enlarge="+shrinkFactor);
	roiManager("Update");
	}

print("processed "+numROIs+" ROIs.")
