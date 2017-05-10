// @File(label = "Input directory", style = "directory") dir1
// @File(label = "Output directory", style = "directory") dir2
// @String(label = "File suffix", value = ".tif") suffix

// DO NOT DELETE OR MOVE THE FIRST 3 LINES -- they supply essential parameters
// projection_measure.ijm
// does particle analysis on existing binary stacks (designed for projected images of calcofluor)

// setup

run("Input/Output...", "file=.csv copy_row save_row"); // saves data as csv, preserves headers, preserves row number for copy/paste 
run("Set Measurements...", "area shape feret's display redirect=None decimal=2");
run("Clear Results");

// add headers to results file
particle_headers = ",Label,Area,Circ,Feret,FeretX,FeretY,FeretAngle,MinFeret,AR,Round,Solidity";
File.append(particle_headers,dir2  + File.separator+ "particle_results.csv");
summary_headers = ",Slice,Count,TotalArea,AverageSize,%Area,Circ,Solidity,Feret,FeretX,FeretY,FeretAngle,MinFeret";
File.append(summary_headers,dir2  + File.separator+ "summary_results.csv");

// do the analysis
setBatchMode(true);
n = 0;
processFolder(dir1); // this actually executes the functions

// recursively process folders
function processFolder(dir1) 
	{
	list = getFileList(dir1);
   for (i=0; i<list.length; i++) 
   		{
        if(File.isDirectory(dir1 + File.separator + list[i])){
			processFolder("" + dir1 +File.separator+ list[i]);}
        else if (endsWith(list[i], suffix)){
           	processImage(dir1, list[i]);}
		}
	}


// contains the processing steps to be done on each image
function processImage(dir1, name) 
	{
	open(dir1+File.separator+name);
	print("processing",n++, name);

	// pre-processing
	run("Despeckle", "stack"); // if using circularity

	// particle analysis
	run("Analyze Particles...", "size=10-Infinity display exclude clear include summarize stack");
	
	// copy results table
	String.copyResults;
	newResults = String.paste;
	newResults = substring(newResults,0,lengthOf(newResults)-1); // strip the final newline
	newResults = replace(newResults, "\t",","); // replace tabs with commas for csv
	File.append(newResults,dir2 + File.separator + "particle_results.csv");

	// copy summary table
	selectWindow("Summary of "+name);
	// newSummary = split(getInfo(), "\n");
	newSummary = getInfo();
	newSummary = substring(newSummary,0,lengthOf(newSummary)-1); // strip the final newline
	newSummary = replace(newSummary, "\t",","); // replace tabs with commas for csv
	lines=split(newSummary, "\n");
	for (i=1;i<lengthOf(lines);i++){ // skips the first line
		lines[i] = name+","+lines[i];
		File.append(lines[i],dir2 + File.separator + "summary_results.csv");
	}
	// cleanup
	selectWindow("Summary of "+name); // TODO: fix Summary closing
	// close(); // does not work with text windows
	run("Close");
	//	run("Clear Results");
	}
setBatchMode(false);