// Macro for calculating percentage of fibrose componnent compared to cardiomyocyte component
// taking into account the lumen part or not in batch
// 
// Folder structure:
// Source folder selected contains subfolders that contain the images
// Result folder, just a folder to store results
//
// The color thresholding algorithm used by this macro is based on an algorithm written by G. Landini (version v1.8) 
// 
// Note: This only works with Black background and White foreground
run("Colors...", "foreground=white background=black selection=yellow");
run("Options...", "iterations=1 black count=1");
//
// All image calculation using logical operators take zero values as zero and 255 as "one" in the case below
// So inverted luts only change black to white and white to black but zero stays zero meaning black was zero and after
// inverting the LUT white is now zero.
// Anything measured needs to have value 255
// So 255 or '1' is the object

dir1 = getDirectory("Choose Source Directory");
dir2 = getDirectory("Choose Destination Directory");
list1 = getFileList(dir1);
setBatchMode(true);
for (my_list1=0; my_list1<list1.length; my_list1++) {
	list = getFileList(dir1+list1[my_list1]);
	if (list.length>0) {
		overall_result_file = File.open(dir2+"Results_of_"+substring(list1[my_list1],0,lengthOf(list1[my_list1])-1)+"_"+list[0]+"_till_"+list[list.length - 1]+".txt");
		print(overall_result_file, "Imagename;Total_area_excluded;Total_area_lumen;Total_area_incl_cardiomyocytes;Tota_area_fibrosis");
		showProgress(my_list1, list1.length+1);
		for (my_list=0; my_list<list.length; my_list++) {
			open(dir1+list1[my_list1]+list[my_list]);
			AssessLumenFibrosisAndCardiomyocyteComponents();
	     		close();
 
function AssessLumenFibrosisAndCardiomyocyteComponents() {

	// Initialisation based on emperical analyses of test data set
	exclude_high_th=72;
	lumen_low_th=240;
	fibrosis_high_th=130;

	image_name = File.name;
	OriginalImage = getImageID();

	// Create duplicate and determine if green marked areas can be detected as areas to be excluded
	run("Duplicate...", "title=exclude_area");

	// Obtain (possible) exclusion area
	ExclusionImage = getImageID();
	selectImage(ExclusionImage);
	min=newArray(3);
	max=newArray(3);
	filter=newArray(3);
	a=getTitle();
	run("RGBtoLab");
	run("RGB Stack");
	run("Convert Stack to Images");
	selectWindow("Red");
	rename("0");
	selectWindow("Green");
	rename("1");
	selectWindow("Blue");
	rename("2");
	min[0]=0;
	max[0]=255;
	filter[0]="pass";
	min[1]=0;
	max[1]=exclude_high_th;
	filter[1]="pass";
	min[2]=0;
	max[2]=255;
	filter[2]="pass";
	for (i=0;i<3;i++){
  		selectWindow(""+i);
  		setThreshold(min[i], max[i]);
  		run("Make Binary", "thresholded remaining");
  		if (filter[i]=="stop") {
	 		run("Invert");
  		}
	}
	imageCalculator("AND create", "0","1");
	imageCalculator("AND create", "Result of 0","2");
	for (i=0;i<3;i++){
  		selectWindow(""+i);
		close();
	}
	selectWindow("Result of 0");
	close();
	selectWindow("Result of Result of 0");
	rename(a);
	// Colour Thresholding------------
	run("8-bit");
	run("Fill Holes"); // Detected area inside green demarcated area has value 255
	run("Invert"); // So invert (not invert LUT): Needed to exclude this area from calculations; 

        // Now obtain lumen part from image
	selectImage(OriginalImage);
	run("Duplicate...", "title=lumen_area");
	LumenImage = getImageID();
	selectImage(LumenImage);
	a=getTitle();
	run("RGBtoLab");
	run("RGB Stack");
	run("Convert Stack to Images");
	selectWindow("Red");
	rename("0");
	selectWindow("Green");
	rename("1");
	selectWindow("Blue");
	rename("2");
	min[0]=lumen_low_th;
	max[0]=255;
	filter[0]="pass";
	min[1]=0;
	max[1]=255;
	filter[1]="pass";
	min[2]=0;
	max[2]=125;
	filter[2]="pass";
	for (i=0;i<3;i++){
	  	selectWindow(""+i);
  		setThreshold(min[i], max[i]);
  		run("Make Binary", "thresholded remaining");
  		if (filter[i]=="stop")
  			run("Invert");
	}
	imageCalculator("AND create", "0","1");
	imageCalculator("AND create", "Result of 0","2");
	for (i=0;i<3;i++){
  		selectWindow(""+i);
  		close();
	}
	selectWindow("Result of 0");
	close();
	selectWindow("Result of Result of 0");
	rename(a);
	// Colour Thresholding------------
	run("8-bit");
	imageCalculator("AND", "lumen_area","exclude_area");

	//Now obtain fibrosis component
	selectImage(OriginalImage);
	run("Duplicate...", "title=fibrosis_area");
	FibrosisImage = getImageID();
	selectImage(FibrosisImage);
	a=getTitle();
	run("RGBtoLab ");
	run("RGB Stack");
	run("Convert Stack to Images");
	selectWindow("Red");
	rename("0");
	selectWindow("Green");
	rename("1");
	selectWindow("Blue");
	rename("2");
	min[0]=0;
	max[0]=lumen_low_th-1;
	filter[0]="pass";
	//Based on discussion with Noura and Nynke
	min[1]=fibrosis_high_th;
	max[1]=255;
	filter[1]="pass";
	min[2]=0;
	max[2]=255;
	filter[2]="pass";
	for (i=0;i<3;i++){
  		selectWindow(""+i);
  		setThreshold(min[i], max[i]);
  		run("Make Binary", "thresholded remaining");
  		if (filter[i]=="stop")
  			run("Invert");
	}
	imageCalculator("AND create", "0","1");
	imageCalculator("AND create", "Result of 0","2");
	for (i=0;i<3;i++){
  		selectWindow(""+i);
  		close();
	}
	selectWindow("Result of 0");
	close();
	selectWindow("Result of Result of 0");
	rename(a);
	// Colour Thresholding------------
	run("8-bit");

        // Obtain the remaining tissue compartments, in this case cardiomyocytes
	selectImage("fibrosis_area");
	run("Duplicate...", "title=cardiomyocytes_area");
	CardioMyocyteImage = getImageID();
	selectImage("fibrosis_area");
	imageCalculator("AND", "fibrosis_area","exclude_area");
	selectImage("cardiomyocytes_area");
	run("Invert");
	// Invert lumen and get rid of lumen in cardiomyocyte image
	selectImage("lumen_area");
	run("Invert");
	imageCalculator("AND", "cardiomyocytes_area","lumen_area");
	selectImage("lumen_area");
	run("Invert");
	selectImage("cardiomyocytes_area");
	imageCalculator("AND", "cardiomyocytes_area","exclude_area");

	// Now estimate percentages and present to user=Awal
	// Everything with value zero will be measured as object!
	run("Set Measurements...", "area limit redirect=None decimal=3"); // General settings
	// First Exclusion area
	selectImage("exclude_area");
	// We need the size of the exclusion part
	totarea_exclusion=0;
	run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing clear");
	for (i=0; i<nResults; i++) {
		totarea_exclusion = totarea_exclusion+ getResult("Area",i);
	}
	close();
	//  lumen
	selectImage("lumen_area");
	run("Invert");
	totarea_lumen=0;
	run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing clear");
	for (i=0; i<nResults; i++) {
		totarea_lumen = totarea_lumen+ getResult("Area",i);
	}
	close();
	// Fibrosis
	selectImage("fibrosis_area");
	run("Invert");
	totarea_fibrosis=0;
	run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing clear");
	for (i=0; i<nResults; i++) {
		totarea_fibrosis = totarea_fibrosis+ getResult("Area",i);
	}
	close();
	// Cardiomyocytes
	selectImage("cardiomyocytes_area");
	run("Invert");
	totarea_cardio=0;
	run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing clear");
	for (i=0; i<nResults; i++) {
		totarea_cardio = totarea_cardio+ getResult("Area",i);
	}
	close();
	run("Clear Results");
	print(overall_result_file, dir1+list[my_list]+";"+totarea_exclusion+";"+totarea_lumen+";"+totarea_cardio+";"+totarea_fibrosis);
}
}//End of for my_list
File.close(overall_result_file);
}//End if list.length>0
}//End of for my_list1
