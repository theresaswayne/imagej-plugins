// @File(label = "Input directory", style = "directory") dir1
// @File(label = "Output directory", style = "directory") dir2
// @String(label = "File suffix", value = ".tif") suffix

// Note: DO NOT DELETE OR MOVE THE FIRST 3 LINES -- they supply essential parameters
// batch_cfos_arc_Coloc.ijm
// IJ macro to measure object-based colocalization of nuclei
// Theresa Swayne, Columbia University, 2017
// input: two single-channel single-slice images, and corresponding ROIsets from cfosArc_analysis macro, in same directory
// output: mask of overlapping cells, and custom table: 
//     # C1 cells, # C2 cells, # C1+C2 cells, % C1 cells with C2 label, % C2 cells with C1 label.
// 
// usage: Run the nuclear analysis first to get the ROI sets.  Have them in the same directory as the channel images. 
//        Then run the macro, and when prompted select the C1 image. They need to have names starting with C1 and C2 
// 


// SETUP ----------------------------------

// saves data as csv, preserves headers, preserves row number for copy/paste
run("Input/Output...", "file=.csv copy_row save_column save_row"); 

// add headers to results file
headers = "Filename,Channel,Total Cells,Colocalized Cells,Fraction Colocalized";
File.append(headers,dir2  + File.separator+ "Coloc.csv");

// these values can be changed -- keep consistent with the channel analysis macro. Overlapping areas can be a bit smaller (MIN) 
CELLMIN = 50 // microns^2
CELLMAX = 300 // microns^2

// PROCESSING ------------------------------
setBatchMode(true);
n=0;
processFolder(dir1); // this actually executes the functions

// FOLDER PROCESSING FUNCTION
function processFolder(dir1) {
   list = getFileList(dir1);
   for (i=0; i<list.length; i++) {
        if(File.isDirectory(dir1 + File.separator + list[i])) { // process subfolders recursively
			processFolder("" + dir1 +File.separator+ list[i]);}
        else if (endsWith(list[i], suffix)) // filter by suffix
        	if (startsWith(list[i], "C1"))
           		processImage(dir1, list[i]);
           	else if (startsWith(list[i], "C2")) {
           		continue; // C2s are processed along with their C1 counterpart
           	}
    }
}

// IMAGE PROCESSING FUNCTION

function processImage(dir1, name) {
   open(dir1+File.separator+name);
   print(n++, name);

	// parsing file names
	dotIndex = indexOf(name, ".");
	basename = substring(name, 3, dotIndex); // omitting the channel name
	roiname = "Coloc-"+ basename;
	channel = substring(name, 1, 2);

	function makeMask(image, channel) 
		{
		// creates and saves a mask from a ROIset and image that are open
		// leaves the original image and mask open
	
		roiManager("deselect"); // select none 
		roiManager("Combine"); // if none are selected, all will be combined
		roiManager("Delete"); // delete individual rois
		roiManager("Add"); // the combined ROI so there is now only one in the list
		roiManager("Select", 0); // the combined roi
		run("Create Mask");
		roiManager("reset");

		maskName = "C"+channel+"-Mask-";
		selectWindow("Mask");
		rename(maskName);
		// save(dir2+File.separator+maskName+basename+".tif"); // optional saving the mask
		return;
		}


	// make masks for each channel using the saved ROI sets
	for (c = 1; c <= 2; c ++)
		{
		channel = d2s(c,0); // decimal to string, no decimal places
		
		if (!(isOpen("C"+channel+"-"+basename+".tif"))) // open the channel image
			{
			open(dir1 + File.separator + "C" + channel + "_" + basename + ".tif");
			}

		id = getImageID();
		roiManager("Open", dir1 + File.separator +"RoiSet_C" + channel + "_" + basename + ".zip"); // open the ROI set
		makeMask(id, channel);
	
		selectImage(id); // close the original image
		close();
		}

	// multiply masks to find the overlapping areas - result is 255 where both masks are 255, and 0 elsewhere  
	imageCalculator("Multiply create","C1-Mask-","C2-Mask-");
	rename("Overlap-"+basename+".tif"); // the result window is automatically selected
	// save(dir1 + File.separator +"Overlap-"+basename+".tif");

	selectWindow("C1-Mask-");
	rename("C1-Mask-"+basename+".tif"); // renaming gives us the filename in the results table

	selectWindow("C2-Mask-");
	rename("C2-Mask-"+basename+".tif");

	function AnalyzePartic(image)
		{
		// prints a particle summary for the specified image ID
		run("Analyze Particles...", "size=" + CELLMIN + "-" + CELLMAX + " exclude summarize");
		return;
		}

	run("Clear Results");

	// get cell counts for channel 1
	selectWindow("C1-Mask-"+basename+".tif");
	id1 = getImageID();
	AnalyzePartic(id1);
	selectImage(id1);
	close();

	// get cell counts for channel 2
	selectWindow("C2-Mask-"+basename+".tif");
	id2 = getImageID();
	AnalyzePartic(id2);
	selectImage(id2);
	close();

	// get cell counts for overlap
	selectWindow("Overlap-"+basename+".tif");
	idOverlap = getImageID();
	AnalyzePartic(idOverlap);
	selectImage(idOverlap);
	run("Close");

	// read data from the Summary window
	selectWindow("Summary"); 
	lines = split(getInfo(), "\n"); 
	headings = split(lines[0], "\t"); 
	C1Values = split(lines[1], "\t"); 
	C1Name = C1Values[0];
	C2Values = split(lines[2], "\t"); 
	C2Name = C2Values[0];
	OverlapValues = split(lines[3], "\t"); 

	// convert strings to integers
	C1Count = parseInt(C1Values[1]);
	C2Count = parseInt(C2Values[1]);
	OverlapCount = parseInt(OverlapValues[1]);

	// calculate the percent overlap and convert to string
	C1withC2 = OverlapCount/C1Count;
	C2withC1 = OverlapCount/C2Count;
	strC1withC2 = d2s(C1withC2, 3);
	strC2withC1 = d2s(C2withC1, 3);

	// collect the colocalization data
	// format: image name, n cells, n cells colocalized with other label, % colocalized with other label
	firstRow = C1Name+",1," + C1Count+ ","+ OverlapCount + "," + strC1withC2;
	secondRow = C2Name + ",2," + C2Count+ "," + OverlapCount + "," + strC2withC1;
	colocResults = firstRow + "\n" + secondRow;
	
	// save the table
//	selectWindow("Cell_Colocalization");
//	String.copyResults;
//	newResults=String.paste;
//	newResults = substring(newResults,0,lengthOf(newResults)-1); // strip the final newline 
//	newResults = replace(newResults, "\t",","); // replace tabs with commas for csv
	File.append(colocResults,dir2 + File.separator + "Coloc.csv");
//	saveAs("Text", path+"coloc-"+basename+".xls");

	// clean up
//	selectWindow("Cell_Colocalization");
//	run("Close");
	selectWindow("Summary"); 
	run("Close");
//	selectWindow("ROI Manager");
//	run("Close");

} // end of processImage function

