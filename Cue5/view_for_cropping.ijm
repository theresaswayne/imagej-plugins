// move to trans image
Stack.setPosition(3,11,1);

// adjust contrast and color for trans
Stack.setDisplayMode("color");
Stack.setChannel(3);
run("Grays");
resetMinAndMax;

// adjust contrast and color for Nup159
Stack.setChannel(5);
run("Enhance Contrast", "saturated=0.35");
run("Green");
resetMinAndMax;

// overlay
Property.set("CompositeProjection", "Sum");
Stack.setDisplayMode("composite");
Stack.setActiveChannels("00101");
