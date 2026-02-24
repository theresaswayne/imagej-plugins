// @File(label = "Input directory", style = "directory") inputdir
// @File(label = "Output directory", style = "directory") outputdir
// @String(label = "File suffix", value = ".tif") suffix

// Note: DO NOT DELETE OR MOVE THE FIRST 3 LINES -- they supply essential parameters

// arc_LC3B_analysis.ijm
// ImageJ macro to identify DAPI nuclei in faint/noisy images at high magnification,
// and measure nuclear and cytoplasmic intensity in two other channels
// Designed for analysis of neuronal markers
// Theresa Swayne, Ph.D, Columbia University, tcs6@cumc.columbia.edu, 2017

// Input: A folder of single-slice, 3-channel images (usually max projections), with nuclei as the 1st channel
// Output: 
//	1) split-channel images
//	2) ROI sets containing nuclear and cytoplasmic regions measured
//	3) a csv file containing measurements of nuclear and cytoplasmic intensity in channels 2 and 3
// Usage: Organize images to be analyzed into a folder. Run the macro.
// Limitations: only multi-channel images can be in the input directory. Do not place previously split images there.
 
// ADJUSTABLE PARAMETERS -------------------------

// Neighborhood values -- larger nuclei require larger values
BLOCKSIZE = 127; // used in contrast enhancement
RADIUS = 40; // used in local thresholding

// Allowable nuclei sizes in microns^2
CELLMIN = 60; // minimum area
CELLMAX = 150; // maximum area

// Radius beyond the nucleus, in microns, that is used to measure cytoplasm
// Larger values may impinge on neighboring cells
// Smaller values may bring in more noise because of fewer pixels measured
CYTOPLASM_THICKNESS = 1

// --------- SETUP 

run("Set Measurements...", "area mean centroid integrated display decimal=2");
run("Clear Results");
print("=============================="); // draws a line in the Log window

// save data as csv, omit headers, preserve row number
run("Input/Output...", "file=.csv copy_row"); 

// add headers to results file
// 0 filename, 1 x centroid, 2 y centroid,
// 3-6 C2 nuclear, 7-10 C2 cyto,
// 11-14 C3 nuclear, 15-18 C3 cyto
headers1 = "Filename,X,Y,";
headers2 = "C2NucArea,C2NucMean,C2NucIntDen,C2NucRawIntDen,C2CytoArea,C2CytoMean,C2CytoIntDen,C2CytoRawIntDen,";
headers3 = "C3NucArea,C3NucMean,C3NucIntDen,C3NucRawIntDen,C3CytoArea,C3CytoMean,C3CytoIntDen,C3CytoRawIntDen";
headers = headers1 + headers2 + headers3;
File.append(headers,outputdir  + File.separator+ "Results.csv");

setBatchMode(true); 
n = 0;

splitChannelsFolder(inputdir); // split each image into channels
processFolder(inputdir); // actually do the analysis
run("Clear Results");
print("Finished.");
setBatchMode(false);


// ------- functions for processing folders

function splitChannelsFolder(inputdir) 
	{
   list = getFileList(inputdir);
   for (i=0; i<list.length; i++) 
   		{
   		isSingleChannel = ((startsWith(list[i], "C1")) || (startsWith(list[i], "C2")) || (startsWith(list[i], "C3")));
//   		print(list[i],isSingleChannel);	
        if(File.isDirectory(inputdir + File.separator + list[i])) {
			splitChannelsFolder("" + inputdir +File.separator+ list[i]);}
        else if (!isSingleChannel && (endsWith(list[i], suffix))) {     // avoids error if there are C1, C2, C3 images in the folder
			splitChannelsImage(inputdir, list[i]);}
    	}
	}

function processFolder(inputdir) 
	{
	list = getFileList(inputdir);
	for (i=0; i<list.length; i++) 
   		{
        if(File.isDirectory(inputdir + File.separator + list[i])){
			processFolder("" + inputdir +File.separator+ list[i]);}
        else if (endsWith(list[i], suffix))
        	{
        	if (startsWith(list[i], "C1")){
           		segmentNucleiImage(inputdir, list[i]);} // nuclei segmentation 
           	else if (startsWith(list[i], "C2")){
           		processC2C3Image(inputdir, list[i]);} // nuclei/cytoplasm intensity analysis
        	} // nothing happens here with C3 images or original images
    	}
	}

// ------- functions for processing individual files

function splitChannelsImage(inputdir, name) 
	{
	open(inputdir+File.separator+name);
	print("splitting",n++, name);
	run("Split Channels");
	while (nImages > 0)  // works on any number of channels
		{
		saveAs ("tiff", inputdir+File.separator+getTitle);	// save split channels in the *input* folder
		close();
		}
	}

function segmentNucleiImage(inputdir, name) 
	{
	// assumes nuclei are in channel 1 of the previously split image, and the filename begins with "C1"
	open(inputdir+File.separator+name);
	print("processing C1 image",name);
	dotIndex = indexOf(name, ".");
	basename = substring(name, 3, dotIndex); // taking off the channel number
	procName = basename + "_processed.tif";
	nucRoiName = basename + "_Nuclei" + ".zip";
	id = getImageID();

	roiManager("reset");

	// process a copy of the image
	selectImage(id);
	// square brackets allow handing of filenames containing spaces
	run("Duplicate...", "title=" + "[" +procName+ "] duplicate"); 
	selectWindow(procName);
	
	// PRE-PROCESSING -----------------------------------------------------------
	run("Enhance Local Contrast (CLAHE)", "blocksize=" + BLOCKSIZE + " histogram=256 maximum=3 mask=*None*"); // accentuate faint nuclei
	run("Gaussian Blur...", "sigma=8"); // merge speckles to make nucleus more cohesive
	
	// SEGMENTATION AND MASK PROCESSING -------------------------------------------
	selectWindow(procName);
	run("Auto Local Threshold", "method=Phansalkar radius=" + RADIUS + " parameter_1=0 parameter_2=0 white");
	run("Convert to Mask");
	
	selectWindow(procName);
	run("Watershed"); // separate touching nuclei
	
	// analyze particles to get initial ROIs
	// note "display" here prevents sporadic error on saving ROIs: "the selection list is empty" ... usually on a repeat run but not always
	run("Analyze Particles...", "size=" + CELLMIN + "-" + CELLMAX + " display exclude clear add"); 
																				
	roiManager("Save", outputdir + File.separator + nucRoiName); 

	// clean up
	selectWindow(name);
	close();
	roiManager("reset");
	run("Clear Results");
	selectWindow(procName);
	close(); 	

	}

