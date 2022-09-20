// @File(label = "Select input file") input
// @File(label = "Output directory", style = "directory") output

// cervix_preprocess_tiff.ijm

// Use for cervical whole-slide TIF images
// Subtracts background and corrects color balance
// Splits colors using "H DAB" scheme and saves constituent colors

// Usage: Open the tiff image, crop it (not necessary to save), and run the macro

// get image name
id = getImageID();
origTitle = getTitle();

name = File.getName(input);
//dotIndex = indexOf(name, ".");
//basename = substring(name, 0, dotIndex);
basename = File.nameWithoutExtension;
rgbName = basename+"_corrected.tif";

// subtract background
run("Subtract Background...", "rolling=300 light");

// correct color
run("BIOP SimpleColorBalance");

// save RGB corrected image
saveAs ("tiff", output+File.separator+rgbName);

selectImage(id);
close();

// split colors
selectWindow(rgbName);
run("Colour Deconvolution", "vectors=[H DAB] hide");

// close Colour 3 image -- not needed
selectWindow(rgbName+"-(Colour_3)");
close();

// save hematoxylin image -- will be used to measure total area
selectWindow(rgbName+"-(Colour_1)");
run("Set Scale...", "distance=1 known=2.5595 pixel=1 unit=um");
saveAs ("tiff", output+File.separator+basename+"_H.tif");
close();

// save DAB image -- will be used to detect antibody staining
selectWindow(rgbName+"-(Colour_2)");
run("Set Scale...", "distance=1 known=2.5595 pixel=1 unit=um");
saveAs ("tiff", output+File.separator+basename+"_DAB.tif");





