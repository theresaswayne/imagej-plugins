
// open the example image "label issue-1.tif" then run the macro
 
run("Duplicate...", "duplicate");
selectWindow("label issue-1.tif");
run("Label...", "format=00:00:00 starting=0 interval=300 x=5 y=20 font=18 text=[] range=1-5");
rename("no overlay.tif");
selectWindow("label issue-2.tif");
run("Label...", "format=00:00:00 starting=0 interval=300 x=5 y=20 font=18 text=[] range=1-5 use");
rename("overlay.tif");