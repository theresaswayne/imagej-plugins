//@File(label = "Resliced image input directory", style = "directory") imageInputDir
//@File(label = "Segmented image input directory", style = "directory") segInputDir
//@File(label = "Output directory", style = "directory") outputDir
//@String (label = "File suffix", value = ".tif") fileSuffix

// ImageJ/Fiji script to process a batch of images
// Theresa Swayne, 2025-6
//  -------- Suggested text for acknowledgement -----------
//   "These studies used the Confocal and Specialized Microscopy Shared Resource 
//   of the Herbert Irving Comprehensive Cancer Center at Columbia University, 
//   funded in part through the NIH/NCI Cancer Center Support Grant P30CA013696."

// Input: 2 folders, of single-channel fluorescence images and label images showing segmented objects
// Output: Measurements of position, size, intensity (1 table per image)
// File name constraint: The label image name must be the name of the fluorescence image plus "_seg"

//	Limitation -- cannot have >1 dots in the filename
// 	

// Updated to use 3D Manager rather than 3D Object Counter as 3D OC is older and less efficient with memory -- tended to fail on a large (>100 image) dataset
// see also https://mcib3d.frama.io/3d-suite-imagej/plugins/3DManager/3D-Manager-macros/

// ---- Setup ----

while (nImages>0) { // clean up open images
	selectImage(nImages);
	close();
	}
print("\\Clear"); // clear Log window
run("Clear Results");

//setBatchMode(true); // faster performance
run("Bio-Formats Macro Extensions"); // support native microscope files

// collect log in a table with a time/date stamp
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
timeString = "" + year + "-" + month + "-" + dayOfMonth + "-" + hour + "-" + minute; // have to start with empty string
logName = timeString + "_Log.txt";
logFile = outputDir + File.separator + logName;
logStartString = "Batch 3D Measure started " + timeString +"\n";
if (File.exists(logFile)==false) { // start the file with headers
	File.append(logStartString, logFile);	
	print("Created log file");
    }

// ---- Run ----

print("Starting");

// set up measurements
// options: important to NOT show as IJ results table beause it conflicts with the other table
run("3D Manager Options", "volume feret centroid_(pix) centroid_(unit) distance_to_surface objects radial_distance distance_between_centers=0 distance_max_contact=0 drawing=Contour use_0");

// Call the processFolder function, including the parameters collected at the beginning of the script
processFolder(imageInputDir, segInputDir, outputDir, fileSuffix);

// Clean up images and get out of batch mode

while (nImages > 0) { // clean up open images
	selectImage(nImages);
	close(); 
}
//setBatchMode(false);
run("Clear Results");
print("Finished");

// save Log
//selectWindow("Log");
//saveAs("text", outputDir + File.separator + "Log.txt");


// ---- Functions ----

function processFolder(imginput, seginput, output, suffix) {

	// this function searches for files matching the criteria and sends them to the processFile function
	filenum = -1;
	print("Processing folder", imginput);
	// scan folder tree to find files with correct suffix
	list = getFileList(imginput);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(imginput + File.separator + list[i])) {
			processFolder(imginput + File.separator + list[i], seginput, output, suffix); // handles nested folders
		}
		if(endsWith(list[i], suffix)) {
			filenum = filenum + 1;
			processFile(imginput, seginput, output, list[i], filenum); // passes the filename and parameters to the processFile function
		}
	}
} // end of processFolder function


function processFile(imgInputFolder, segInputFolder, outputFolder, imgFile, fileNumber) {
	
	run("Fresh Start");
	// this function processes a single image
	// initialize 3D functions
	run("3D Manager");
	Ext.Manager3D_Reset();
	run("Clear Results");
	
	imgPath = imgInputFolder + File.separator + imgFile;


	// determine the name of the file without extension
	dotIndex = lastIndexOf(imgFile, ".");
	//rawBasename = substring(imgFile, 0, dotIndex); 
	//reslIndex = indexOf(rawBasename, "_resliced");
	//basename = substring(rawBasename, 0, reslIndex);
	basename = substring(imgFile, 0, dotIndex);
	extension = substring(imgFile, dotIndex);
	
	logString = "Processing file " + fileNumber + " at path " + imgPath + " with basename " + basename+ "/n";
	File.append(logString, logFile);	

	// open the image file
	run("Bio-Formats", "open=&imgPath");
	//open(imgPath);
	
	// rename for easier handling
	rename("dup");

	// Duplicate the image
	//dupName = "dup";
	//run("Duplicate...", "title="+dupName+" duplicate");

	// close the original
	//selectWindow(imgFile);
	//close();

	//wait(1000); // a little space to let things catch up
	
	// check for the segmented image
	segFile = basename + "_seg.tif";
	
	// open the segmented image
	segPath = segInputFolder + File.separator + segFile;
	if (!(File.exists(segPath))) {
		logString = "No segmented image found for " + basename + "/n";
		File.append(logString, logFile);
		//print("No segmented image found for", basename);
		close("*");
		while(nImages!=0) wait(500);
		run("Collect Garbage");
		return; // go to next file in folder
	}
	else {
		run("Bio-Formats", "open=&segPath");
		
		// set up options with redirect
		//run("3D OC Options", "volume nb_of_obj._voxels integrated_density mean_gray_value median_gray_value maximum_gray_value centroid dots_size=5 font_size=10 store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to="+dupName);
		//run("3D OC Options", "volume nb_of_obj._voxels integrated_density mean_gray_value median_gray_value maximum_gray_value centroid mean_distance_to_surface median_distance_to_surface bounding_box dots_size=5 font_size=10 store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=dup");

		selectImage(segFile);
		rename("seg");

		// close the original
		//selectWindow(binFile);
		//close();
		
		wait(500); // a little space to let things catch up

		// check for objects (if there are none and we try to measure, it will crash)
		selectWindow("seg");
		Stack.getStatistics(area, mean, min, max, std, histogram);
		if (max == 0) {
			logString = "No objects in " + basename + "/n";
			File.append(logString, logFile);
			//print("No objects in", basename);
			run("Collect Garbage");
			//continue;
			return; // go to next file in folder
		}
		else {
			//run("3D Objects Counter", "threshold=1 slice=10 min.=1 max.=723975 statistics");
			// add segmented objects to the mgr
			selectWindow("seg");
			Ext.Manager3D_AddImage();
			Ext.Manager3D_DeselectAll();
			Ext.Manager3D_Count(objCount); // number of objects
			
			logString = "Found " + objCount + " objects in image " + basename + "/n";
			File.append(logString, logFile);
			//print("Found", objCount, "objects in image", basename);
			
			Ext.Manager3D_Measure(); 
			// save results; M is prepended whether you want it or not
			//Ext.Manager3D_SaveResult("M",subFolder + "allMeas.csv");
			Ext.Manager3D_SaveResult("M", outputDir + File.separator + basename + "_results.csv");
			Ext.Manager3D_CloseResult("M");
			
			// save results
			//statsName = "Statistics for seg redirect to dup"; // renaming the images helps with referring to this window
			//selectWindow(statsName);
			//saveAs("Results", outputDir + File.separator + basename + "_results.csv");
			//run("Close");
			run("Clear Results");
			Ext.Manager3D_Reset();
		}
		// clean up before next cycle
		close("*");
		while(nImages!=0) wait(500);
		run("Collect Garbage");
		wait(500); // a little space to let things catch up
	}	

} // end of processFile function


	