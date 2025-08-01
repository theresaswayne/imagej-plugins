//@File(label = "Input file", style = "file") inputFile
//@File(label = "Output directory", style = "directory") outputDir

//Cells counting in case of cytoplasmatic staining
//Count all DAPI and them all cell positive for marker and dysplay a percentage ratio//

//open file
run("Bio-Formats", "open=&inputFile");
	
// Split channels and get their names
// --- Split channels and rename ---
run("Split Channels");
wait(500); // wait for windows to open

list = getList("image.titles");

selectWindow(list[0]);
rename("DAPI");

selectWindow(list[1]);
rename("CH2");

// clear ROIs from ROI Manager
roiManager("reset");

// determine the name of the file without extension
dotIndex = lastIndexOf(list[0], ".");
DAPIbasename = substring(list[0], 0, dotIndex); 
CH2basename = substring(list[1], 0, dotIndex); 
	
// --- COUNT DAPI ---
selectWindow("DAPI");
run("Enhance Contrast", "saturated=0.35");
run("Auto Threshold", "method=Otsu white");
run("Convert to Mask");
run("Watershed");
run("Analyze Particles...", "size=10-Infinity show=Nothing add"); // add each particle to ROI Manager

roiManager("deselect"); // ensure that all ROIs will be saved
DAPIroiName = DAPIbasename + "_ROIs.zip"
roiManager("save", outputDir + File.separator + DAPIroiName); // save ROIs
roiManager("reset"); // remove all of the ROIs

dapiCount = nResults;
run("Clear Results");

// --- COUNT CH2 ---
selectWindow("CH2");
run("Enhance Contrast", "saturated=0.35");
run("Auto Threshold", "method=Otsu white");
run("Convert to Mask");
run("Watershed");
run("Analyze Particles...", "size=10-Infinity show=Nothing add");

roiManager("deselect"); // ensure that all ROIs will be saved
CH2roiName = CH2basename + "_ROIs.zip"
roiManager("save", outputDir + File.separator + CH2roiName);
roiManager("reset"); // remove all of the ROIs

ch2Count = nResults;
run("Clear Results");

// --- CALCULATE RATIO ---

if (dapiCount > 0) {
    ratio = (ch2Count / dapiCount) * 100;
} else {
    ratio = 0;
}

// --- DISPLAY RESULTS ---
print("DAPI+ nuclei count: " + dapiCount);
print("CH2+ cells count: " + ch2Count);
print("CH2/DAPI ratio (%): " + d2s(ratio, 2) + "%");

summaryLine = "CH2/DAPI: " + ch2Count + " / " + dapiCount + " → " + d2s(ratio, 2) + "%";
print(summaryLine);