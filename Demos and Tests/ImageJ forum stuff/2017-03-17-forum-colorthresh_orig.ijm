run("Clown (14K)");
run("Set Measurements...", "area mean limit display redirect=None decimal=3");

// Color Thresholder 2.0.0-rc-43/1.51k
selectWindow("Hue");
rename("0");
selectWindow("Saturation");
rename("1");
selectWindow("Brightness");
rename("2");
min[0]=0;
max[0]=100;
filter[0]="pass";
min[1]=0;
max[1]=30;
filter[1]="pass";
run("Analyze Particles...", "summarize");
run("Color Threshold...");
// Color Thresholder 2.0.0-rc-43/1.51k
selectWindow("Hue");
rename("0");
selectWindow("Saturation");
rename("1");
selectWindow("Brightness");
rename("2");
min[0]=0;
max[0]=100;
filter[0]="pass";
min[1]=30;
max[1]=60;
filter[1]="pass";
run("Analyze Particles...", "summarize");
run("Color Threshold...");
// Color Thresholder 2.0.0-rc-43/1.51k
selectWindow("Hue");
rename("0");
selectWindow("Saturation");
rename("1");
selectWindow("Brightness");
rename("2");
min[0]=0;
max[0]=100;
filter[0]="pass";
min[1]=60;
max[1]=90;
filter[1]="pass";
run("Analyze Particles...", "summarize");
run("Color Threshold...");
// Color Thresholder 2.0.0-rc-43/1.51k
selectWindow("Hue");
rename("0");
selectWindow("Saturation");
rename("1");
selectWindow("Brightness");
rename("2");
min[0]=0;
max[0]=100;
filter[0]="pass";
min[1]=90;
max[1]=255;
filter[1]="pass";
run("Analyze Particles...", "summarize");

