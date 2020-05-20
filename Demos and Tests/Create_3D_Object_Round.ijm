// create a test stack for 3d object processing
// There is one spherical object, not touching any edge.

// setup
circleR = 50; // maximum radius of the whole object
zRatio = 4; // z:xy voxel size ratio (typical microscopy ratio = 4) 
slices = 31; // any ODD number
midSlice = (slices+1)/2 ; // odd numbers only
print("midSlice =",midSlice);

// Start with a 256 x 256 black image
newImage("HyperStack", "8-bit grayscale-mode", 256, 256, 1, slices, 1);
setForegroundColor(255, 255, 255); // white

// Set the scale reflecting the desired z:xy ratio (4:1 mimics most real microscopy datasets)
run("Properties...", "channels=1 slices=&slices frames=1 unit=pixel pixel_width=1.0000 pixel_height=1.0000 voxel_depth=&zRatio");

// create gradually expanding circles 

for (slice = 2; slice < midSlice ; slice++) {
	print("Processing slice", slice);
	setSlice(slice);
	dz = zRatio * (midSlice - slice); // z distance of this slice from center of sphere
	print("z distance =",dz);
	dx = circleR * cos(asin(dz/circleR)); // x distance from center of circle to edge in this slice
	diam = 2*dx;
	print("x distance = ",dx,"; diameter =",diam);
	run("Specify...", "width="+diam+" height="+diam+" x=128 y=128 oval centered");
	run("Fill", "slice");
	print("Finished with slice",slice);
}

// create gradually contracting circles

for (slice = midSlice; slice < slices + 1 ; slice++) {
	print("Processing slice", slice);
	setSlice(slice);
	dz = zRatio * (slice - midSlice); // z distance of this slice from center of sphere
	print("z distance =",dz);
	dx = circleR * cos(asin(dz/circleR)); // x distance from center of circle to edge in this slice
	diam = 2*dx;
	print("x distance = ",dx,"; diameter =",diam);
	run("Specify...", "width="+diam+" height="+diam+" x=128 y=128 oval centered");
	run("Fill", "slice");
	print("Finished with slice",slice,"\n");
}

// finish up

run("Select None");


// open the 3d viewer

//run("3D Viewer");
//call("ij3d.ImageJ3DViewer.setCoordinateSystem", "false");
//call("ij3d.ImageJ3DViewer.add", "HyperStack", "White", "HyperStack", "0", "true", "true", "true", "2", "0");
//call("ij3d.ImageJ3DViewer.select", "HyperStack");

// open clearvolume
run("Open in ClearVolume", "datasetview=net.imagej.display.DefaultDatasetView@2340bcb0");

