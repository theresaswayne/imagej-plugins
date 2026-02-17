//@ File(label = "Nup label image folder:", style = "directory") NupFolder
//@ File(label = "Erg label image folder:", style = "directory") ErgFolder
//@ File(label = "Output folder:", style = "directory") outDir
// @String(label = "File suffix", value = ".tif") suffix
//@ Double(label = "Distance criterion (µm):", value = 0.9) dist
// find_object_associations_batch.ijm
// Detect and visualize 3D closest objects within a specified distance
// input: 2 label image stacks; distance criterion
// For each object in the first input stack, the closest object (center-center) is found using 3D Suite
// If the center-center distance is <= the criterion, the two objects are counted as associated
// output: 2 label image stacks containing all associated objects; 
//		3D Manager size/position measurements for all objects and associated objects;
//		table giving IDs of closest associated Erg object for each Nup object, or 0 if no associated object

// Limitation: Erg count of associations could be inaccurate if the same LD is associated with 2 Nup aggregates


// setup general
while (nImages>0) { // clean up open images
	selectImage(nImages);
	close();
	}
print("\\Clear"); // clear Log window


// close one or more results windows
while (isOpen("Results")) {
     selectWindow("Results"); 
     run("Close" );
}

// options: important to NOT show as IJ results table beause it conflicts with the other table
run("3D Manager Options", "volume feret centroid_(pix) centroid_(unit) distance_to_surface objects radial_distance distance_between_centers=0 distance_max_contact=0 drawing=Contour use_0");

// dataset counter
n = 0;

// collect association counts in a table with a time/date stamp
headerString = "ImageName,TotalNup,TotalErg,AssociatedNup";
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
timeString = "" + year + "-" + month + "-" + dayOfMonth + "-" + hour + "-" + minute; // have to start with empty string
summaryName = timeString + "_results.csv";
summaryFile = outDir + File.separator + summaryName;
if (File.exists(summaryFile)==false) { // start the file with headers
	File.append(headerString, summaryFile);	
	print("Added headings");
    }


// ---- Commands to run the processing functions

processFolder(NupFolder, ErgFolder, outDir, suffix, dist); // actually do the analysis
showMessage("Finished.");
//setBatchMode(false);

// ---- Function for processing folders
function processFolder(inputNup, inputErg, outputdir, suffix, distance) 
	{
	list = getFileList(inputNup);
	for (i=0; i<list.length; i++) 
		{
	    if(File.isDirectory(inputNup + File.separator + list[i])) {
			processFolder("" + inputNup +File.separator+ list[i]); }
	    else if (endsWith(list[i], suffix)) {
	       	processImage(inputNup, inputErg, list[i], outputdir, suffix, distance); } 
		}
	}

// ------- Function for processing individual files

