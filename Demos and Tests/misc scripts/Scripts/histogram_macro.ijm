run("Blobs");
imageName=getTitle;
run("8-bit");
makeRectangle(62,69,380,288);

// get histogram values
nBins = 256;
run("Clear Results");
row = 0;
getHistogram(values, counts, nBins);

// put histogram values in the results window and save
for (i=0; i<nBins; i++) {
// modified to output a single column
//    setResult("Value", row, values[i]);
    setResult("Count", row, counts[i]);
    row++;
    }
updateResults();
//saveAs("Results","/Users/confocal/Desktop/output/"+getTitle+".xls");

// close all windows
close("*");

selectWindow("Counts_blobs.gif");

run("Close");