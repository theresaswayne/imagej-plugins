// paste this text in the ImageJ Process > Batch > Macro window

getPixelSize(unit, pw, ph, pd);
run("Conversions...", " "); // make sure the image is not rescaled when converting
Stack.setDisplayMode("composite");
resetMinAndMax(); // attempt to set display contrast
run("RGB Color"); 
run("Gamma...", "value=0.45");
// set pixel size
run("Properties...", "pixel_width=&pw pixel_height&ph");
Stack.setXUnit("um"); // getPixelSize unit does not work here

