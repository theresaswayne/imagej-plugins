// original macro was for a 61-slice stack


run("Specify...", "width=1000 height=1000 x=648 y=486 slice=1");
run("Crop");
rename("Original");
run("32-bit");
run("Subtract Background...", "rolling=20 light stack");
//run("Brightness/Contrast...");
run("Set Scale...", "distance=1000 known=110 unit=um");
setAutoThreshold("Default");
//run("Threshold...");
setOption("BlackBackground", false);
run("Convert to Mask", "method=Default background=Light calculate");
run("Analyze Particles...", "size=1-Infinity show=Outlines display exclude clear summarize stack");
rename("Cells");
run("Fill Holes", "stack");
run("32-bit");
//run("Duplicate...", "title=Cells-tmin1 duplicate range=2-61");
run("Duplicate...", "title=Cells-tmin1 duplicate range=2-3");

selectWindow("Cells");
//run("Duplicate...", "title=Cells-t duplicate range=1-60");
run("Duplicate...", "title=Cells-t duplicate range=1-2");

imageCalculator("Subtract create stack", "Cells-tmin1","Cells-t");
selectWindow("Result of Cells-tmin1");
//run("Brightness/Contrast...");
run("Analyze Particles...", "size=1-Infinity show=Outlines display exclude clear summarize stack");
run("8-bit");
run("Analyze Particles...", "size=1-Infinity show=Outlines display exclude clear summarize stack");
