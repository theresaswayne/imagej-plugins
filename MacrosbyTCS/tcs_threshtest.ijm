
// threshold test
// Theresa Swayne Februrary 2011
// Purpose: Test multiple thresholds on Nile Red images

imageName = getTitle();
threshMethod = newArray("Default","IsoData","MaxEntropy","Minimum","Moments","Otsu");

for (i=0; i<threshMethod.length; i++) {

	setAutoThreshold(threshMethod[i] + " dark");
	getThreshold(lower,upper);
	print(threshMethod[i]+"\t"+lower);
	run("Convert to Mask");
	run("Open");
	run("Watershed");
	run("Analyze Particles...", "size=1000-6000 pixel circularity=0.70-1.00 show=Masks exclude summarize");
	run("Create Selection");
	run("Add to Manager");
	selectWindow("Mask of "+imageName);
	close();
	selectWindow(imageName);
	run("Revert");
}

run("Set Measurements...", "area mean standard integrated display redirect=None decimal=2");
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");

n = roiManager("count");
for (i=0; i<n; i++) {
     roiManager("select", i);
     roiManager("Measure");
}
