
 // macro from wayne rasband on ij list
 // when run in 2017 this does not give you visible windows
 // but it does seem to correctly access the values

homedir = getDirectory("home");

run("Clear Results"); 

run("Blobs (25K)"); 
run("Set Measurements...", "area mean min decimal=2"); 
setAutoThreshold("Default"); 
run("Analyze Particles...", "display clear add"); 
IJ.renameResults("C1.csv"); 
saveAs("Results", homedir + "C1.csv"); // first batch of results == the particles


run("Clear Results"); 
run("Gaussian Blur...", "sigma=2"); 
n = roiManager("count"); 
for (i=0; i<n; i++) { 
   roiManager("select", i) 
   run("Measure"); 
	} 

IJ.renameResults("C2.csv"); 
saveAs("Results", homedir + "C2.csv"); // first batch == the particles in the smoothed image

selectWindow("C1.csv");  // TODO: open from disk instead of choosing window
IJ.renameResults("Results"); 
selectWindow("blobs.gif");
run("Select All");
run("Measure");  // C1 has the particles plus the whole image -- this works
saveAs("Results", homedir + "C1_appended.csv");

selectWindow("C2.csv"); // TODO: open from disk instead of choosing window.
IJ.renameResults("Results"); 
selectWindow("blobs.gif");
setAutoThreshold("Default"); 
run("Analyze Particles...", "display clear add");  // C2 should have the particles twice -- but instead it just has 62 particles. TODO: fix
saveAs("Results", homedir + "C2_appended.csv");


selectWindow("blobs.gif");
close();

   
   