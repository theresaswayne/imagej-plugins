// rearrange_results_Demo.ijm
// IJ macro to show how to read data from the Summary table, do calculations, and output to a new table
// 		simulating an object overlap analysis
// Theresa Swayne, tcs6@cumc.columbia.edu, 2017
// Output: custom table: 
//     # C1 cells, # C2 cells, # overlapped cells, % C1 cells with C2 label, % C2 cells with C1 label.

// SETUP
run("Set Measurements...", "area display redirect=None decimal=2");
run("Clear Results");
CELLMIN = 150 
CELLMAX = 500 

// prepare sample images
run("Blobs (25K)");
setOption("BlackBackground", true);
run("Make Binary");
rename("C1");
run("Duplicate...", "title=C2");
run("Rotate 90 Degrees Left"); // C2 is rotated version of C1

// find overlapping areas - result is 255 where both masks are 255, and 0 elsewhere  
imageCalculator("Multiply create","C1","C2");
rename("Overlap"); // the result window is automatically selected

// get cell counts for channel 1 (counting large areas only)
selectWindow("C1");
run("Analyze Particles...", "size=" + CELLMIN + "-" + CELLMAX + "show=Overlay exclude summarize");

// get cell counts for channel 2 (counting large areas only)
selectWindow("C2");
run("Analyze Particles...", "size=" + CELLMIN + "-" + CELLMAX + "show=Overlay exclude summarize");

// get cell counts for overlap (counting large areas only)
selectWindow("Overlap");
run("Analyze Particles...", "size=" + CELLMIN + "-" + CELLMAX + "show=Overlay exclude summarize");

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

// calculate the percent overlap
C1withC2 = OverlapCount/C1Count;
C2withC1 = OverlapCount/C2Count;

// create a new table with all colocalization data
// format: image name, num cells, num cells colocalized with other label, % cells colocalized with other label
run("Table...", "name=[Cell_Colocalization] width=1000 height=250"); 
print("[Cell_Colocalization]", "\\Headings:Filename\tChannel\tTotal Cells\tColocalized Cells\tFraction Colocalized\n"); // prettier table
print("[Cell_Colocalization]", C1Name+"\t1\t" + C1Count+ "\t"+ OverlapCount + "\t" + C1withC2);
print("[Cell_Colocalization]", C2Name+"\t2\t" + C2Count+ "\t"+ OverlapCount + "\t" + C2withC1);

// clean up
run("Tile");
selectWindow("Cell_Colocalization");




