// see if we can explicitly register the scale within a macro
run("Bat Cochlea Volume (19K)");
run("Properties...", "unit=foos pixel_width=0.0645 pixel_height=0.0645 voxel_depth=0.3");
run("3D Project...", "projection=[Brightest Point] axis=X-Axis slice=1 initial=0 total=180 rotation=10 lower=1 upper=255 opacity=0 surface=0 interior=0 interpolate");

