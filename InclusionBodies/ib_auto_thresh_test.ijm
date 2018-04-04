// ib_auto_thresh_test.ijm
// test methods to identify cell and pull out cytoplasmic background level

// e.g. set a generous threshold
// take out a percentage of the upper range and/or percentiles, that is consistent with typical IB size and intensity
// allow for different levels of cyto bkgd
// possibly take out some of the lower pixels -- vacuole?
// take mean of remaining pixels

// cropped cell, 16 bit, middle slice with small inclusion, range 1520-5680
// stack, range 1408-1616

// middle slice, hand measured bkgd = 2985 (avg of 2932, 2992, 3033), mode is 2944-3024
// Default thresh, mean is 2801, mode 2848


// choose several areas, take the mean of the one with the least st dev?

getDimensions(width, height, channels, slices, frames);
middleSlice = slices/2;
Stack.setPosition(1, middleSlice, 1); // move to only channel, middle slice, only frame
