// fix_cropped_nd2.ijm
// opens multipoint, z, time series (1 channel) that don't open properly in ij
// output: for each xy point, a zt series tiff

// alternative -- take original dual channel czt series delete one channel and save every 4th timepoint

// open raw VS -- correct order, 8 series, 1 49 t, 29 z, 2c, intermed t's are black. 2842 planes
// open "crop" VS -- says 8 series of 377 planes... weird order, a few z from 1 point then another. 13x29

// open "crop" nonVS, "concat when compat" -- get memory wnaring
 