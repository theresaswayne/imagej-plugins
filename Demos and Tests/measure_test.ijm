// measure_test.ijm
// goal: test if multi-measure causes expansion of results table
// to test: run the macro a few times in succession. 
// Note the number of results increases incorrectly when Multi-Measure is called with the "append" option, even though results appear to be clearerd att the beginning of the macro
// this is fixed by closing the ROI manager window

run("Dot Blot (7K)");
run("Set Measurements...", "area redirect=None decimal=2");
roiManager("reset");
print("clearing results");
run("Clear Results");
print("number of results at start:",nResults);

// make selections
for (i = 1; i < 3; i++) {
	run("Specify...", "width="+(i*10)+" height="+(i*10)+" x=200 y=200");
	roiManager("Add");
	}

// measure ROIs using Multi-Measure
for (i = 1; i < 3; i++) {
	print("Multi-Measure, start of repetition",i+", nResults: ",nResults);
	roiManager("Deselect");
	roiManager("multi-measure measure_all append");
//	roiManager("multi-measure measure_all");
	print("Multi-Measure, end of repetition",i+", nResults: ",nResults);
	}

// measure ROIs individually
for (i = 1; i < 3; i++) {
	print("Individual measurement, start of repetition",i+", nResults: ",nResults);
	numROIs = roiManager("count");
	for (j = 0; j < numROIs; j++) {
		roiManager("select",j);
		//print("measuring ROI",j+1);
		run("Measure");
		}
	print("Individual measurement, end of repetition",i+", nResults: ",nResults);
	}


print("number of results at end:",nResults);
print("==================================");
selectWindow("Dot_Blot.jpg");
close();
roiManager("reset");
selectWindow("ROI Manager");
run("Close"); // close() does not work to close the ROI Manager

// problem -- multimeasure retains results after clear -- unless roi manager is closed
// TODO -- clean up example == if possible demonstrate this with a single run of the macro


