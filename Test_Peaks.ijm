// make an image with simulated peaks

// create blank image
newImage("Test_Peaks", "8-bit black", 200, 200, 1);

// set foreground to white
run("Color Picker...");
setForegroundColor(255, 255, 255);

// make small circle selections and fill with white
run("Specify...", "width=3 height=3 x=50 y=50 oval");
run("Fill", "slice");

run("Specify...", "width=3 height=3 x=140 y=100 oval");
run("Fill", "slice");

// blur to simulate gaussian peaks
run("Select None");
run("Gaussian Blur...", "sigma=3");
