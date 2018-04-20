

path = getDirectory("Choose a Directory");
filelist = getFileList(path);
splitDir= path + "Results";
File.makeDirectory(splitDir);

function process(index) {
	// placeholder for image processing
	print("processing",index);
}
for (i=0; i< filelist.length; i++) {

	// extract the filename without 3-letter extension, without opening the file

	name=filelist[i];
	basename = substring(name, 0, (lengthOf(name)-3)); // assumes 3-letter extension
	print("checking for ",path+basename+" completed.txt");
	print("text file exists?",!File.exists(path+basename+" completed.txt"));
	print("is a zvi?",(endsWith(filelist[i], ".zvi")));
	
	if (!File.exists(path+basename+" completed.txt")&&endsWith(filelist[i], ".zvi")) {
		run("Bio-Formats Importer", "open=[" + path + filelist[i] + "] autoscale color_mode=Default split_channels view=Hyperstack stack_order=XYCZT");
		process(i);
	    print("completed");
	    selectWindow("Log");
	    saveAs("Text", path+basename+" completed.txt");
        print("\\Clear");
		}
   }

