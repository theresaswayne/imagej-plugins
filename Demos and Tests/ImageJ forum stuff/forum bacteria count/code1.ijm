

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
run("Analyze Particles...", "size=1-Infinity show=Outlines display exclude clear summarize stack")
