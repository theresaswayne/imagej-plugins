// this example makes a stack of blurred versions of the
// current slice with a range of radii.

radius = getNumber("Maximal radius?", 5);

title = "Blurred stack of " + getTitle();
run("Duplicate...", "title=[" + title + "]");
run("Select All");
run("Copy");
for (i = 1; i <= radius; i++) {
        run("Add Slice");
        run("Paste");
        run("Gaussian Blur...", "radius=" + i);
}