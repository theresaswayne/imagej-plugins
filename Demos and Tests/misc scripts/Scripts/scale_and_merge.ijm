
// scale_and_merge.ijm

// Create some images with the appropriate initial scales (delete these lines if using your own images)
newImage("large", "8-bit ramp", 1236, 862, 1);
newImage("small", "8-bit white", 554, 412, 1);
selectWindow("large");
run("Set Scale...", "distance=15.17 known=1 unit=um");
selectWindow("small");
run("Set Scale...", "distance=4.9 known=1 unit=um");

// Replace "large", "small", and "small-scaled" with your image names!

// Give the smaller image the same scale as the larger one
// Scale factor = 15.17/4.9 = 3.096
selectWindow("small");
run("Scale...", "x=3.096 y=3.096 width=1715 height=1275 interpolation=Bicubic create title=small-scaled");

// Expand the canvas of the other image so that they have the same dimensions
selectWindow("large");
run("Canvas Size...", "width=1715 height=1275 position=Center zero");

// Merge channels
run("Merge Channels...", "c1=large c2=small-scaled create keep");
