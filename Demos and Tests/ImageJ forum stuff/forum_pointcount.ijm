

run("Clear Results"); // get rid of previous results table
myTitle = getTitle(); // read the image name into a variable
run("Properties... ", "show"); // same as alt-Y; shows the table of point counts
IJ.renameResults("Counts_"+myTitle,"Results"); // make IJ consider this a Results table, so that values can be accessed
myCounter0 = getResult("Ctr 0", 0); // read the value from the first counter, first row 
print(myCounter0); // print the number to the Log window
