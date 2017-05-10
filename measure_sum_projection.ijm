// designed to measure total calcofluor
// generates and saves a sum projection, applies a threshold, and measures
// works on single-channel stacks. must include whole cell.
// also works in batch macro command

path = getDirectory("image");
id = getImageID();
title = getTitle();
// print("title is",title);
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);

run("Z Project...", "projection=[Sum Slices]");
// setAutoThreshold("Minimum dark stack");
// setAutoThreshold("Default dark stack");
setAutoThreshold("Huang dark stack");

run("Set Measurements...", "area mean min integrated limit display redirect=None decimal=2");
run("Measure");

selectWindow("SUM_"+title);
saveAs("tiff", path+getTitle);

while (nImages > 0) { // works on any number of channels
	close();
	}
	