function processImage(nupFolder, ergFolder, name, outDir, suffix, dist) 
	{
	// ---- Open image and get name, info
	
	print("processing image", name);

	while (nImages>0) { // clean up open images
		selectImage(nImages);
		close();
		}
	// open datasets
	open(nupFolder + File.separator + name);
	nupTitle = getTitle();
	// determine the name of the file without extension
	dotIndex = lastIndexOf(nupTitle, ".");
	nupBasename = substring(nupTitle, 0, dotIndex);
	
	imageBasename = substring(nupBasename, 0, dotIndex-16); // remove "-c4_resliced_seg.tif"
	ergName = imageBasename + "-c4_resliced_seg.tif";
	
	if (File.exists(ergFolder + File.separator + ergName)) {
		open(ergFolder + File.separator + ergName);
		ergTitle = getTitle();
		dotIndex = lastIndexOf(ergTitle, ".");
		ergBasename = substring(ergTitle, 0, dotIndex);
	}
	else {
		print("No matching Erg image",ergName, "for",nupTitle);
		return; // to next image in folder loop
	}
	
	// initialize 3D functions
	run("3D Manager");
	Ext.Manager3D_Reset();
	//run("3D Manager Options", "volume feret centroid_(pix) centroid_(unit) distance_to_surface objects radial_distance distance_between_centers=0 distance_max_contact=0 drawing=Contour use_0");
	
	// check for absence of objects in each channel
	selectWindow(nupTitle);
	Stack.getStatistics(voxelCount, mean, min, max, stdDev);
	if (max == 0) {
		print("No objects in Nup image");
		nupEmpty = true;
	}
	else {
		nupEmpty = false;
	}
	
	selectWindow(ergTitle);
	Stack.getStatistics(voxelCount, mean, min, max, stdDev);
	if (max == 0) {
		print("No objects in Erg image");
		ergEmpty = true;
	}
	else {
		ergEmpty = false;
	}
	
	// --- get measurements for all objects
	
	if (!nupEmpty) {
		// add nup objects and rename
		selectWindow(nupTitle);
		Ext.Manager3D_AddImage();
		Ext.Manager3D_SelectAll();
		Ext.Manager3D_Rename("Nup");
		Ext.Manager3D_DeselectAll();
		Ext.Manager3D_Count(nupCount); // number of nup objects
	}
	else {
		nupCount = 0;
	}
	if (!ergEmpty) {
		// add erg objects and rename
		selectWindow(ergTitle);
		Ext.Manager3D_AddImage();
		Ext.Manager3D_Count(allCount); // total number of objects
		Ext.Manager3D_SelectFor(nupCount, allCount, 1); // select all the ergs
		Ext.Manager3D_Rename("Erg");
		Ext.Manager3D_DeselectAll();
		ergCount = allCount - nupCount;
	}
	else {
		ergCount = 0;
	}
	// save results; M is prepended whether you want it or not
	Ext.Manager3D_Measure(); 
	//Ext.Manager3D_SaveResult("M",subFolder + "allMeas.csv");
	Ext.Manager3D_SaveResult("M", outDir + File.separator + imageBasename + "_allMeas.csv");
	Ext.Manager3D_CloseResult("M");
	
	// find objects meeting association criteria
	if (!nupEmpty && !ergEmpty) {
		run("3D Distances Closest", "image_a="+nupBasename+" image_b="+ergBasename+" number=1 distance=DistCenterCenterUnit distance_maximum="+dist);
	
		// save the data
		distTableName = imageBasename + "_assoc.csv";
		saveAs("Results", outDir + File.separator + distTableName);
		
		// read the results
		
		rowCount = getValue("results.count");
		nupAssocs = newArray();
		nupNonAssocs = newArray();
		ergAssocs = newArray();
		
		assocCount = 0;
		nonAssocCount = 0;
		
		if (rowCount > 0) { // if there are any association (behavior varies; may be one row per object or not)
		
			for (i = 0; i < rowCount; i++) { // go through the table
			
				nupNum = Table.get("LabelObj", i); // each nup object will have a row whether or not it meets criteria
				ergNum = Table.get("O1", i); // will be 0 if no match
				
				// check if there is a matching Erg object and if so, add to the array of assocs
				if (ergNum > 0) {
					
					nupAssocs[assocCount] = nupNum;
					ergAssocs[assocCount] = ergNum;
					assocCount = assocCount + 1;
				}
				else {
					nupNonAssocs[nonAssocCount] = nupNum;
					nonAssocCount = nonAssocCount + 1;
				}
			}
			
			print("Associated Nups:");
			Array.print(nupAssocs);
			print("Non-associated Nups:");
			Array.print(nupNonAssocs);
			print("Associated Ergs:");
			Array.print(ergAssocs);
		}
		else {
			print("No data in table between",nupTitle, "and",ergTitle);
		}
		print("total associations: ",assocCount);
		
		// collect association counts in a table
		//headerString = "ImageName,TotalNup,TotalErg,AssociatedNup";
		summaryString = imageBasename + "," + nupCount + "," + ergCount + "," + assocCount;
		File.append(summaryString, summaryFile);
	
		// generate an image of only the associated Nups
		Ext.Manager3D_Reset();
		selectWindow(nupTitle);
		run("Duplicate...", "title=nupAssoc duplicate");
		Ext.Manager3D_AddImage();
		Ext.Manager3D_SelectAll();
		Ext.Manager3D_Rename("Nup");
		Ext.Manager3D_DeselectAll();
		
		Ext.Manager3D_MultiSelect();
		// object numbers start at 1, ROI indices start at 0
		for (j = 0; j < nonAssocCount; j++) {
			nupObject = nupNonAssocs[j];
			nupIndex = nupObject-1;
			print("Selecting ROI index",nupIndex,",Nup object number",nupObject);
			Ext.Manager3D_Select(nupIndex);
		}
		
		Ext.Manager3D_Erase(); // fill with black in the duplicated stack
		Ext.Manager3D_DeselectAll();
		Ext.Manager3D_Measure(); // measure only the assoc nups
		
		// save the image
		selectWindow("nupAssoc");
		//saveAs("Tiff", subFolder  + "nupAssoc.tif");
		saveAs("Tiff", outDir  + File.separator + imageBasename + "_nupAssoc.tif");
		
		// save the measurements for Nups with associations
		// Ext.Manager3D_SaveResult("M",subFolder + "nupAssocMeas.csv");
		Ext.Manager3D_SaveResult("M",outDir + File.separator + imageBasename + "_nupAssocMeas.csv");
		//Ext.Manager3D_SaveResult(outDir + File.separator + imageBasename + "_nupAssocMeas.csv");
		Ext.Manager3D_CloseResult("M");
		
	
		// generate an image of only the associated Ergs
		Ext.Manager3D_Reset();
		selectWindow(ergTitle);
		run("Duplicate...", "title=ergAssoc duplicate");
		Ext.Manager3D_AddImage();
		Ext.Manager3D_SelectAll();
		Ext.Manager3D_Rename("Erg");
		Ext.Manager3D_DeselectAll();
		
		// make a list of nonassociated Ergs, that is everything that is not in the ergAssocs array
		Ext.Manager3D_Count(ergCount);
		ergNonAssocs = Array.getSequence(ergCount+1);
		ergNonAssocs = Array.deleteValue(ergNonAssocs, 0);// start with a list of all erg obj numbs starting with 1
		for (idx = 0; idx < assocCount; idx++) {
			ergObj = ergAssocs[idx];
			ergNonAssocs = Array.deleteValue(ergNonAssocs, ergObj); // delete the object number from the array and make the array shorter
		}
		ergNonAssocCount = lengthOf(ergNonAssocs);
		
		Ext.Manager3D_MultiSelect();
		// object numbers start at 1, ROI indices start at 0
		
		for (k = 0; k < ergNonAssocCount; k++) { // loop over the non-assoc ergs in the roi mgr
		
			ergObject = ergNonAssocs[k];
			ergIndex = ergObject-1;
			print("Selecting ROI index",ergIndex,",Erg object number",ergObject);
			Ext.Manager3D_Select(ergIndex);
		}
		
		Ext.Manager3D_Erase(); // fill with black in the duplicated stack
		Ext.Manager3D_DeselectAll();
		Ext.Manager3D_Measure(); // measure only the assoc ergs
		
		// save the image
		selectWindow("ergAssoc");
		saveAs("Tiff", outDir + File.separator  + imageBasename + "_ergAssoc.tif");
		
		// save the measurements
		//Ext.Manager3D_SaveResult("M",subFolder + "ergAssocMeas.csv");
		Ext.Manager3D_SaveResult("M",outDir + File.separator + imageBasename + "_ergAssocMeas.csv");
		Ext.Manager3D_CloseResult("M");
	}
	else {
		print("No objects in one or both images. Association not determined.");
	}
	
	// clean up
	while (nImages>0) { // clean up open images
		selectImage(nImages);
		close();
		}
	
	Ext.Manager3D_Reset();
	
	// close one or more results windows
	while (isOpen("Results")) {
	     selectWindow("Results"); 
	     run("Close" );
	}
	distTableName = imageBasename + "_assoc.csv";
	while (isOpen(distTableName)) {
	 	selectWindow(distTableName); 
	 	run("Close" );
	}
} // end processImage function




