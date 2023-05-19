//  measure distance between rois in the manager

numRois = roiManager("count");

myROIs = newArray(numRois);
print(myROIs);

testIndex = floor(random * numRois) + 1; 

for (i=0; i < numRois; i++) {
	//The euclidean distance between centers should be > 2w where w is the field width.
	
	dist = sqrt((centerX-centersX[i])^2 + (centerY-centersY[i])^2);
	print("Distance between ROI",index,"and selected ROI",i,"is",dist);
	if (dist <= 2*fieldWidth) { // too close
		pass = false;
		print("too close");
		break; // exit the for loop
	}
	else {
		print("far enough");
		continue; // jump to beginning of for loop and check the next position
	}
	
	
	for (i = 0; i < count; i++) {
	roiManager("select", i);
	scaleROI(factor);
	roiManager("update");
}
if (current < 0)
	roiManager("deselect");
else
	roiManager("select", current);