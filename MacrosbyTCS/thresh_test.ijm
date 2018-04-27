// threshold test
// Theresa Swayne Februrary 2011
// Purpose: Test multiple thresholds on Nile Red images

imageName = getTitle();
threshMethod = newArray("Default","Isodata","MaxEntropy","Minimum","Moments","Otsu");

for (i=0; i<threshMethod.length; i++) {

	setAutoThreshold(threshMethod[i]);
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
