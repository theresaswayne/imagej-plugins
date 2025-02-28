imp = IJ.getImage();

// selected channels 1-3, slice 1
// 	run​(ImagePlus imp, int firstC, int lastC, int firstZ, int lastZ, int firstT, int lastT)

imp = new Duplicator().run(imp, 1, 3, 1, 1, 1, 1);

// selected channels 1-3, slice 2
imp = new Duplicator().run(imp, 1, 3, 2, 2, 1, 1);

// selected channels 1-3, slice 3
IJ.run("Make Substack...", "channels=1-3 slices=3");
