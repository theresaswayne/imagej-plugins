// splits multi-channel CZI or ND2 stack, saves channel 2 for czi, 3 for nd2
// kludgeriffic macro for batch macro window by TCS 4/2017

path = getDirectory("image");
id = getImageID();
title = getTitle();
print("title is",title);
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);

run("Split Channels");

if (endsWith(title,".nd2"))
	{
	print(title+" is an nd2");
	selectWindow("C3-"+title);
	saveAs("tiff", path+getTitle);	
	}
else
	{
	print(title+" must be a czi");
	selectWindow("C2-"+title);
	saveAs("tiff", path+getTitle);	
	}
while (nImages > 0) { // works on any number of channels
	close();
	}