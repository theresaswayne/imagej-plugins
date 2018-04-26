
// you need to place a segmented line selection on the image before running the macro

roiManager("Add"); // adds the selection you made

pixelSize=0.4587; // image pixel size in µm - based on 2.18 pixels per micron
dist=10; // the distance interval in µm
pixelDist = dist/pixelSize; // distance interval in pixels


num = 30;  // number of repetitions

for (i=0; i<num; i++) { 
	roiManager("Select", i);
	roiManager("translate", 0, -pixelDist);  // negative number makes the next line closer to the top of the image
	roiManager("Add");
}
roiManager("Show All"); //Show all selections of the ROI Manager.