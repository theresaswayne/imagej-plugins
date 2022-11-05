
// clear the old results
run("Clear Results");

// set csv as table type
run("Input/Output...", "jpeg=85 gif=-1 file=.csv copy_row save_column save_row");
//run("Input/Output...", "file=.tsv copy_row save_column save_row");

// set up measurements
run("Set Measurements...", "area mean min integrated limit display redirect=None decimal=3");

// open image
run("Blobs (25K)");

// set a scale
Stack.setXUnit("um");
Stack.setYUnit("um");
run("Properties...", "channels=1 slices=1 frames=1 pixel_width=0.225 pixel_height=0.225 voxel_depth=0.225");

// set a threshold
setThreshold(128, 255, "raw");

// measure whole image
run("Measure");
// measure selection
run("Specify...", "width=101 height=99 x=108.50 y=113.50 centered");
run("Measure");

// add another column
background = 6.5;
selectWindow("Results");
resultsRows = Table.size; // number of rows
for (i=0; i<resultsRows; i++){
	setResult("Background", i, background+i);
	} // set fake background value

selectWindow("Results");
resultsRows = Table.size; // number of rows
headings = split(Table.headings);
print("The headings are",Table.headings);

	for (i=0; i<resultsRows; i++){
		resultLine = "";
		for (col = 0; col<lengthOf(headings); col++){
			//print("getting result from row",i,"column",headings[col]);
			colName = headings[col];
			data = Table.getString(colName, i);
			resultLine = resultLine + "," + data;
			} // column loop
		print("The result line from row",i,"is", resultLine);
		//data = getResultString(headingsArray[i], 0);
		} // row loop
print("The Mean of row 1 is",Table.getString("Mean", 0));
print("The IntDen of row 1 is",Table.getString("IntDen", 0));
