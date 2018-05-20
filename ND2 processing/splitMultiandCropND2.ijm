//@ File (label = "Input file", style = "file") inputFile
//@ File (label = "Output directory", style = "directory") outputDir

// splitMultiandCropND2.ijm
// opens a multipoint, c, z, time series
// output: for each xy point, a zt series tiff with the user-specified ranges and increments
// designed for keeping one channel and every 4th t
// thanks to Martin Hoehne's lif processing macro

// WARNING -- fails on the last series with Invalid Index. 
// WORKAROUND: 'Series stop' defaults to penultimate series. 
// 		Last series must be opened manually using "Specify Range"!

// SETUP

startTime = getTime();
setBatchMode(true);
run("Bio-Formats Macro Extensions");
Ext.setId(inputFile); //-- Initializes the given path (filename) without opening
Ext.getSeriesCount(seriesCount); //-- Gets the number of image series in the active dataset.
print("there are",seriesCount,"series in",inputFile);
Ext.setSeries(1); // look at the first series
Ext.getSizeC(channels); // get dimensions of the first series (they should be all the same)
Ext.getSizeZ(slices);
Ext.getSizeT(frames);



// GET RANGES

Dialog.create("Specify dimensions to save");

Dialog.addNumber("Series start",1);
Dialog.addNumber("Series stop",seriesCount-1);

Dialog.addNumber("Channel start", 1);
Dialog.addNumber("Channel stop", channels);
Dialog.addNumber("Channel increment", 1);

Dialog.addNumber("Z Slice start", 1);
Dialog.addNumber("Slice stop", slices);
Dialog.addNumber("Slice increment", 1);

Dialog.addNumber("Frame start", 1);
Dialog.addNumber("Frame stop", frames);
Dialog.addNumber("Frame increment", 4);

Dialog.show();

serStart = Dialog.getNumber();
serStop = Dialog.getNumber();

cStart = Dialog.getNumber();
cStop = Dialog.getNumber();
cInc = Dialog.getNumber();

zStart = Dialog.getNumber();
zStop = Dialog.getNumber();
zInc = Dialog.getNumber();

tStart = Dialog.getNumber();
tStop = Dialog.getNumber();
tInc = Dialog.getNumber(); 


// OPEN IMAGE AND SAVE

for (j=serStart; j<=serStop; j++) {  

	Ext.setSeries(j);

	run("Bio-Formats", "open="+inputFile+" color_mode=Default rois_import=[ROI manager] specify_range view=Hyperstack stack_order=XYCZT series_"+j+" c_begin_"+j+"="+cStart+" c_end_"+j+"="+cStop+" c_step_"+j+"="+cInc+" z_begin_"+j+"="+zStart+" z_end_"+j+"="+zStop+" z_step_"+j+"="+zInc+" t_begin_"+j+"="+tStart+" t_end_"+j+"="+tStop+" t_step_"+j+"="+tInc);
	name=File.nameWithoutExtension;
	seriesName = name + "_" + j + ".tif";
	print("Processing series",j,seriesName);
	saveAs("Tiff", outputDir + File.separator + seriesName);
	}

setBatchMode(false);
// TODO: close open windows using ID (not window)

endTime = getTime();
print("Finished in",((endTime-startTime)/1000)," sec");

