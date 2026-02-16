//@ File(label = "Nup label image director:") NupDir
//@ File(label = "Erg label image:") ErgDir
//@String (label = "File suffix", value = ".tif") fileSuffix
//@ File(label = "Output folder:", style = "directory") outputDir
//@ Double(label = "Distance criterion (µm):", value = 0.9) dist
// closest_object_3d_batch.ijm
// Measure and visualize 3D closest objects
// input: 2 label image stacks in a specific order; distance criterion
// output: label stacks containing all objects that are within the given distance (center-center) of an object in the other stack

// Theresa Swayne, 2026
//  -------- Suggested text for acknowledgement -----------
//   "These studies used the Confocal and Specialized Microscopy Shared Resource 
//   of the Herbert Irving Comprehensive Cancer Center at Columbia University, 
//   funded in part through the NIH/NCI Cancer Center Support Grant P30CA013696."

//	Limitation -- cannot have >1 dots in the filename
// 	

// ---- Setup ----

while (nImages>0) { // clean up open images
	selectImage(nImages);
	close();
}
print("\\Clear"); // clear Log window


// ---- Run ----

print("Starting");

// Call the processFolder function, including the parameters collected at the beginning of the script

processFolder(inputDir, outputDir, fileSuffix, numericalParameter);

// Clean up images and get out of batch mode

while (nImages > 0) { // clean up open images
	selectImage(nImages);
	close(); 
}
setBatchMode(false);
print("Finished");


// ---- Functions ----

function processFolder(input, output, suffix, param) {

	// this function searches for files matching the criteria and sends them to the processFile function
	filenum = -1;
	print("Processing folder", input);
	// scan folder tree to find files with correct suffix
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i])) {
			processFolder(input + File.separator + list[i], output, suffix); // handles nested folders
		}
		if(endsWith(list[i], suffix)) {
			filenum = filenum + 1;
			processFile(input, output, list[i], filenum, param); // passes the filename and parameters to the processFile function
		}
	}
} // end of processFolder function


