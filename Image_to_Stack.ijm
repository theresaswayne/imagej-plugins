
// insert number of images here
numImages = 21;

for (i = 0; i < numImages-1; i++) {
	run("Add Slice");
	run("Previous Slice [<]");
	run("Select All");
	run("Copy");
	run("Next Slice [>]");
	run("Paste");
}
