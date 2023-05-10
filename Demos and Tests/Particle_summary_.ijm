
path = "/Users/theresaswayne/Desktop/";
results = "/Users/theresaswayne/Desktop/Summary.csv";
run("Set Measurements...", "area mean integrated centroid display redirect=None decimal=2");

run("Blobs (25K)");
setAutoThreshold("Default");
setOption("BlackBackground", true);
run("Convert to Mask");
run("Analyze Particles...", "display exclude clear summarize");

selectWindow("Summary");
saveAs("Text", path + File.separator + "OriginalSummary.tsv");  // this changes the name

selectWindow("OriginalSummary.tsv");
// gather info, tab separated
lines = split(getInfo(), "\n"); 
headings = lines[0];
// label count totalarea averagesize pctarea mean intden 
values = split(lines[1], "\t"); 

//C1Count = parseInt(values[1]);

// replace the mask file name with the original file name
origLabel = values[0];
print("Original label",origLabel);
newLabel = "Actual Image";
values[0] = newLabel;
print("Renamed to",newLabel);

// construct the data line replacing tabs with commas
summaryLine = String.join(values, ",");

// begin the new comma-separated file if needed, then add the summary data
if (File.exists(results)==false) {
	SummaryHeaders = replace(headings, "\t",","); // replace tabs with commas
	File.append(SummaryHeaders,results);
	print("added headings: ",SummaryHeaders);
	}
File.append(summaryLine,results); // add one line of data
print("added data");



