path    = getDirectory("Choose a Directory");
list    = getFileList(path);
length  = list.length;

File.makeDirectory(path + "ImagingBG/");

//Images substract

for (i=0; i<length; i++) { // loop through images in directory
             
	n=i+1;
	open(path+list[i]);
	img = File.nameWithoutExtension();
	selectWindow(img+".tif");
	run("ROI Manager...");
	//setTool("rectangle");
	waitForUser("Draw ROI, then hit OK");  
	
	if (selectionType==-1)
		exit("This macro requires an area selection");
	for (j=1; j<=nSlices; j++) { // loop through slices in image
		setSlice(j);
		getStatistics(area, mean);
		run("Select None");
		run("Subtract...", "value="+mean);
		run("Restore Selection");                
	}
	saveAs ("Tiff", path + "ImagingBG/BG" + i);  
	run("Close All");  
}
