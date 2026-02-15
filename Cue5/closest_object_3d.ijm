//@ File(label = "Nup label image:") NupFile
//@ File(label = "Erg label image:") ErgFile
//@ File(label = "Output folder:", style = "directory") outDir
//@ Double(label = "Distance criterion (µm):", value = 0.9) dist
// closest_object_3d.ijm
// Visualize 3D closest objects
// input: 2 label image stacks in a specific order; distance criterion
// output: multichannel stack with channel 1= all objects in stack 1 that are within the given distance (center-center) of an object in stack 2
// channel 2 = all objects in stack 2 that are within that distance of some object in stack 1 

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

imageBasename = substring(nupBasename, 0, dotIndex-8);
subFolder = outDir + File.separator + imageBasename + File.separator;
File.makeDirectory(subFolder);
if (!File.exists(subFolder))
      exit("Unable to create directory");

// find objects matching criteria
run("3D Distances Closest", "image_a="+nupBasename+" image_b="+ergBasename+" number=1 distance=DistCenterCenterUnit distance_maximum="+dist);

// save the data
distTableName = "ClosestObjectsWithinCriterion.csv";
saveAs("Results", subFolder + distTableName);

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
run("3D Manager Options", "volume feret centroid_(pix) distance_to_surface objects radial_distance distance_between_centers=0 distance_max_contact=0 drawing=Contour use_0");

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
saveAs("Tiff", subFolder  + "nupColoc.tif");

// save the measurements
Ext.Manager3D_SaveResult("M",subFolder + "nupColocMeas.csv");
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
saveAs("Tiff", subFolder  + "ergColoc.tif");

// save the measurements
Ext.Manager3D_SaveResult("M",subFolder + "ergColocMeas.csv");
Ext.Manager3D_CloseResult("M");


// --- get measurements for all objects
Ext.Manager3D_Reset();
run("3D Manager Options", "volume feret centroid_(pix) distance_to_surface objects radial_distance distance_between_centers=0 distance_max_contact=0 drawing=Contour use_0");

// add nup objects and rename
selectWindow(nupTitle);
Ext.Manager3D_AddImage();
Ext.Manager3D_SelectAll();
Ext.Manager3D_Rename("Nup");
Ext.Manager3D_DeselectAll();
Ext.Manager3D_Count(nupCount); // number of nup objects

selectWindow(ergTitle);
Ext.Manager3D_AddImage();
Ext.Manager3D_Count(allCount); // number of nup objects
Ext.Manager3D_SelectFor(nupCount, allCount, 1);
Ext.Manager3D_Rename("Erg");
Ext.Manager3D_DeselectAll();

Ext.Manager3D_Measure(); 
Ext.Manager3D_SaveResult("M",subFolder + "allMeas.csv");
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
while (isOpen("ClosestObjectsWithinCriterion.csv")) {
 	selectWindow("ClosestObjectsWithinCriterion.csv"); 
 	run("Close" );
}
