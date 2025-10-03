// @File(label = "Input directory", style = "directory") inputdir
// @File(label = "Output directory", style = "directory") outputdir
//@String (label = "File suffix", value = ".nd2") fileSuffix
// @Boolean(label="Channels to save: Channel 1") C1
// @Boolean(label="Channel 2") C2
// @Boolean(label="Channel 3") C3
// @Boolean(label="Channel 4") C4
// @Boolean(label="Channel 5") C5
// @Boolean(label="Channel 6") C6
// @Boolean(label="Channel 7") C7

//  ImageJ macro to save individual multichannel images from hyperstacks (Z and/or T)
//  Based on a macro by Martin Hoehne, August 2015
//  Updated 2023, 2025, Theresa Swayne: use script parameters, use standard batch functions to process folder and image, save specific channels/Z
//  Limitations: Supports up to 7 channels

//  -------- Suggested text for acknowledgement -----------
//   "These studies used the Confocal and Specialized Microscopy Shared Resource 
//   of the Herbert Irving Comprehensive Cancer Center at Columbia University, 
//   funded in part through the NIH/NCI Cancer Center Support Grant P30CA013696."

// ---- Setup ----

// TODO: fix failure to open each series
// TODO: fix failure to merge channels (low priority)



while (nImages>0) { // clean up open images
	selectImage(nImages);
	close();
}
print("\\Clear"); // clear Log window

setBatchMode(true); // faster performance

run("Bio-Formats Macro Extensions"); // enables access to macro commands

// set up which channels will be used
channelList = newArray(7);

channelList[0] = C1;
channelList[1] = C2;
channelList[2] = C3;
channelList[3] = C4;
channelList[4] = C5;
channelList[5] = C6;
channelList[6] = C7;

// assemble channel range
// find the start, end, and step
//Array.getStatistics(channelList, min, max, mean, std);

selectedChannels = newArray(); 
for (i = 0; i < 7; i++) {
	if (channelList[i] == 1) {
		chan = i+1;
		selectedChannels = Array.concat(selectedChannels, chan);
		}
	}
print("Selected channels");
Array.print(selectedChannels);



// ---- Commands to run the processing functions ---

// image counter
filenum = -1;
	
processFolder(inputdir, outputdir, fileSuffix, selectedChannels); // actually do the processing
showMessage("Finished.");
setBatchMode(false);
// clean up
while (nImages > 0) {
	close(); }


// ---- Function for processing folders ----
function processFolder(input, output, extension, chans) 
	{
	list = getFileList(input);
	list = Array.sort(list);
	for (i=0; i<list.length; i++)  {
	    showProgress(i+1, list.length);
	    if(File.isDirectory(input + File.separator + list[i])) { 
			processFolder("" + input +File.separator+ list[i], output, suffix, chans); } // handles nested folders
	    else if (endsWith(list[i], extension)) {
	    	filenum = filenum + 1;
	       	processImage(input, list[i], output, filenum, chans); 
	       	} 
		}
	}

	
// ------- Function for processing individual files

function processImage(inputdir, name, outputdir, fileNumber, channelList) 
	{

	imagePath = inputdir + File.separator + name;
	print("Processing file",fileNumber," at path" ,imagePath);	

	// determine the name of the file without extension
	dotIndex = lastIndexOf(name, ".");
	basename = substring(name, 0, dotIndex); 
	extension = substring(name, dotIndex);
	
	// ---- Check image metadata before opening ----
	Ext.setId(imagePath);//-- Initializes the given path (filename).
	Ext.getSeriesCount(seriesCount); //-- Gets the number of image series in the active dataset.
	seriesDigits = floor(log(seriesCount)/log(10)) + 1; // log10 of the series count to tell us how many digits to pad to
	name=File.nameWithoutExtension;
	
	for (j=1; j<=seriesCount; j++) // loop through series (multipoints)
    	{
			// ---- Check image metadata before opening ----
			Ext.getSizeX(width);
			Ext.getSizeY(height);
			Ext.getSizeZ(slices);
			Ext.getSizeC(channels);
			Ext.getSizeT(frames);
			
			padCount = IJ.pad(j, seriesDigits);
			//run("Bio-Formats", "open=imagePath autoscale color_mode=Default view=Hyperstack stack_order=XYCZT series_"+j);
			
			// find the start and end channels
			Array.getStatistics(channelList, startChannel, endChannel, mean, stdDev);
			
			// open the image in the desired channel range
			//run("Bio-Formats", "open=&imagePath color_mode=Default specify_range view=Hyperstack stack_order=Default series_&j c_begin_1=&startChannel c_end_=&endChannel c_step_=1");
			
			run("Bio-Formats", "open=&imagePath color_mode=Default view=Hyperstack stack_order=Default series_"+j+" virtual");
			
			// TODO: expunge any unwanted channels between start and end
			// run("Make Subset...", "channels=1,2,4");
			// save as image sequence
			// TODO: make a folder for each image
			
			run("Image Sequence... ", "dir=" + outputdir + File.separator + " format=TIFF name=" + name + padCount);
				
			run("Close All");
			run("Collect Garbage"); // free up memory
        
    	} // series loop
	} // end processImage function
   
	
