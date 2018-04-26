roiManager("Add");
roiManager("Add");  //add an extra copy
pixelSize=2.18
dist=10 
pixelDist = dist*pixelSize;
num = 5;
for ( i=1; i < num; i++) {
roiManager ("Select", i);
roiManager ("translate", 0, -pixelDist);
roiManager ("Add")};
roiManager ("Show All");
