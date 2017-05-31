
// setup

// for each channel

	// make a copy
	// run("Duplicate...", "duplicate channels=2");
	
	// TODO: have user draw ROI on cytoplasmic background
	// add to manager
	run("Measure"); // TODO: get mean 
	
	// make initial mask
	setAutoThreshold("Default dark");
	setThreshold(123, 4095); // lower = 150% of the mean 
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark black");
	
	// remove stray pixels
	run("Options...", "iterations=1 count=1 black edm=16-bit do=Open stack");

// TODO: OR the two channels -- generally gives the larger inclusion

// set up inclusion measurements TODO: redirect to original image -- note you have to do this on the single channel image
run("Set Measurements...", "area mean min integrated display redirect=[to be measured] decimal=3");

// for each channel
	// measure the OR image redirecting to each channel of the original image
	run("Analyze Particles...", "display exclude stack");

// consolidate results table?


