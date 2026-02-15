//@ File(label = "Nup label image:") NupFile
//@ File(label = "Erg label image:") ErgFile
//@ File(label = "Output folder:", style = "directory") outDir
//@ Double(label = "Distance criterion (µm):", value = 0.9) dist
//@ Int(label = "Random trials for shuffling labels", value = 10) trials

// shuffle labels.ijm
// Finds closest objects between 2 datasets

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

// find objects matching criteria in the original data
run("3D Distances Closest", "image_a="+nupBasename+" image_b="+ergBasename+" number=1 distance=DistCenterCenterUnit distance_maximum="+dist);

// save the data
distTableName = "ClosestObjectsWithinCriterion_Experimental.csv";
saveAs("Results", outDir + File.separator + distTableName);

// set up a table of results
colocCounts = newArray(trials);

// randomize labels
function shuffleLabels(numA, numB) { 
// given a number of objects in 2 populations A and B, shuffle their labels  


run("3D Manager");
// population 1
selectImage("pop1");
Ext.Manager3D_AddImage();
Ext.Manager3D_Count(nb1);
// population 2
selectImage("pop2");
Ext.Manager3D_AddImage();
Ext.Manager3D_Count(nbTotal);
nb2=nbTotal-nb1;

// select objects in population 2 
Ext.Manager3D_SelectFor(nb2,nbTotal,1);

// find closest object in pop2 for all objects in pop1
// cc = center to center distance, bb=border to border distance (slower)
for(i=0;i<nb1;i++) {
	Ext.Manager3D_Closest(i,"cc",closest); 
	Ext.Manager3D_GetName(closest, name);
	print("Closest center to "+i+" is "+name);
}


Dist2
Computes the distances between
two objects without ResultsTable,
the parameter is the type of
distance
The first object
number, the second
object number and
the type of distance
("cc", "bb", "c1b2",
"c2b1", "r1c2",
"r2c1", "ex2c1",
"ex1c2")
The
measurement
Ext.Manager3D_Dist2(0,1,"bb",dist);
print("Border to border distance
between 0 and 1 is",dist);


function find
