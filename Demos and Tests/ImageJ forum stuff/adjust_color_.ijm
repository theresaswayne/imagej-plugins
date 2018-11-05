
run("Organ of Corti (2.8M, 4D stack)");// open a sample image (delete this line after testing)
run("Z Project...", "projection=[Average Intensity]");
run("Brightness/Contrast...");
title = "Adjust Brightness/Contrast";
msg = "for each channel and Apply, Press OK to proceed";
waitForUser(title, msg);
run("RGB Color"); //convert to RGB color
