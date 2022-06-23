//@ int(label="Channel for gel phase (short wavelength)", style = "spinner") Chan_Gel
//@ int(label="Channel for liquid crystalline phase (long wavelength)", style = "spinner") Chan_LC

// Calculates Generalized Polarization (GP) from a multichannel image with interative background selection 
// Output is a 32-bit image with the GP values
// GP Formula from Learmonth and Gratton, 2002, doi: 10.1007/978-3-642-56067-5_14
// GP = (Igel - Ilc)/(Igel + Ilc)
// GP is higher in less fluid membranes
// Theresa Swayne, Columbia University, 2022 for Erika Shor and Yasmine Hassoun

// TO USE: Open a multi-channel image. Run the macro. Save the resulting images -- both the GP image and the HSB.

// ---- Get image information ----
id = getImageID();
title = getTitle();
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);
getDimensions(width, height, channels, slices, frames);

// ---- Subtract background from a user-specified ROI ----

// get the ROI
setTool("freehand");
waitForUser("Mark background", "Draw a background area that works for both channels, then click OK");
run("Set Measurements...", "mean redirect=None decimal=3");

// measure background in Gel channel
Stack.setChannel(Chan_Gel);
run("Measure");
gelMeasBackground = getResult("Mean",nResults-1); // from the last row of the table

// measure background in LC channel
Stack.setChannel(Chan_LC);
run("Measure");
lcMeasBackground = getResult("Mean",nResults-1); // from the last row of the table

// subtract background from each channel

run("Split Channels");

GelChannelName = "C"+Chan_Gel+"-"+title;
selectWindow(GelChannelName);
run("Subtract...", "value="+gelMeasBackground);
run("Add...", "value=1"); // prevent 0 values

LCChannelName = "C"+Chan_LC+"-"+title;
selectWindow(LCChannelName);
run("Subtract...", "value="+lcMeasBackground);
run("Add...", "value=1"); // prevent 0 values

// ---- Calculate the GP ----

// calculate the numerator
imageCalculator("Subtract create 32-bit", GelChannelName,LCChannelName);
selectWindow("Result of "+GelChannelName);
rename("Difference.tif");

// calculate the denominator
imageCalculator("Add create 32-bit", GelChannelName,LCChannelName);
selectWindow("Result of "+GelChannelName);
rename("Sum.tif");

// calculate the ratio
imageCalculator("Divide create 32-bit", "Difference.tif","Sum.tif");
selectWindow("Result of Difference.tif");
rename("GP "+title);



// ---- Make an intensity modulated image ----

// create a new single-channel RGB image to hold the data
IMName = "Intensity Modulated GP "+title;
newImage(IMName, "RGB black", width, height, 1, 1, 1);

// convert the RGB image to the HSB colorspace
selectWindow(IMName);
run("HSB Stack");

// hue is the GP value
selectWindow("GP "+title);
run("Duplicate...", "title=copy_GP");
selectWindow("copy_GP");
//run("Add...", "value=1"); // make all the values positive
run("Conversions...", "scale"); // make sure values are scaled properly when we convert
//run("8-bit"); // possibly omit this?
run("Select All");
run("Copy");
selectWindow(IMName);
setSlice(1); // hue
run("Select All");
run("Paste");

// saturation should be all white (max value)
selectWindow(IMName);
setSlice(2); // saturation
setForegroundColor(255, 255, 255); // white
run("Select All");
run("Fill", "slice");
run("Select None");

// a popular choice for the value is the sum (or average) of the two channels. Here we use the sum.
selectWindow("Sum.tif");
//run("Duplicate...", "title=copy_2");
//selectWindow("copy_2");
//run("8-bit");
run("Select All");
run("Copy");
run("Select None");
//selectWindow("copy_2");
//close(); // the 8-bit copy
selectWindow(IMName);
setSlice(3); // value
run("Select All");
run("Paste");
run("Select None");

// finally convert the HSB image back into RGB color space
selectWindow(IMName);
run("Select None");
run("RGB Color");

// make a calibration bar
selectWindow("copy_GP");
run("Spectrum"); // set the spectrum lut used in HSB conversions
run("Calibration Bar...", "location=[Upper Right] fill=Black label=White number=5 decimal=2 font=12 zoom=1 overlay");
run("To ROI Manager");
selectWindow(IMName);
run("From ROI Manager");
run("Flatten");
rename(IMName+" with color bar");

// ---- Clean up and display ----
selectWindow("copy_GP"); 
close();
selectWindow(IMName);
run("Hide Overlay");
roiManager("reset");
run("Tile");
