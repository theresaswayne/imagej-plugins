if(!isOpen("boats.gif")){
  run("Boats (356K)");}
inimg=getImageID();
run("Clear Results");
 makePoint(250, 156);run("Measure");
makePoint(288, 351);run("Measure");
makeRectangle(274, 99, 21, 22);run("Measure");
makeRectangle(440, 227, 21, 22);run("Measure");

roiManager("reset");
drawResults();
roiManager("Set Fill Color", "#1f000000"); // argb, alpha=0.53
roiManager("Show All without labels");
selectWindow("Results");
 
function drawResults(){
	pixelplace=columnStarts();
	point=12;	px=point*2;	 setFont("mono", point); characterheight=px;
 	headings = split(String.getResultsHeadings);
	getDimensions(imageWidth, height, channels, slices, frames);

	textWidth = pixelplace[pixelplace.length-2];
	
	if(textWidth>imageWidth){
		print("printed results will be wider than image");
		return;
	}
	//build in extra checks on image size and number of rows in results table here

	//set headers
	y=0;
	for (col=0; col<lengthOf(headings); col++){
		rcresult=headings[col];
		x=pixelplace[col];
		makeText(rcresult,x,y);
		roiManager("Add", "white");
			
 	}
	//add water
	for (row=0; row<nResults; row++) { 
		y=(1+row)*characterheight;
		for (col=0; col<lengthOf(headings); col++){
			rcresult=toString(getResult(headings[col],row));
			x=pixelplace[col];
			makeText(rcresult,x,y);
			roiManager("Add", "white");
			
 		}
	}
	roiManager("Set Fill Color", "#1f000000"); // argb, alpha=0.53
	roiManager("Show All without labels");
	setOption("Show All", true);
}
function columnStarts(){
	headings = split(String.getResultsHeadings);
	columnWidths=newArray(headings.length+1);
	pipewidth=15;//getStringWidth(" | "); //if you want to print column separators
	columnWidths[0]=pipewidth;
	headings = split(String.getResultsHeadings); 
	for(c=1;c<headings.length;c++){
		cwr=headings[c];
		columnWidth=getStringWidth(cwr);
		for(i=0;i<nResults;i++){
			cwrStr=getResult(headings[c], i);
			cwr=getStringWidth(toString(cwrStr));
			if(cwr>columnWidth){
				columnWidth=cwr;
			}
		}
		newcw=columnWidths[c-1]+columnWidth+pipewidth;
		columnWidths[c]=newcw;
	}
	return columnWidths;
}