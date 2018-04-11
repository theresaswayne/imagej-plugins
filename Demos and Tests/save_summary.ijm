// @File(label = "Output directory", style = "directory") outputDir

run("Blobs (25K)");
setOption("BlackBackground", false);
run("Make Binary");
run("Analyze Particles...", "display summarize");
selectWindow("Summary");
saveAs("Results", outputDir + File.separator +  "Summary.txt");
run("Close");
