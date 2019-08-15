

title = getTitle();
path = getDirectory("image");

dotIndex = indexOf(title, ".");
extension = substring(title, dotIndex);
basename = substring(title, 0, dotIndex);

//print("The name of the image is",title);
//print("The folder is",path);
//print("The basename is",basename);

run("Split Channels");

run("Merge Channels...", "c1=[C3-"+title+"] c2=[C2-"+title+"] c3=[C4-"+title+"] create ignore");
run("Z Project...", "projection=[Average Intensity]");
run("RGB Color");
saveAs("Tiff", path + basename + "_AVG.tif");

selectWindow("C1-"+ title);
run("Z Project...", "projection=[Average Intensity]");
run("RGB Color");
saveAs("Tiff", path + basename + "_AVGa.tif");
