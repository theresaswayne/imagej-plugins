// @File(label = "Input directory", style = "directory") inputdir
// @File(label = "Output directory", style = "directory") outputdir
// @String (label = "File suffix", value = ".nd2") fileSuffix
// @Integer (label="Channel to save:", style="slider", min=1, max=7, stepSize=1) Channel


//  ImageJ macro to save individual single channel images from hyperstacks (series, Z, and/or T), ignoring other channels
//  Based on a macro by Martin Hoehne, August 2015
//  Updated 2023, 2025, Theresa Swayne: use script parameters, use standard batch functions to process folder and image, save specific channels/Z
//  Limitations: Supports up to 7 channels

//  -------- Suggested text for acknowledgement -----------
//   "These studies used the Confocal and Specialized Microscopy Shared Resource 
//   of the Herbert Irving Comprehensive Cancer Center at Columbia University, 
//   funded in part through the NIH/NCI Cancer Center Support Grant P30CA013696."

// ---- Setup ----

// TODO: fix failure to open each series
// TODO: keep track of time elapsed


while (nImages>0) { // clean up open images
	close(); 
	}

print("\\Clear"); // clear Log window

setBatchMode(true); // faster performance

run("Bio-Formats Macro Extensions"); // enables access to macro commands


// ---- Commands to run the processing functions ---

// image counter
filenum = -1;
print("Starting");
processFolder(inputdir, outputdir, fileSuffix, Channel); // actually do the processing
print("Finished");
setBatchMode(false);

// clean up
while (nImages > 0) {
	close(); 
	}

// ---- Function for processing folders ----
function processFolder(input, output, extension, chan) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i=0; i<list.length; i++)  {
	    showProgress(i+1, list.length);
	    if(File.isDirectory(input + File.separator + list[i])) { 
			processFolder(input + File.separator+ list[i], output, suffix, chan); 
			} // handles nested folders
	    else if (endsWith(list[i], extension)) {
	    	print("found a matching file at", list[i]);
	    	filenum = filenum + 1;
	       	processImage(input, list[i], output, filenum, chan); 
	       	} 
		}
	}

	
// ------- Function for processing individual files

function processImage(inputdir, name, outputdir, fileNumber, channel) {

	imagePath = inputdir + File.separator + name;
	print("Processing file",fileNumber," at path" ,imagePath);	
	
	// ---- Check image metadata before opening ----
	Ext.setId(imagePath);//-- Initializes the given path (filename).
	Ext.getSeriesCount(seriesCount); //-- Gets the number of image series in the active dataset.
	print("there are",seriesCount,"series in this file");
	seriesDigits = floor(log(seriesCount)/log(10)) + 1; // log10 of the series count to tell us how many digits to pad to

	// determine the name of the file without extension
	dotIndex = lastIndexOf(name, ".");
	basename = substring(name, 0, dotIndex); 
	extension = substring(name, dotIndex);
	
	print("the basename of the file is", basename);
	//Ext.setSeries(i);
	
	for (j=1; j<=seriesCount; j++) {  // loop through series (multipoints)
  		print("Opening series",j);
  		Ext.getSeriesName(serName);
		print("The series name is", serName);
		// ---- Check image metadata before opening ----
		Ext.getSizeC(channels);
		Ext.getSizeZ(slices);
		Ext.getSizeT(frames);
		
		if (channels < channel) {
			print("Invalid channel selection for", imagePath);
			break; // to the next image file
		}
		
		padCount = IJ.pad(j, seriesDigits);
		
		// we can EITHER select a channel range OR use a virtual stack. 
		// to accommodate larger images we'll err on the side of caution and use virtual stack
		run("Bio-Formats", "open=&imagePath color_mode=Default view=Hyperstack stack_order=XYCZT use_virtual_stack series_"+j);

		// make a substack with only the desired channel (this can take time because it must read from memory)
		run("Make Subset...", "channels="+channel+" slices=1-"+slices+" frames=1-"+frames);
		

		// save as image sequence
		// TODO: make a folder for each image
		print("splitting");
		//selectImage(basename+"-1");
		run("Image Sequence... ", "dir=" + outputdir + File.separator + " format=TIFF name=" + basename + "_m" + padCount + "_c" + channel);
			
		run("Close All");
		run("Collect Garbage"); // free up memory
        
   		} // series loop
	} // end processImage function
