//@ int(label="Channel for numerator of ratio", style = "spinner") Chan_Num
//@ int(label="Channel for denominator of ratio", style = "spinner") Chan_Denom

// ImageJ/Fiji macro to calculate a ratio image from a multichannel image with interactive background selection
// Outputs: a 32-bit image with the ratio values, and an RGB intensity modulated image with calibration bar
// 
// Theresa Swayne, Columbia University, 2022 for Liza Pon

// TO USE: Open a multi-channel image. Run the script. Save the resulting images -- both the ratio data image and the HSB image.

// TODO: Stack compatibility
// TODO: User defined scale for calibration bar
// TODO: Automatic saving
// TODO: Batch


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

// measure background in Numerator channel
Stack.setChannel(Chan_Num);
run("Measure");
NumerMeasBackground = getResult("Mean",nResults-1); // from the last row of the table

// measure background in LC channel
Stack.setChannel(Chan_Denom);
run("Measure");
DenomMeasBackground = getResult("Mean",nResults-1); // from the last row of the table

// subtract background from each channel
run("Split Channels");

NumChannelName = "C"+Chan_Num+"-"+title;
selectWindow(NumChannelName);
run("Subtract...", "value="+NumerMeasBackground);
run("Add...", "value=1"); // prevent 0 values

DenomChannelName = "C"+Chan_Denom+"-"+title;
selectWindow(DenomChannelName);
run("Subtract...", "value="+DenomMeasBackground);
run("Add...", "value=1"); // prevent 0 values

// ---- Calculate the ratio ----

imageCalculator("Divide create 32-bit", NumChannelName,DenomChannelName);
selectWindow("Result of "+NumChannelName);
rename("Ratio "+title);



// ---- Make an intensity modulated image ----

run("Conversions...", "scale"); // adjusts image values to the display range

// create a new single-channel RGB image to hold the data
IMName = "Intensity Modulated Ratio "+title;
newImage(IMName, "RGB black", width, height, 1, 1, 1);

// convert the RGB image to the HSB colorspace
selectWindow(IMName);
run("HSB Stack");

// Set the Hue to the ratio value
selectWindow("Ratio "+title);
run("Duplicate...", "title=copy_ratio");
selectWindow("copy_ratio");
run("Select All");
run("Copy");
selectWindow(IMName);
setSlice(1); // hue component of the HSB image
run("Select All");
run("Paste"); // this rescales to a 0-255 scale based on the current display range which should be the min and max for the 32bit image

// saturation should be all white (max value)
selectWindow(IMName);
setSlice(2); // saturation component of HSB image
setForegroundColor(255, 255, 255); // white
run("Select All");
run("Fill", "slice");
run("Select None");

// popular choices for the value component are the sum or average of the two channels. Here we use the sum.

// calculate the sum of the two channels
imageCalculator("Add create 32-bit", NumChannelName,DenomChannelName);
selectWindow("Result of "+NumChannelName);
rename("Sum.tif");
selectWindow("Sum.tif");
run("Select All");
run("Copy");
run("Select None");

selectWindow(IMName);
setSlice(3); // value component of the HSB image
run("Select All");
run("Paste");
run("Select None");

// finally convert the HSB image back into RGB color space
selectWindow(IMName);
run("Select None");
run("RGB Color");

// make a calibration bar on the ratio image and bring it into the RGB image
selectWindow("copy_ratio");
run("Fire"); // set the lut
//run("Spectrum RGB"); // set the lut
//run("Green Fire Blue"); // set the lut
run("Calibration Bar...", "location=[Upper Right] fill=Black label=White number=5 decimal=2 font=12 zoom=1 overlay");
run("To ROI Manager"); // sends the bar from the overlay to the ROI Mgr
selectWindow(IMName);
run("From ROI Manager"); // brings the calibration bar onto the RGB image
run("Flatten");
rename(IMName+" with color bar");

// ---- Clean up and display all of the windows ----
selectWindow("copy_ratio"); 
close();
selectWindow(IMName);
run("Hide Overlay");
roiManager("reset");
run("Tile");
