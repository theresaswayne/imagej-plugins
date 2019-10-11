run("Bio-Formats Macro Extensions"); // required to open ND2 files
//path = "/Users/confocal/Desktop/Yunkyoung\ Lee\ images/Red\ vs\ green\ cells/Group\ \#1/\[Merged\]\ Group\#1.tif"

//run("Bio-Formats Importer", "open=path autoscale color_mode=Default view=Hyperstack stack_order=XYCZT split_channels");

path = getDirectory('Choose Directory');
filelist = getFileList(path);
output = path+"MergedJPG"+File.separator;

File.makeDirectory(output);

print("Starting");

setBatchMode(true);
for (i=0; i< filelist.length; i++) {
	if (endsWith(filelist[i], ".tif")) {
		name = path + File.separator + filelist[i];
		print("Processing",name);
		run("Bio-Formats", "open= ["+name+"] color_mode=Default view=Hyperstack stack_order=XYCZT color_mode=Default split_channels");
		red = filelist[i]+" - C=1";
		green = filelist[i]+" - C=0";
		print("Merging",red,"and",green);
		run("Merge Channels...", "c1=["+red+"] c2=["+green+"] create");
		saveAs("jpeg", output + filelist[i]);
		run("Close");
		run("Close");
	}
}
setBatchMode(false);
