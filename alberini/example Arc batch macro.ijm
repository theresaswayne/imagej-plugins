// paste this into the batch macro for measuring mean intensity of LC3 in VS120 images

setAutoThreshold("Default dark");
run("Set Measurements...", "area mean min limit display redirect=None decimal=3");
run("Measure");
