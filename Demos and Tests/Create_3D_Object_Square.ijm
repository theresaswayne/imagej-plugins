// create a test stack for 3d object processing
// There is one object, roughly a flattened diamond, not touching any edge.

// Start with an 11-slice 256 x 256 black image
newImage("HyperStack", "8-bit grayscale-mode", 256, 256, 1, 11, 1);

// Make a 64x64 white square in slices 5-7 
run("Specify...", "width=64 height=64 x=128 y=128 slice=4 centered");
setForegroundColor(255, 255, 255);

for (slice = 5; slice < 8; slice++) {
	setSlice(slice);
	run("Fill", "slice");
}
	
// Make a 24 x 24 white square in slices 3-4 and 8-9
run("Enlarge...", "enlarge=-20");
for (slice = 3; slice < 5; slice++) {
	setSlice(slice);
	run("Fill", "slice");
}
for (slice = 8; slice < 10; slice++) {
	setSlice(slice);
	run("Fill", "slice");
}

run("Select None");



// Set the scale so the z:xy ratio is 4:1 mimicking most real microscopy datasets
run("Properties...", "channels=1 slices=11 frames=1 unit=pixel pixel_width=1.0000 pixel_height=1.0000 voxel_depth=4");

