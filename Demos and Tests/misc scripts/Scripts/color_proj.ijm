
// macro by Theresa Swayne tcs6@cumc.columbia.edu for Eileen Guilfoyle, 2015
// opens image, sets colors to grey, green, red, blue, max projects, saves as rgb tiff

run("Bio-Formats Importer", "autoscale color_mode=Custom view=Hyperstack stack_order=XYCZT series_0_channel_0_red=255 series_0_channel_0_green=255 series_0_channel_0_blue=255 series_0_channel_1_red=0 series_0_channel_1_green=255 series_0_channel_1_blue=0 series_0_channel_2_red=255 series_0_channel_2_green=0 series_0_channel_2_blue=0 series_0_channel_3_red=0 series_0_channel_3_green=0 series_0_channel_3_blue=255");
run("Z Project...", "projection=[Max Intensity]");

// save as rgb
run("Stack to RGB");

