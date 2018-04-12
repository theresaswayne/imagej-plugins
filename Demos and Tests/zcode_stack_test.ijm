
run("Mitosis (26MB, 5D stack)");
run("Duplicate...", "title=spindle.tif duplicate channels=2 frames=19");
run("Z Code Stack");
selectWindow("Depth Coded Stack");
rename("original image depth coded.tif");
selectWindow("spindle.tif");
run("Duplicate...", "title=8-bit spindle.tif duplicate");
run("8-bit");
run("Z Code Stack");
selectWindow("Depth Coded Stack");
rename("8-bit image depth coded.tif");
