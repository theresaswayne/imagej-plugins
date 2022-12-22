
// draft of an attempt to make intensity modulated image

// ---- Make an intensity modulated image ----

// create a new single-channel RGB image to hold the data
IMName = "Intensity Modulated GP "+title;
newImage(IMName, "RGB black", width, height, 1, 1, 1);

// convert the RGB image to the HSB colorspace
selectWindow(IMName);
run("HSB Stack");

// hue is the GP value
selectWindow("GP "+title);
run("Duplicate...", "title=copy_1");
selectWindow("copy_1");
run("Add...", "value=1"); // make all the values positive
run("Conversions...", "scale"); // make sure values are scaled properly when we convert
//run("8-bit"); // possibly omit this?
run("Select All");
run("Copy");
//selectWindow("copy_1");
//close(); // the 8-bit copy
selectWindow(IMName);
setSlice(1); // hue
run("Paste");

// saturation should be all white (max value)
selectWindow(IMName);
setSlice(2); // saturation
setForegroundColor(255, 255, 255); // white
run("Select All");
run("Fill", "slice");

// a popular choice for the value is the sum (or average) of the two channels. Here we use the sum.
selectWindow("Sum.tif");
//run("Duplicate...", "title=copy_2");
//selectWindow("copy_2");
//run("8-bit");
run("Select All");
run("Copy");
//selectWindow("copy_2");
//close(); // the 8-bit copy
selectWindow(IMName);
setSlice(3); // value
run("Paste");

// finally convert the HSB image back into RGB color space
selectWindow(IMName);
run("Duplicate...", "title=copy_HSB");
selectWindow("copy_HSB");
run("RGB Color");