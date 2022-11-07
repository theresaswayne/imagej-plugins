
// clear the old results
run("Clear Results");

// set table type
run("Input/Output...", "file=.csv copy_row save_column save_row");
//run("Input/Output...", "file=.tsv copy_row save_column save_row");

// set up measurements
run("Set Measurements...", "area mean integrated limit display redirect=None decimal=3");

// open image
run("Blobs (25K)");

// set a scale
Stack.setXUnit("um");
Stack.setYUnit("um");
run("Properties...", "pixel_width=0.225 pixel_height=0.225 voxel_depth=0.225");

// set a threshold
setThreshold(128, 65535);


// measure selection
run("Specify...", "width=101 height=99 x=108.50 y=113.50 centered");
run("Measure");

// measure whole image
run("Select None");
run("Measure");

// add another column
background = 6.5;
selectWindow("Results");
resultsRows = Table.size; // number of rows
for (i=0; i<resultsRows; i++){
	setResult("Background", i, background+i);
	} // set fake background value
updateResults();

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
