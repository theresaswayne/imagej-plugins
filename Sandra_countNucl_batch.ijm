// @File(label = "Choose result folder:", style = "directory") myDir


//// count nuclei with Find maxima
//// worka on single stack
//// 2020-01-2020




list = getFileList(myDir);
list = Array.sort(list);

for (i = 0; i < list.length; i++) {
	if (endsWith(list[i], ".tif")) {

//setBatchMode(true);
open(list[i]);
title = list[i];
dotIndex = lastIndexOf(title, ".");
filename = substring(title, 0, dotIndex);

Stack.getDimensions(width, height, ch, slices, frames);
run("Duplicate...", "duplicate channels=2");
run("Gaussian Blur...", "sigma=2 stack");
run("Clear Results");

run("Clear Results");
for (j = 1; j <= frames; j++) {
	Stack.setFrame(j);
	run("Find Maxima...", "prominence=300 output=Count");	
}
saveAs("results",myDir+File.separator+filename+"_Results.txt");
close();
close();
//setBatchMode(false);

}
}
