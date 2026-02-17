//@ File(label = "Nup label image:") NupFile
//@ File(label = "Erg label image:") ErgFile
//@ File(label = "Output folder:", style = "directory") outDir
//@ Double(label = "Distance criterion (µm):", value = 0.9) dist
// closest_object_3d.ijm
// Detect and visualize 3D closest objects within a specified distance
// input: 2 label image stacks; distance criterion
// For each object in the first input stack, the closest object (center-center) is found using 3D Suite
// If the center-center distance is <= the criterion, the two objects are counted as associated
// output: 2 label image stacks containing all associated objects; 
//		3D Manager size/position measurements for all objects and associated objects;
//		table giving IDs of closest associated Erg object for each Nup object, or 0 if no associated object

// TODO: Catch error and show message if no objects found in either of the original datasets 
// TODO: re-organize output so it has the file name in the title like normal, no subfolders

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
while (isOpen("ClosestObjectsWithinCriterion.csv")) {
 	selectWindow("ClosestObjectsWithinCriterion.csv"); 
 	run("Close" );
}

// options: important to NOT show as IJ results table beause it conflicts with the other table
run("3D Manager Options", "volume feret centroid_(pix) distance_to_surface objects radial_distance distance_between_centers=0 distance_max_contact=0 drawing=Contour use_0");

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

// create a folder for all the results

imageBasename = substring(nupBasename, 0, dotIndex-16); // remove "-c4_resliced_seg.tif"
//subFolder = outDir + File.separator + imageBasename + File.separator;
//File.makeDirectory(subFolder);
//if (!File.exists(subFolder))
//      exit("Unable to create directory");

// find objects matching criteria
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


// initialize 3D functions
run("3D Manager");
Ext.Manager3D_Reset();
run("3D Manager Options", "volume feret centroid_(pix) distance_to_surface objects radial_distance distance_between_centers=0 distance_max_contact=0 drawing=Contour use_0");

// generate an image of only the associated Nups
selectWindow(nupTitle);
run("Duplicate...", "title=nupAssoc duplicate");
Ext.Manager3D_AddImage();
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


// save the measurements
// Ext.Manager3D_SaveResult("M",subFolder + "nupAssocMeas.csv");
Ext.Manager3D_SaveResult("M",outDir + File.separator + imageBasename + "_nupAssocMeas.csv");
//Ext.Manager3D_SaveResult(outDir + File.separator + imageBasename + "_nupAssocMeas.csv");
Ext.Manager3D_CloseResult("M");

// --- Erg assoc ----

// initialize 3D functions
Ext.Manager3D_Reset();
run("3D Manager");
Ext.Manager3D_Reset();
// options: important to NOT show as IJ results table beause it conflicts with the other table
run("3D Manager Options", "volume feret centroid_(pix) centroid_(unit) distance_to_surface objects radial_distance distance_between_centers distance_max_contact drawing=Contour use_0");

// generate an image of only the associated Ergs
selectWindow(ergTitle);
run("Duplicate...", "title=ergAssoc duplicate");
Ext.Manager3D_AddImage();
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

// --- get measurements for all objects
Ext.Manager3D_Reset();
run("3D Manager Options", "volume feret centroid_(pix) centroid_(unit) distance_to_surface objects radial_distance distance_between_centers=0 distance_max_contact=0 drawing=Contour use_0");

// add nup objects and rename
selectWindow(nupTitle);
Ext.Manager3D_AddImage();
Ext.Manager3D_SelectAll();
Ext.Manager3D_Rename("Nup");
Ext.Manager3D_DeselectAll();
Ext.Manager3D_Count(nupCount); // number of nup objects

selectWindow(ergTitle);
Ext.Manager3D_AddImage();
Ext.Manager3D_Count(allCount); // total number of objects
Ext.Manager3D_SelectFor(nupCount, allCount, 1); // select all the ergs
Ext.Manager3D_Rename("Erg");
Ext.Manager3D_DeselectAll();

// save results; M is prepended whether you want it or not
Ext.Manager3D_Measure(); 
//Ext.Manager3D_SaveResult("M",subFolder + "allMeas.csv");
Ext.Manager3D_SaveResult("M", outDir + File.separator + imageBasename + "_allMeas.csv");

Ext.Manager3D_CloseResult("M");

// clean up
while (nImages>0) { // clean up open images
	selectImage(nImages);
	close();
	}
print("\\Clear"); // clear Log window

Ext.Manager3D_Reset();

// close one or more results windows
while (isOpen("Results")) {
     selectWindow("Results"); 
     run("Close" );
}
while (isOpen(distTableName)) {
 	selectWindow(distTableName); 
 	run("Close" );
}
