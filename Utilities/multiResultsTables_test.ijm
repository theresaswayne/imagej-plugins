// illustrates how to append results to an existing table

homedir = getDirectory("home");
run("Clear Results");
run("Input/Output...", "file=.txt copy_row save_column save_row");

// generate images

run("Blobs (25K)");
selectWindow("blobs.gif");
rename("C1-blobs.gif");
run("Duplicate...", "title=C2-blobs.gif");

selectWindow("C1-blobs.gif");
run("Select None");
run("Measure");
makeRectangle(94, 90, 68, 72);
run("Measure");
close();
saveAs("Results", homedir + "C1.txt"); // 2 lines
saveAs("Results", homedir + "C1_appended.txt"); // 2 lines

run("Clear Results");

selectWindow("C2-blobs.gif");
run("Select None");
run("Measure");
makeRectangle(94, 90, 68, 72);
run("Measure");
close();
saveAs("Results", homedir + "C2.txt"); // 2 lines

run("Clear Results");

run("Blobs (25K)");
selectWindow("blobs.gif");
run("Measure");
close();
String.copyResults;
newResults=String.paste;   

File.append(newResults,homedir + "C1_appended.txt");
