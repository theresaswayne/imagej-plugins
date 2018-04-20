// ImageJ macro demonstrating how to capture a screenshot of the Results Window

// load a sample image
run("Blobs (25K)");
imageName = getTitle();

// make some dummy measurements
run("Clear Results");
run("Measure");

// use beanshell to get the size of the results table, and position it in a known location
resW = eval("bsh", "rt = ResultsTable.getResultsWindow();resW = rt.getWidth();return resW");
resH = eval("bsh", "rt = ResultsTable.getResultsWindow();resH = rt.getHeight();return resH");
eval("bsh", "rt = ResultsTable.getResultsWindow();rt.setLocation(100, 100)")

// put Results window on top and capture the screen
selectWindow("Results");
run("Capture Screen");

// crop the screenshot to include only the Results window
selectWindow("Screenshot");
makeRectangle(100, 100, resW, resH);
run("Crop");
rename("Results for "+imageName);
