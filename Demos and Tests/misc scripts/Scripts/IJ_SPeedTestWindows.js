// modified from Brandon Hurr IJ forum Apr 2016
imp = IJ.openImage("http://imagej.nih.gov/ij/images/clown.jpg");
show();

for (i=0; i<99; i++) {
	run("Duplicate...", " ");
}