// paste into the batch macro window, commenting out lines as needed
// For points:

run("Multipurpose gridMod", "set=by_area_per_point new line_thickness=1 area=50000 encircled regular=red dense_points_color=green line_color=blue");

// For lines:

// run("Multipurpose gridMod", "set=by_tiles_density random new line_thickness=1 tile=2 regular=black dense_points_color=green horizontal_segmented line_color=black");

/* 
If using point overlays remove the counts thus:
roiManager("Add");
roiManager("Select", 0);
roiManager("Deselect");
roiManager("Delete");
roiManager("Show All");
*/