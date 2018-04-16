//@File(label = "Output directory", style = "directory") outputDir
//@File(label = "Image to analyze", style = "file") inputFile

print("Starting");
open(inputFile);


// from Abi
l = getWidth();
//---- VARIABLE: Depends how many lines you want -----//
k = 6;
// ---------------------------------------------------//
h = getHeight()/k;

i= 0

makeLine(0,h*i+h/2,l,h*i+h/2,1);
	
run("Plot Profile");

// from w rasband
//run("Find Peaks", "min._peak_amplitude=73.45 min._peak_distance=0");
//   Plot.showValues("Plot Values");
//   x1 = Table.getColumn("X1");
//   x2 = Table.getColumn("X2");
//   Array.print(x1);
//   Array.print(x2);

// from h gluender
run("Find Peaks", "min._peak_amplitude=254.99 min._peak_distance=0 min._value=[] max._value=[]");
Plot.showValues();
arrX_1 = newArray(nResults);
arrX_2 = newArray(nResults);
k = 0;
l = 0;
for ( i=0; i<nResults; i++ ) { 
	x1 = getResult("X1", i);
	x2 = getResult("X2", i);
	if ( !isNaN(x1) ) { arrX_1[i] = x1; k++; }
	if ( !isNaN(x2) ) { arrX_2[i] = x2; l++; }
}
arrX_1 = Array.trim(arrX_1, k);
arrX_2 = Array.trim(arrX_2, l);
// inspect the arrays
Array.show("Inspect",arrX_1, arrX_2);
exit();