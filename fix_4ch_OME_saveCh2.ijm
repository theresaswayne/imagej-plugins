// converts 4-channel OME tiff stack to hyperstack, splits channels, and saves channel 2
// TCS 4/2017

path = getDirectory("image");
id = getImageID();
title = getTitle();
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);

run("Stack to Hyperstack...", "order=xyzct channels=4 slices=21 frames=1 display=Color");
run("Split Channels");
selectWindow("C2-"+title);
saveAs("tiff", path+getTitle);	

while (nImages > 0) { // works on any number of channels
	close();
	}