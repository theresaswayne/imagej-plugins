run("Bat Cochlea Volume (19K)");
selectWindow("bat-cochlea-volume.tif");
run("Select All");
run("Copy");
run("Add Slice");
run("Paste");
run("Next Slice [>]");
run("Select All");
run("Copy");
run("Add Slice");
run("Paste");

setSlice(6);
