// @File(label = "Input directory", style = "directory") inputdir
// @String(label = "Well to process", value = "A1") wellNumber
// @Integer(label = "Amount to enlarge nuclei (pixels)", value = 15) enlargeRadius
// @File(label = "Output directory", style = "directory") outputdir


//list = getFileList(inputdir);
//	list = Array.sort(list);
//	for (i = 0; i < list.length; i++) {
//		if(File.isDirectory(input + File.separator + list[i]))
//			processFolder(input + File.separator + list[i]);
//		if(endsWith(list[i], suffix))
//			processFile(input, output, list[i]);
//	}


	


// Naming style: C6_-3_1_1_ZProj[Stitched[Deconvolved[Texas Red 586,647]]]_001.tif
// {well}_{-3}_{1}_{chnum}_{proc}[{chname}]_{t}.tif


// summary name should include the folder name, or maybe user enters name?

dirname = File.getName(inputdir);
//“Returns the last name in path’s name sequence.”

print(dirname); // use this to get the folder name, or actually the file will have the folder name if you do import image seq.

//File.getParent(path):
//“Returns the parent of the file specified by path.”

// open one well, one channel, all timepoints 
// in Cytation, ch2 = gfp, ch 3 = dapi
for (channelNumber = 2; channelNumber <= 3; channelNumber ++) {

	run("Image Sequence...", "open=["+inputdir+"] file=(^"+wellNumber+".{0,8}"+channelNumber+"_ZProj) sort use"); // regex in parentheses
	// TODO: get a procname and rename this C2 or C3-procname

	}
// TODO: renumber channels in main macro so nuclei detected in C3

// ^C6.{0,8}2_ZProj
// TODO: merge channels using updated names
// run("Merge Channels...", "c2=#1971632616_ZProj c3=#1971632616_ZProj create");



//getDimensions(width, height, channels, slices, frames);
//print("we have",channels, "channels and",frames,"frames");
