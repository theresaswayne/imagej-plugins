
// demonstration of drawing point counting results on an image
// assume the image is a single slice and of a known size

// up to 7 categories

// get an image and points
run("Blobs (25K)");
imageName = getTitle();
width = getWidth();
height = getHeight();

setTool("multipoint");
run("Point Tool...", "type=Hybrid color=Yellow size=Small label show counter=0");
waitForUser("Make a multi-point selection.");

// get the results to determine number of counters
run("Set Measurements...", "centroid display redirect=None decimal=0");
run("Measure");

// check for multiple counters by looking for Counter column
numCounters = 0;

headings = split(String.getResultsHeadings);
for (i=0;i<lengthOf(headings);i++) {
	if (headings[i] == "Counter") {
		Ctrs = Table.getColumn("Counter"); // prevent  error -- if there is only 1 type, the Counter column is not present
		Array.getStatistics(Ctrs, min, max, mean, stdDev);
		numCounters = max+1;
	}
	else {
		numCounters = 1;
	}
}

print("There is/are",numCounters,"counters");

// get the counts
run("Properties... ", "show");

counts = newArray(numCounters);

// loop through columns
for (col = 0; col < numCounters; col++) {
	counterName = "Ctr "+col;
	counterVal = Table.getColumn(counterName);
	counts[col] = counterVal[0];
	print("Counter ",col,counterName,counts[col]);
}

// make a copy of the image
run("Duplicate...", "title=labeled_"+imageName);

// calculate position of top row based on image height
overlayPosX = width*0.67; // this should be the left edge of the results area
overlayPosY = 10; // top of image

// calculate column spacing based on text size
colSpacing = 40;

// set text formatting
setFont("Monospaced", 12);
setColor("black");
setJustification("right");

selectImage("labeled_"+imageName);

for (resultCol = 0; resultCol < numCounters; resultCol++) {
	counterName = "Ctr "+resultCol;
	resultString = counterName + "\n" + counts[resultCol];
	print("Printing ",resultString," at ",overlayPosX, overlayPosY);
	drawString(resultString, overlayPosX, overlayPosY, "white");
	overlayPosX += colSpacing;
}
