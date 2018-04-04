// getCoordinates_Demo.ijm
// based on https://imagej.nih.gov/ij/macros/SelectionCoordinates.txt
// and https://imagej.nih.gov/ij/macros/examples/RoiFunctionsDemo.txt

// output:  
//	1) list of selection coordinates (position, x, y)
//	2) new image re-drawing based on the coordinates (should match the original selection well)

// usage: Open an image and create a selection. Run the macro.

requires("1.30k");

// getSelectionCoordinates(x, y); // this gets the definition, NOT evenly spaced
//Roi.getCoordinates(x, y); // this gets the definition, NOT evenly spaced
//for (i=0; i<x.length; i++)
// print("coord",i+" "+x[i]+","+y[i]);

//Roi.getSplineAnchors(xx, yy) // this gets the definition, NOT evenly spaced
//for (i=0; i<x.length; i++)
// print("spline",i+" "+xx[i]+","+yy[i]);

//type = selectionType();
//newImage("Outline", "8-bit white", getWidth, getWidth, 1);
//setColor(0); // black
//setLineWidth(1); // otherwise it will draw as the width of the original line
//moveTo(x[0], y[0]);
//for (i=1; i<x.length; i++)
// lineTo(x[i], y[i]);
//if (type==2 || type==3)
//lineTo(x[0], y[0]);

// from christopher coulon
// https://list.nih.gov/cgi-bin/wa.exe?A2=ind0807&L=IMAGEJ&D=0&1=IMAGEJ&9=A&J=on&d=No+Match%3BMatch%3BMatches&z=4&P=72550
// this gives 142 coords for a 235 length freehand line (0.6 ratio), 307 for 360 (0.85 ratio)

sum = 0;
count = 0;

getSelectionCoordinates(x, y);
len = x.length;
x1 = newArray(len);
y1 = newArray(len);
hypot = newArray(len);

print("\n**********\ni x[i] y[i] x1[i] y1[i] hypot");
for (i = 1; i < len; i++) {
    x1[i] = x[i-1] - x[i];
    y1[i] = y[i-1] - y[i];
     hypot[i] = sqrt(x1[i] * x1[i] + y1[i] * y1[i]);
     sum += hypot[i];
     //print(i + " " + x[i] + "  " + y[i] + " " + x1[i] + " " + y1[i] + " " + hypot[i]);
	}

fullPerimX = newArray(sum);
fullPerimY = newArray(sum);

for (i = 0; i < len; i++) {
    if(x1[i] != 0) {
        n = x1[i];
               
        if(n < 0) {
            for(j = n; j < 0; j++) {
                fullPerimX[count] = x[i] + j;
                fullPerimY[count] = y[i];
                count++;
            }
        }
        else {
            for(j = n; j > 0; j--) {
                fullPerimX[count] = x[i] + j;
                fullPerimY[count] = y[i];
                count++;
            }
        }
    }
    else {
        if(y1[i] != 0) {
            n = y1[i];
            
            if(n < 0) {
                for(j = n; j < 0; j++) {
                    fullPerimY[count] = y[i] + j;
                    fullPerimX[count] = x[i];
                    count++;
                }
            }
            else {
                for(j = n; j > 0; j--) {
                    fullPerimY[count] = y[i] + j;
                    fullPerimX[count] = x[i];
                    count++;
                }
            }
        }
    }
}

print("\ncount = " + count + "\n***** Full Line Coordinates *****\n");
print("Position     X     Y");
for (i = 0; i < count; i++) {
    if(i < 10)
        print("    " + i + "          " + fullPerimX[i] + "   " +
fullPerimY[i]);
        else
        if(i < 100)
            print("  " + i + "          " + fullPerimX[i] + "   " +
fullPerimY[i]);
            else
                print(" " + i + "          " + fullPerimX[i] + "   " +
fullPerimY[i]);
}

