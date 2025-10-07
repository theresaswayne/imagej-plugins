// Threshold value test macro

// ---- setup ----

run("Close All");
print("\\Clear");
threshold = "Default";

// open an image
//run("M51 Galaxy (16-bits)");
newImage("Ramp8", "8-bit ramp", 512, 512, 1);
title = getTitle();

// ---- pre-process image ----

//run("32-bit");
//run("8-bit");

// ---- test display vs getThreshold values ----

// auto threshold
selectWindow(title);
run("Select None");
run("Duplicate...", "title=Auto");
setAutoThreshold(threshold+" dark");
getThreshold(lowerAuto, upperAuto);
print("Automatically selected threshold value: "+ lowerAuto);
createNaNMask();
resetThreshold;

// user-selected threshold, but user does not apply it
selectWindow(title);
run("Select None");
run("Duplicate...", "title=Manual");
run("Threshold..."); // ask user to set the threshold
waitForUser("Set the threshold but don't hit apply");
getThreshold(lowerManual, upperManual);
print("User selected threshold value: "+ lowerManual);
resetThreshold;

// user selects and applies threshold, value retrieved afterwards
// NB this results in an inaccurate number
selectWindow(title);
run("Select None");
run("Duplicate...", "title=ManualUserApplied");
setOption("BlackBackground", true);
run("Threshold..."); // ask user to set the threshold
waitForUser("Set the threshold and hit apply");
run("Threshold..."); // run again to retrieve the values
getThreshold(lowerApply, upperApply);
print("User applied threshold value: "+ lowerApply);


// ---- test macro-applied vs user-applied threshold

// user-selected threshold, macro applies (16 bit)
newImage("Ramp16", "16-bit ramp", 512, 512, 1);
selectWindow("Ramp16");
run("Select None");
run("Duplicate...", "title=16bitMacroApplied");
run("Threshold..."); // ask user to set the threshold
waitForUser("Set the threshold but don't hit apply");
getThreshold(lowerMan16, upperMan16);
print("User selected threshold value, 16 bit: "+ lowerMan16);
setOption("BlackBackground", true);
run("Convert to Mask");

// user-selected threshold, macro applies (32 bit)
newImage("Ramp32", "32-bit ramp", 512, 512, 1);
selectWindow("Ramp32");
run("Select None");
run("Duplicate...", "title=32bitMacroApplied");
run("Threshold..."); // ask user to set the threshold
waitForUser("Set the threshold but don't hit apply");
getThreshold(lowerMan32, upperMan32);
print("User selected threshold value, 32 bit: "+ lowerMan32);
setOption("BlackBackground", true);
run("NaN Background");
createNaNMask();


function createNaNMask() {
	
	run("Options...", "black");
	run("32-bit");
	run("Macro...", "code=[if (v == 0) v = NaN;]"); // set the background pixels to NaNs using Process > Math > Expression evaluator
	run("Macro...", "code=[if (v > -1) v = 1;]");   // set the foreground pixels to 1.0
	setMinAndMax(0.0,1.0);
	
}