close();
run("Neuron (5 channels)");
makeRectangle(204, 21, 111, 87);
run("Duplicate...", " ");
saveAs("Tiff", "/Users/theresaswayne/Desktop/Rat_Hippocampal_Neuron-1.tif");
run("In [+]");
run("In [+]");
run("In [+]");
run("In [+]");
run("Auto Local Threshold");
setOption("ScaleConversions", true);
run("8-bit");
run("Save");
run("Auto Local Threshold", "method=Niblack radius=15 parameter_1=0 parameter_2=0 white");
run("In [+]");
run("In [+]");
run("In [+]");
run("In [+]");
run("In [+]");
makeRectangle(54, 16, 2, 8);
run("Options...");
run("Out [-]");
run("Out [-]");
run("Out [-]");
run("Out [-]");
run("Out [-]");
run("Open");
close();
selectWindow("Rat_Hippocampal_Neuron.tif");
makeRectangle(113, 148, 179, 140);
run("Duplicate...", " ");
run("Auto Local Threshold");
setOption("ScaleConversions", true);
run("8-bit");
saveAs("Tiff", "/Users/theresaswayne/Desktop/Rat_Hippocampal_Neuron-1.tif");
run("Auto Local Threshold", "method=[Try all] radius=5 parameter_1=0 parameter_2=0 white");
close();
run("Auto Local Threshold", "method=Niblack radius=15 parameter_1=0 parameter_2=0 white");
selectWindow("Rat_Hippocampal_Neuron.tif");
selectWindow("Rat_Hippocampal_Neuron-1.tif");
run("Open");
run("Fill Holes");
run("In [+]");
run("In [+]");
run("In [+]");
run("Out [-]");
run("Out [-]");
run("Undo");
run("Undo");
run("Undo");
run("Revert");
run("Gaussian Blur 3D...");
run("Gaussian Blur...", "sigma=2");
run("Auto Local Threshold", "method=[Try all] radius=5 parameter_1=0 parameter_2=0 white");
close();
run("Auto Local Threshold", "method=Niblack radius=5 parameter_1=0 parameter_2=0 white");
run("Open");
run("Fill Holes");
run("Options...", "iterations=1 count=1 black do=Nothing");
//setTool("wand");
doWand(97, 66);
run("Measure");
run("Set Measurements...", "area perimeter display redirect=None decimal=3");
run("Measure");
