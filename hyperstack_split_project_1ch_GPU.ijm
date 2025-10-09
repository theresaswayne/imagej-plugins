// @File(label = "Input directory", style = "directory") inputdir
// @File(label = "Output directory", style = "directory") outputdir
// @String (label = "File suffix", value = ".nd2") fileSuffix
// @Integer (label="Channel to save:", style="slider", min=1, max=7, stepSize=1) Channel


//  ImageJ macro to save individual single channel Z projection images from hyperstacks (series, Z, and/or T), ignoring other channels
//  Based on a macro by Martin Hoehne, August 2015
//  Updated 2023, 2025, Theresa Swayne: use script parameters, use standard batch functions to process folder and image, save specific channels/Z
//  Limitations: Supports up to 7 channels

//  -------- Suggested text for acknowledgement -----------
//   "These studies used the Confocal and Specialized Microscopy Shared Resource 
//   of the Herbert Irving Comprehensive Cancer Center at Columbia University, 
//   funded in part through the NIH/NCI Cancer Center Support Grant P30CA013696."

// ---- Setup ----

// TODO: Handle both channels using a checkbox input or 2 sliders

while (nImages>0) { // clean up open images
	close(); 
	}

print("\\Clear"); // clear Log window

setBatchMode(true); // faster performance

//Let's start with the initialization of the GPU:

run("CLIJ2 Macro Extensions", "cl_device=");
Ext.CLIJ2_clear();
run("Bio-Formats Macro Extensions"); // enables access to macro commands -- note only one "ext" seems to work at a time

// ---- Commands to run the processing functions ---

// image counter
filenum = -1;
print("Starting");
startTime = getTime();

processFolder(inputdir, outputdir, fileSuffix, Channel); // actually do the processing

endTime = getTime();
elapsedTime = endTime - startTime;
print("Finished in", elapsedTime/1000, "sec");
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
	    //showProgress(i+1, list.length);
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
	run("Bio-Formats Macro Extensions"); // enables access to macro commands
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
	
	for (j=0; j<seriesCount; j++) {  // loop through series (multipoints)
		run("Bio-Formats Macro Extensions"); // enables access to macro commands
  		print("Opening series",j+1);
  		Ext.setId(imagePath);//-- Initializes the given path (filename).
  		Ext.setSeries(j) // internal series names start with 0 
  		Ext.getSeriesName(serName);
		print("The series name is", serName);

		// ---- Check image metadata before opening ----
		Ext.getSizeC(channels);
		Ext.getSizeZ(slices);
		Ext.getSizeT(frames);
		print("The image has", channels, "channels,", slices, "slices, and",frames, "frames");
		
		if (channels < channel) {
			print("Invalid channel selection for", imagePath);
			break; // to the next image file
		}
		
		padCount = IJ.pad(j+1, seriesDigits); // using the apparent series name (starting with 1)
		frameDigits = floor(log(frames)/log(10)) + 1; // log10 of the frame count to tell us how many digits to pad to

		// we can EITHER select a channel range OR use a virtual stack. 
		// to accommodate larger images we'll err on the side of caution and use virtual stack
		// brackets support paths containing spaces
		run("Bio-Formats", "open=["+imagePath+"] color_mode=Default view=Hyperstack stack_order=XYCZT use_virtual_stack series_"+j);
		
		serTitle = getTitle();
//		/*
//		# Push images to GPU
//		*/
//		time = getTime();
//		Ext.CLIJ2_push(serTitle);
//		print("Pushing one image to the GPU took " + (getTime() - time) + " msec");
		print("Z projecting");
		// loop over time points
		run("CLIJ2 Macro Extensions", "cl_device=");
		for (t = 0; t < frames; t += 1) { 
			// move forward in time in the dataset
			selectWindow(serTitle);
			Stack.setFrame(t + 1); // ImageJ's frame-counter is 1-based
			
			// process channel of choice
			Stack.setChannel(channel);
			Ext.CLIJ2_pushCurrentZStack(serTitle);
			Ext.CLIJ2_maximumZProjection(serTitle, max_projection_c1);
			//Ext.CLIJ2_pull(max_projection_c1);
			padFrame = IJ.pad(t, frameDigits);
			saveName = basename + "_max_m" + padCount + "_c"+ channel+"_t"+padFrame+".tif";
			
			Ext.CLIJ2_saveAsTIF(max_projection_c1, outputdir+File.separator+saveName);

			// process channel 2
//			selectWindow(input);
//			Stack.setChannel(2);
//			Ext.CLIJ2_pushCurrentZStack(input);
//			Ext.CLIJ2_maximumZProjection(input, max_projection_c2);
//			Ext.CLIJ2_pull(max_projection_c2);
//			run("Green");
//		
			// merge channels
//			run("Merge Channels...", "c1=" + max_projection_c1 + " c2=" + max_projection_c2 + " create");
			//rename("merged t"+t); 
		}
		// make a substack with only the desired channel (this can take time because it must read from memory)
		//run("Make Subset...", "channels="+channel+" slices=1-"+slices+" frames=1-"+frames);
//		print("Making substack");
//		run("Make Subset...", "channels="+channel);
		//run("Make Subset...", "channels=2 slices=1-5 frames=1-51");


		
		//Ext.CLIJ2_maximumZProjection(serName+"-1", max_proj);

		// optional: create projection, all time frames
		//selectImage(serName+"-1"); // should be the subset
		//run("Z Project...", "projection=[Max Intensity] all");
		
		/*
		# Pull a result image from the GPU
		*/
		
//		time = getTime();
//		Ext.CLIJ2_pull(max_proj);
//		
//		print("Pulling one image from the GPU took " + (getTime() - time) + " msec");
		// save as image sequence
		//print("splitting");

		// note that if there is only one dimension besides C, the numbers will be sequential without identifying t or z
		// if both t and z are present, then the slices and frames will be identified accordingly
		//selectImage(max_projection_c1);
		//run("Image Sequence... ", "dir=["+outputdir + File.separator+"] format=TIFF name=[" + basename + "]_m" + padCount + "_c"+ channel+"_");
			
		run("Close All");
		run("Collect Garbage"); // free up memory
        Ext.CLIJ2_clear();
   		} // series loop
	} // end processImage function
