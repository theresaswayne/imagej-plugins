
// make a small window (e.g. of a single yeast cell) easier to see

// zoom in 3x to some arbitrary-ish center
run("Set... ", "zoom=300 x=36 y=37");

// enhance display contrast and set pseudocolor on channels 4 and 5
Stack.setDisplayMode("color");
Stack.setChannel(4);
run("Red");
resetMinAndMax;
Stack.setChannel(5);
resetMinAndMax;
run("Green");

// show the overlay of only channels 4 and 5
Property.set("CompositeProjection", "Sum");
Stack.setDisplayMode("composite");
Stack.setActiveChannels("00011");

