
// run("Z Project...", "projection=[Max Intensity]");
id = getImageID();


N_obj = roiManager("count");
print(N_obj);

for (i = 0; i < N_obj; i++) {
	roiManager("Select", i);
	
	Stack.setChannel(1);
	run("Set Measurements...", "mean min redirect=None decimal=3");
	run("Measure");
	maxDAPI = getResult("Max");
	meanDAPI = getResult("Mean");

	Stack.setChannel(2);
	run("Set Measurements...", "mean min integrated redirect=None decimal=3");
	run("Measure");
	meanGFP = getResult("Mean");
	totalGFP = getResult("RawIntDen");
	
	roiManager("Select", i);
	run("Enlarge...", "enlarge=5 pixel");
	
	selectImage(id);
	Stack.setChannel(3);
	run("Set Measurements...", "mean min integrated redirect=None decimal=3");
	run("Measure");
	totalRed = getResult("RawIntDen");
	meanRed = getResult("Mean");

	
}
