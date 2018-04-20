// @File(label = "Input image 1", style = "file") path1
// @File(label = "Input image 2", style = "file") path2
// @File(label = "Output directory", style = "directory") outputDir

run("Close All");
//path = File.openDialog("Choose a File");
open(path1)
macro "DAPI cell count - 20X" {
	run("Unsharp Mask...", "radius=1 mask=0.60");
	run("Subtract Background...", "rolling=50");
	run("8-bit");
	setAutoThreshold("Triangle dark");
	//run("Threshold...");
	//setThreshold(50, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Watershed");
	run("Analyze Particles...", "size=100-Infinity display clear summarize add");
	close();
//path = File.openDialog("Choose a File");
open(path2)
macro "Count particles in ROI - 20X" {
original = getImageID()
run("Duplicate...", " ");
copy = getImageID();
selectImage(copy);
run("Median...", "radius=2");
selectImage(original)
imageCalculator("Subtract", original,copy);
run("Auto Threshold", "method=Triangle dark");
run("From ROI Manager");
name1 = getTitle; 
            dotIndex = indexOf(name1, "."); 
            title1 = substring(name1, 0, dotIndex);
n = roiManager("count");
        for (i=0; i<n; i++)  {
        roiManager("select", i);
         run("Analyze Particles...", "size=1-30 circularity=0.00-1.00 show=Nothing display summarize");}
selectWindow("Summary of "+name1);
saveAs("Text",outputDir+ File.separator+ title1+".txt"); 
run("Close All");
