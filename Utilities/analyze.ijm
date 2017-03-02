// Particle analysis and measurement
// IJ1 macro to analyze particles, adjust ROI size, and measure intensity 
// usage: have mask image open, run macro
// input: mask image, raw image
// output: measurements and rois


// TODO: get path for saving ROIs

// initial particle detection 

selectWindow("Hua_Gau_test open 23 ws.tif");
setAutoThreshold("Default dark");
run("Analyze Particles...", "size=70-300 display exclude clear summarize add");

// ROI shrinkage

numROIs = roiManager("count");

shrinkFactor = -0.5;

for (index = 0; index < numROIs; index++) {
	roiManager("Select", index);
	run("Enlarge...", "enlarge="+shrinkFactor);
	roiManager("Update");
	}

print("processed "+numROIs+" ROIs.")

// TODO: save adjusted ROIs

// analysis of adjusted rois

run("Set Measurements...", "area mean min centroid display decimal=2");
selectWindow("raw_bgsub.tif");
roiManager("deselect");
roiManager("multi-measure measure_all");

// TODO: save ROIs and clear manager
// roiManager("deselect")
// roiManager("Save", "/Users/confocal/Desktop/Alberini brain images/cfos-Arc/RoiSet.zip");
// roiManager("reset")