function processC2C3Image(inputdir, name)
	{
	// converts nuclear ROIs to bands, 
	// measures nuclear and cytoplasmic (band) intensity in C2 and C3,
	// and saves results in a CSV file

	open(inputdir+File.separator+name); // C2 image
	print("processing C2 image",name);
	dotIndex = indexOf(name, ".");
	basename = substring(name, 3, dotIndex); // take off the channel number
	nucRoiName = basename + "_Nuclei.zip";
	cytRoiName = basename + "_Cyto.zip";

	C3Name = "C3-"+basename+".tif";
	open(inputdir+File.separator+C3Name); // the corresponding C3 image
	print("processing C3 image",C3Name);

	roiManager("Open", outputdir + File.separator + nucRoiName); // ROI set containing nuclei

	// measure C2 nuclear intensity
	selectWindow(name);
	roiManager("multi-measure measure_all append"); // measure individual nuclei and append results

	// measure C3 nuclear intensity
	selectWindow(C3Name);
	roiManager("multi-measure measure_all append");
	
	// create and save cytoplasm band ROIs
	numROIs = roiManager("count");
	roiManager("Deselect");
	run("Select None");
	roiManager("Show None");
	for (index = 0; index < numROIs; index++) // loop through ROIs
		{
		roiManager("Select", index);
		run("Make Band...", "band="+CYTOPLASM_THICKNESS);
		roiManager("Update");
		}

	roiManager("Deselect");
	run("Select None");
	roiManager("Save", outputdir + File.separator + cytRoiName); 

	// measure C2 cytoplasmic intensity
	selectWindow(name);
	roiManager("multi-measure measure_all append");

	// measure C3 cytoplasmic intensity
	selectWindow(C3Name);
	roiManager("multi-measure measure_all append");

	// loop through numROIs (1 line per cell)
	numROIs = roiManager("count");
	for (i = 0; i < numROIs; i++) 
		{
		// gather data as strings from results table:
			// columns: 0 row#, 1 label, 2 area, 3 mean, 4-5 x/y, 6-7 intden/rawintden
			// rows: 0 to n-1 = C2 nuclei
			// n to 2*n-1 = C3 nuclei
			// (2*n) to 3*n-1 = C2 cyto
			// (3*n) to 4*n-1 = C3 cyto

		x = getResultString("X",i); // ith row
		y = getResultString("Y",i);

		C2NucArea = getResultString("Area",i);
		C2NucMean = getResultString("Mean",i);
		C2NucIntDen = getResultString("IntDen",i);
		C2NucRawIntDen = getResultString("RawIntDen",i);
		
		C2CytoArea = getResultString("Area", i+numROIs);
		C2CytoMean = getResultString("Mean", i+numROIs);
		C2CytoIntDen = getResultString("IntDen", i+numROIs);
		C2CytoRawIntDen = getResultString("RawIntDen", i+numROIs);
		
		C3NucArea = getResultString("Area", i+2*numROIs);
		C3NucMean = getResultString("Mean", i+2*numROIs);
		C3NucIntDen = getResultString("IntDen", i+2*numROIs);
		C3NucRawIntDen = getResultString("RawIntDen", i+2*numROIs);
		
		C3CytoArea = getResultString("Area", i+3*numROIs);
		C3CytoMean = getResultString("Mean", i+3*numROIs);
		C3CytoIntDen = getResultString("IntDen", i+3*numROIs);
		C3CytoRawIntDen = getResultString("RawIntDen", i+3*numROIs);
		
		// assemble results:
			// 0 filename, 1 x centroid, 2 y centroid,
			// 3-6 C2 nuclear, 7-10 C2 cyto,
			// 11-14 C3 nuclear, 15-18 C3 cyto

		resultString1 = basename + "," + x + "," + y + ",";
		resultString2 = C2NucArea + ","+ C2NucMean + ","+ C2NucIntDen + ","+ C2NucRawIntDen+ ",";
		resultString3 = C3NucArea + ","+ C3NucMean + ","+ C3NucIntDen + ","+ C3NucRawIntDen+ ",";
		resultString4 = C2CytoArea + ","+ C2CytoMean + ","+ C2CytoIntDen + ","+ C2CytoRawIntDen+ ",";
		resultString5 = C3CytoArea + ","+ C3CytoMean + ","+ C3CytoIntDen + ","+ C3CytoRawIntDen;

		resultString = resultString1 + resultString2 + resultString3 + resultString4 + resultString5;
		
		//  write data for this ROI: 
		File.append(resultString,outputdir + File.separator + "Results.csv");
		}
	
	// clean up
	selectWindow(name);
	close();
	selectWindow(C3Name);
	close();
	roiManager("reset");
	run("Clear Results");

	print("==============================");
	}

