// @File(label = "Input directory", style = "directory") inputdir
// @File(label = "Output directory", style = "directory") outputdir
// @String(label = "File suffix", value = ".nd2") inputsuffix
// @Integer(label="Ki67 cutoff value",value=700,persist=false) cutoff

// Note: DO NOT DELETE OR MOVE THE FIRST 4 LINES -- they supply essential parameters

// ki67_count.ijm
// ImageJ macro
// Theresa Swayne, tcs6 at cumc.columbia.edu, 2018

// Counts DAPI-labeled nuclei and calculates the percentage labeled by Ki67, 
// based on an empirically determined cutoff value entered by the user
// Input: Folder of 2-channel single-slice ND2 images with DAPI first
// Output: 
//	1) ROIs for each DAPI-labeled nucleus; 
//	2) Table of all DAPI nuclei measured in the Ki67 channel; 
//	3) Summary table of total and Ki67-positive cells in each image. 

// TO USE THIS MACRO: 
// 	Place your images in a folder.
//	Create a separate output folder to store the results.
//	Open this file in Fiji and click Run.

// ---- Setup

run("Bio-Formats Macro Extensions"); // enables access to macro commands
run("Set Measurements...", "area mean centroid display redirect=None decimal=3");
run("Clear Results");
roiManager("reset");
run("Input/Output...", "file=.csv save_column"); // save as csv, include headers, omit row number
while (nImages > 0)
	{
	close();
	}

// add headers to results files
countHeaders = "Filename,Total Cells,Ki67-Positive Cells";
File.append(countHeaders,outputdir  + File.separator+ "Counts.csv");

// measurementHeaders = "Filename,Area,Mean,X,Y";
// File.append(measurementHeaders, outputdir  + File.separator+ "Measurements.csv");

setBatchMode(true); 
n = 0;

// --- Commands to run the processing

splitChannelsFolder(inputdir, inputsuffix); // split each image into channels
processFolder(inputdir, ".tif"); // actually do the analysis
run("Clear Results");
showMessage("Finished.");
setBatchMode(false);

// ------- functions for processing folders

function splitChannelsFolder(inputdir, suffix) 
	{
	list = getFileList(inputdir);
 	for (i=0; i<list.length; i++) 
   		{
   		isSingleChannel = ((startsWith(list[i], "C1")) || (startsWith(list[i], "C2")) || (startsWith(list[i], "C3")));
        if(File.isDirectory(inputdir + File.separator + list[i])) {
			splitChannelsFolder("" + inputdir +File.separator+ list[i]);}
        else if (!isSingleChannel && (endsWith(list[i], suffix))) {     // avoids error if there are C1, C2, C3 images in the folder
			splitChannelsImage(inputdir, list[i]);}
    	}
	}


function processFolder(inputdir, suffix) 
{
list = getFileList(inputdir);
for (i=0; i<list.length; i++) 
		{
    if(File.isDirectory(inputdir + File.separator + list[i])){
		processFolder("" + inputdir +File.separator+ list[i]);}
    else if (endsWith(list[i], suffix))
    	{
    	if (startsWith(list[i], "C1")){
       		processImage(inputdir, list[i]);} // process as many images as there are C1's
    	} 
	}
}

// ------- functions for processing individual files

function splitChannelsImage(inputdir, name) 
	{
	path = inputdir + File.separator + name;
	run("Bio-Formats", "open=path color_mode=Default view=Hyperstack");
	run("Split Channels");
	while (nImages > 0)  // works on any number of channels
		{
		saveAs ("tiff", inputdir+File.separator+getTitle);	// save split channels in the *input* folder
		close();
		}
	}

function processImage(inputdir, name) 
	{

	// ---- Open image and get its name
	
	open(inputdir+File.separator+name);
	print("processing image",name);
	dotIndex = indexOf(name, ".");
	basename = substring(name, 3, dotIndex); // taking off the channel number
	maskName = basename + "_mask.tif";
	id = getImageID();
	
	roiManager("reset");
	
	// process a copy of the image
	selectImage(id);
	// square brackets allow handing of filenames containing spaces
	run("Duplicate...", "title=" + "[" +maskName+ "] duplicate"); 
	selectWindow(maskName);
	
	// ---- Detect DAPI nuclei
	
	setAutoThreshold("MaxEntropy dark");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	selectWindow(maskName);
	run("Close-"); 
	run("Fill Holes"); 
	run("Open");
	run("Watershed");
	
	// ---- Open Ki67 image and analyze nuclei

	C2name = "C2-" + basename + ".tif";
	open(inputdir + File.separator + C2name);
	run("Set Measurements...", "area mean centroid display redirect=&C2name decimal=3");

	selectWindow(maskName);
	run("Analyze Particles...", "size=20-Infinity display exclude add");
	
	// save results and ROI set for individual nuclei
	roiManager("Deselect");
	roiManager("Save", outputdir + File.separator + basename + "_DAPI_ROIs.zip");
	saveAs("Results", outputdir + File.separator + basename + "_Measurements.csv");
	
	// ---- Determine cell counts
	
	DAPIcount = nResults();
	
	// calculate positive nuclei (above cutoff)
	
	Ki67count = 0;
	positiveROIs = newArray();
	
	for (resultnum = 0; resultnum < DAPIcount; resultnum++) {
		cellMean = getResult("Mean",resultnum);
		if (cellMean >= cutoff) {
			Ki67count++; // count cell as positive
			positiveROIs = Array.concat(positiveROIs, resultnum); // save ROI index of that cell
			}
		}
	
	if (positiveROIs.length > 0) {
		roiManager("select", positiveROIs);
	 	roiManager("save selected", outputdir + File.separator + basename + "_Ki67_ROIs.zip");
		}

	// append counts to table of image name/total cells/Ki67-positive cells
	
	cellCounts = basename + "," + DAPIcount + "," + Ki67count;
	print("results line =",cellCounts);
	File.append(cellCounts, outputdir  + File.separator + "Counts.csv");

	// ---- Clean up

	while (nImages > 0)
		{
		close();
		}	
	run("Clear Results");
	roiManager("reset");
}	// ========= End processing loop

// clean up
run("Set Measurements...", "area mean centroid display redirect=None decimal=3");