function processFile(inputFolder, outputFolder, fileName, fileNumber, parameter) {
	
	// this function processes a single image
	
	path = inputFolder + File.separator + fileName;
	print("Processing file",fileNumber," at path" ,path);	

	// determine the name of the file without extension
	dotIndex = lastIndexOf(fileName, ".");
	basename = substring(fileName, 0, dotIndex); 
	extension = substring(fileName, dotIndex);
	
	print("File basename is",basename);
	
	// open the file
	run("Bio-Formats", "open=&path");
		
		
		// setup general
		while (nImages>0) { // clean up open images
			selectImage(nImages);
			close();
			}
	print("\\Clear"); // clear Log window
	
	
	// open datasets
	open(NupFile);
	nupTitle = getTitle();
	// determine the name of the file without extension
	dotIndex = lastIndexOf(nupTitle, ".");
	nupBasename = substring(nupTitle, 0, dotIndex);
	
	
	open(ErgFile);
	ergTitle = getTitle();
	dotIndex = lastIndexOf(ergTitle, ".");
	ergBasename = substring(ergTitle, 0, dotIndex);
	
	// find objects matching criteria
	run("3D Distances Closest", "image_a="+nupBasename+" image_b="+ergBasename+" number=1 distance=DistCenterCenterUnit distance_maximum="+dist);
	
	// save the data
	distTableName = "ClosestObjectsWithinCriterion.csv";
	saveAs("Results", outDir + File.separator + distTableName);
	
	// read the results
	
	rowCount = getValue("results.count");
	nupColocs = newArray();
	nupNonColocs = newArray();
	ergColocs = newArray();
	
	colocCount = 0;
	nonColocCount = 0;
	
	if (rowCount > 0) { // if there are any colocalization (behavior varies; may be one row per object or not)
	
		for (i = 0; i < rowCount; i++) { // go through the table
		
			nupNum = Table.get("LabelObj", i); // each nup object will have a row whether or not it meets criteria
			ergNum = Table.get("O1", i); // will be 0 if no match
			
			// check if there is a matching Erg object and if so, add to the array of colocs
			if (ergNum > 0) {
				
				nupColocs[colocCount] = nupNum;
				ergColocs[colocCount] = ergNum;
				colocCount = colocCount + 1;
			}
			else {
				nupNonColocs[nonColocCount] = nupNum;
				nonColocCount = nonColocCount + 1;
			}
		}
		
		print("Colocalizing Nups:");
		Array.print(nupColocs);
		print("Non-colocalizing Nups:");
		Array.print(nupNonColocs);
		print("Colocalizing Ergs:");
		Array.print(ergColocs);
	}
	else {
		print("No data in table between",nupTitle, "and",ergTitle);
	}
	print("total colocalizations: ",colocCount);
	
	
	// initialize 3D functions
	run("3D Manager");
	Ext.Manager3D_Reset();
	// options: important to NOT show as IJ results table beause it conflicts with the other table
	run("3D Manager Options", "volume feret centroid distance_to_surface objects radial_distance distance_between_centers distance_max_contact drawing=Contour use_0");
	
	// generate an image of only the colocalizing Nups
	selectWindow(nupTitle);
	run("Duplicate...", "title=nupColoc duplicate");
	Ext.Manager3D_AddImage();
	Ext.Manager3D_DeselectAll();
	
	Ext.Manager3D_MultiSelect();
	// object numbers start at 1, ROI indices start at 0
	for (j = 0; j < nonColocCount; j++) {
		nupObject = nupNonColocs[j];
		nupIndex = nupObject-1;
		print("Selecting ROI index",nupIndex,",Nup object number",nupObject);
		Ext.Manager3D_Select(nupIndex);
	}
	
	Ext.Manager3D_Erase(); // fill with black in the duplicated stack
	Ext.Manager3D_DeselectAll();
	Ext.Manager3D_Measure(); // measure only the coloc nups
	
	// save the image
	selectWindow("nupColoc");
	saveAs("Tiff", outDir + File.separator + "nupColoc.tif");
	
	// save the measurements
	Ext.Manager3D_SaveResult("M",outDir + File.separator + "nupColocMeas.csv");
	Ext.Manager3D_CloseResult("M");
	
	
	// --- Erg coloc ----
	
	// initialize 3D functions
	Ext.Manager3D_Reset();
	run("3D Manager");
	Ext.Manager3D_Reset();
	// options: important to NOT show as IJ results table beause it conflicts with the other table
	run("3D Manager Options", "volume feret distance_to_surface objects radial_distance distance_between_centers distance_max_contact drawing=Contour use_0");
	
	// generate an image of only the colocalizing Ergs
	selectWindow(ergTitle);
	run("Duplicate...", "title=ergColoc duplicate");
	Ext.Manager3D_AddImage();
	Ext.Manager3D_DeselectAll();
	
	// make a list of noncolocalizing Ergs, that is everything that is not in the ergColocs array
	Ext.Manager3D_Count(ergCount);
	ergNonColocs = Array.getSequence(ergCount+1);
	ergNonColocs = Array.deleteValue(ergNonColocs, 0);// start with a list of all erg obj numbs starting with 1
	for (idx = 0; idx < colocCount; idx++) {
		ergObj = ergColocs[idx];
		ergNonColocs = Array.deleteValue(ergNonColocs, ergObj); // delete the object number from the array and make the array shorter
	}
	ergNonColocCount = lengthOf(ergNonColocs);
	
	Ext.Manager3D_MultiSelect();
	// object numbers start at 1, ROI indices start at 0
	
	for (k = 0; k < ergNonColocCount; k++) { // loop over the non-coloc ergs in the roi mgr
	
		ergObject = ergNonColocs[k];
		ergIndex = ergObject-1;
		print("Selecting ROI index",ergIndex,",Erg object number",ergObject);
		Ext.Manager3D_Select(ergIndex);
	}
	
	Ext.Manager3D_Erase(); // fill with black in the duplicated stack
	Ext.Manager3D_DeselectAll();
	Ext.Manager3D_Measure(); // measure only the coloc ergs
	
	// save the image
	selectWindow("ergColoc");
	saveAs("Tiff", outDir + File.separator + "ergColoc.tif");
	
	// save the measurements
	Ext.Manager3D_SaveResult("M",outDir + File.separator + "ergColocMeas.csv");
	Ext.Manager3D_CloseResult("M");
	
	
		
		// save the output
		outputName = basename + "_processed.tif";
		saveAs("tiff", outputFolder + File.separator + outputName);
		close();
		
	
} // end of processFile function
	


