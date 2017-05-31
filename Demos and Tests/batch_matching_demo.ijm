// @File(label = "Input directory", style = "directory") dir1
// @File(label = "Output directory", style = "directory") dir2
// @String(label = "File suffix", value = ".zvi") suffix

// Note: DO NOT DELETE OR MOVE THE FIRST 3 LINES -- they supply essential parameters

// batch_matching_demo.ijm
// ImageJ macro to open images that don't have corresponding text files
// Theresa Swayne, tcs6@cumc.columbia.edu

 
// SETUP ------------
setBatchMode(true);

splitDir= dir1 + File.separator + "Results";
File.makeDirectory(splitDir);

// EXECUTION ------------
processFolder(dir1); // walks through the folders


function processFolder(dir1) 
	{
	list = getFileList(dir1);
	for (i=0; i<list.length; i++) 
		{
	    if (File.isDirectory(dir1 + File.separator + list[i]))
	    	{
			processFolder("" + dir1 +File.separator+ list[i]);
			}
	    else if (endsWith(list[i], suffix) && (!isCompleted(dir1,list[i])))
	    	{
	       	processImage(dir1, list[i]); // actually processes the image
	    	}
	    else {print("skipping",list[i]);}
		}
	}

function isCompleted(dir1, name) 
	{
	basename = substring(name, 0, (lengthOf(name)-4)); // assumes 3-letter extension
	return (File.exists(dir1+File.separator+basename+" completed.txt"))
	}

function processImage(dir1, name) 
	{
	print("processing",name);
	basename = substring(name, 0, (lengthOf(name)-4)); // assumes 3-letter extension
	run("Bio-Formats Importer", "open=[" + dir1+File.separator+name + "] autoscale color_mode=Default split_channels view=Hyperstack stack_order=XYCZT");
	// your processing code or function call goes here
    print("completed");
    selectWindow("Log");
    saveAs("Text", dir1 + File.separator + basename + " completed.txt"); // saves in the input directory
    print("\\Clear");

    // closes extra split-channels images
	while (nImages > 0)  // works on any number of channels
		{
		close();
		}
	}

setBatchMode(false);
