// colorND2_to_RGB.ijm
// converts color brightfield image with 3 components to an RGB tiff using gamma of 0.45

// usage: open an image. run the macro.

// set contrast and brightness to full range for all 3 channels
Stack.setDisplayMode("color");
for (i = 1; i <=3; i++) {
	Stack.setChannel(1);
	setMinAndMax(0, 255);
}

// convert to an RGB image
Property.set("CompositeProjection", "Sum");
Stack.setDisplayMode("composite");
run("RGB Color");

// optional: set the standard histology gamma value of 0.45. (Gamma of the initial RGB image is 1.0)
run("Gamma...", "value=0.45");
