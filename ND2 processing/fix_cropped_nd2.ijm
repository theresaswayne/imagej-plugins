//@ File (label = "Input file", style = "file") inputFile
//@ File (label = "Output directory", style = "directory") outputDir
//@ String(label ' "

// fix_cropped_nd2.ijm
// Plan: opens multipoint, z, time series (1 channel) that don't open properly in ij
// output: for each xy point, a zt series tiff

// alternative -- take original dual channel czt series delete one channel and save every 4th timepoint

// open raw VS -- correct order, 8 series, 1 49 t, 29 z, 2c, intermed t's are black. 2842 planes
// open "crop" VS -- says 8 series of 377 planes... weird order, a few z from 1 point then another. 13x29

// open "crop" nonVS, "concat when compat" -- get memory warning with all, but does work with 2
// order (of 2 concat): seems to alternate 3 and 4 per position, seem like nonconsec z, hard to tell what it is exactly

// user input: chanKeep string of channels to keep, frameKeep string frame start-stop-interval, sliceKeep string start-stop-interval
// "Enter a range (e.g. 2-14), a range with increment\n(e.g. 1-100-2) or a list (e.g. 7,9,25,27)"
// get numSeries
// cycle through series

setBatchMode(true);
run("Bio-Formats Macro Extensions");

// 
run("Make Substack...", "channels=&chanKeep slices=&sliceKeep frames=&frameKeep");
