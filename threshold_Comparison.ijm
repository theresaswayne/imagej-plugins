// @File(label = "Input file") sourceimage
// @File(label = "Output file", style = "directory") dir2

// Note: DO NOT DELETE OR MOVE THE FIRST 2 LINES -- they supply essential parameters.

// threshold_Comparison.ijm
// ImageJ macro testing equivalence of autothreshold implementations
// expanding on AutoThresholdingDemo.txt example macro

// Input: an image selected by user
// Output: a CSV file containing measurements of the thresholded area of the image by different schemes
// Each method in the auto threshold repertoire is tested.
// As of 2017, this confirms that most methods give the same values, but 
// the Huang threshold is slightly different for the run Auto Threshold (1.64) vs the setThreshold method.

// setup

open(sourceimage);
path = getDirectory("image");
id = getImageID();
title = getTitle();
dotIndex = indexOf(title, ".");
basename = substring(title, 0, dotIndex);
resultName = basename+"_thresh.csv";

run("Input/Output...", "file=.csv copy_row save_column save_row"); // saves data as csv, preserves headers, preserves row number for copy/paste 
run("Set Measurements...", "area limit display redirect=None decimal=2");
run("Clear Results");
run("Select None");

MAXVAL = 255 // change if using a 12-bit image

// set up csv file
// add headers to results file
// 0 image, 1 method, 2 manual threshold value, 3 manual area, 
// 4 setAutoThreshold value, 5 setAutoThreshold area, 6 run Auto Threshold value, 7 run Auto Threhold area

headers = "Label,Method,Manual value,Manual area,setAuto value,setAuto area,run Auto value,run Auto area";
File.append(headers,dir2 + File.separator+ resultName);

methods = getList("threshold.methods");
// Array.print(methods);

// values obtained from Threshold dialog choosing each method in turn
manualThreshVals = newArray(33,21,135,38,33,30,143,29,28,246,52,43,26,130,98,16,162); 

// loop over all methods

for (i=0; i<methods.length; i++) 
	{

	results = basename + "," + methods[i];
	
	// values obtained from dialog
	setThreshold(manualThreshVals[i], MAXVAL);
	run("Measure");
	area = getResult("Area", nResults-1); // trying for last row
	results = results + "," + d2s(manualThreshVals[i],0) + "," + d2s(area,2); 
	resetThreshold();

	
	// set Auto method
	
	setAutoThreshold(methods[i]+" dark");
	getThreshold(lower, upper);
	run("Measure");
	area = getResult("Area", nResults-1); // trying for last row
	results = results + "," + d2s(lower,0) + "," + d2s(area,2);
	resetThreshold();


	// run Auto method
	if (methods[i] == "IJ_IsoData") // not represented in the Auto list
		{
		results = results + ",nd,nd";
		}
	else 
		{
		if (methods[i] == "MinError") // represented by MinError(I) in the Auto list
			{
			run("Auto Threshold", "method=MinError(I) white setthreshold");
			}
		else // all other methods
			{
			run("Auto Threshold", "method="+methods[i]+" white setthreshold"); // setthreshold does not modify image
			}
		getThreshold(lower, upper);
		run("Measure");
		area = getResult("Area", nResults-1); // trying for last row
		results = results + "," +d2s(lower,0) + "," + d2s(area,2);
		resetThreshold();

		}
	// write data
	File.append(results,dir2 + File.separator + resultName);
	}
close();