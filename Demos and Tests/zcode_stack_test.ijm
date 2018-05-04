
// zcode_stack_test.ijm
// Demonstrates apparent bug in Z Code Stack command with dim, 16-bit images

// TODO: determine if this is related to a small # slices
// TODO: prove relation to pixel value by enhancing contrast first

 // Download a sample image
run("Mitosis (26MB, 5D stack)");

// take just the spindle channel, Z code, and project
run("Duplicate...", "title=spindle.tif duplicate channels=2 frames=19");
run("Z Code Stack");
// as of 5/2018 this image shows only noise
selectWindow("Depth Coded Stack");
rename("original image depth coded.tif");
run("Z Project...", "projection=[Max Intensity]");

selectWindow("spindle.tif");
run("Duplicate...", "title=8-bit spindle.tif duplicate");
// convert the original image to 8-bit before running Z Code Stack
run("8-bit");
run("Z Code Stack");
selectWindow("Depth Coded Stack");
rename("8-bit image depth coded.tif");
// project the result. As of 5/2018 this image shows the desired result, with visible spindle fibers in different colors
run("Z Project...", "projection=[Max Intensity]");

