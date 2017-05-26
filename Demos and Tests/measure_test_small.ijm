// measure_test.ijm
// goal: test whether multi-measure causes expansion of results table
// Note that the number of results increases incorrectly each time Multi-Measure is called with the "append" option,
// and this is "fixed" by closing the ROI manager window.

run("Dot Blot (7K)");
run("Set Measurements...", "area redirect=None decimal=2");
print("Clearing results and resetting ROI Manager");
run("Clear Results");
roiManager("reset");
print("Results at start:",nResults);

run("Specify...", "width=50 height=50 x=200 y=200");
roiManager("Add");

// Multi-Measure

for (i = 1; i < 3; i++) {
	print("Results before multi-measure, iteration "+i+":",nResults);
	roiManager("Deselect");
	roiManager("multi-measure measure_all append");
	print("Results after multi-measure, iteration "+i+":",nResults);
	print("Clearing results");
	run("Clear Results");
	}


// Multi-Measure, but close the ROI manager window

for (i = 1; i < 4; i++) {
	print("Results before multi-measure with close, iteration "+i+":",nResults);
	roiManager("Deselect");
	roiManager("multi-measure measure_all append");
	print("Results after multi-measure with close, iteration "+i+":",nResults);
	print("Clearing results and closing ROI Manager");
	run("Clear Results");
	selectWindow("ROI Manager");
	run("Close");
	run("Specify...", "width=50 height=50 x=200 y=200"); // re-add the ROI for the next iteration
	roiManager("Add");
	}
	
print("Results at end:",nResults);
print("==================================");
selectWindow("Dot_Blot.jpg");
close();
roiManager("reset");
selectWindow("ROI Manager");
run("Close");
