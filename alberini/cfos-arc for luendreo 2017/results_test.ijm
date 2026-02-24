homedir = getDirectory("home");
minsize = 10;
maxsize = 250;
run("Blobs (25K)");
setAutoThreshold("Default");
run("Analyze Particles...", "size=&minsize-&maxsize summarize");
IJ.renameResults("Results");
setResult("Slice", 1, "minsize="+minsize)
setResult("Slice", 2, "maxsize="+maxsize)
saveAs("Results", homedir + "summary.xls");