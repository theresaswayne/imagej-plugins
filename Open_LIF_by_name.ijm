// from Bruno Cadot, Image.sc forum
// https://forum.image.sc/t/ij-macro-to-extract-specific-series-from-lif-files-in-batch/77944

setOption("ExpandableArrays", true);
setBatchMode(true);
path="";
newDir="";
Dialog.create("Open series by name");
Dialog.addDirectory("Select a folder to extract", path);
Dialog.addString("Name in the series to select", "");
Dialog.addChoice("Matching", newArray("contains", "equals"), "contains");
Dialog.addChoice("Colors to extract", newArray("All", "C=0", "C=1", "C=2", "C=3"), "colors");
Dialog.addDirectory("Select a destination folder", newDir);
Dialog.show();

path=Dialog.getString();
seriesName = Dialog.getString();
matchMode = Dialog.getChoice();
colors= Dialog.getChoice();

filename = getFileList(path);
for (k=0; k<filename.length; k++){
	if(endsWith(filename[k], ".lif")) {
			//nameT = File.getName(filename[k]);
			//nameT= replace(nameT, ".lif", "");
			//rename(nameT); // TODO: fix bug -- there are no images open in line 26
			file=path + File.getName(filename[k]);

			run("Bio-Formats Macro Extensions");
			Ext.setId(file);
			Ext.getSeriesCount(nSeries);
			seriesToOpen = newArray;
			sIdx = 0;
			for(i = 0; i < nSeries; i++) {
				Ext.setSeries(i);
				Ext.getSeriesName(name);
				if((matchMode == "equals" && name == seriesName) ||
					(matchMode == "contains" && indexOf(name, seriesName) >= 0)) {
					seriesToOpen[sIdx++] = i + 1;
				}
			}
			for(s = 0; s < seriesToOpen.length; s++){
				if (colors=="All"){
					run("Bio-Formats Importer", "open=[" + file + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_list=" + seriesToOpen[s]);
					nameT=getTitle();
					nameT= replace(nameT, ".lif", "");
					nameT=replace(nameT,"/","-"); // get rid of slashes in the name
					//rename(nameT); 
					saveAs("Tiff", newDir+File.separator+nameT+".tif");
					}
				if (colors != "All"){
				run("Bio-Formats Importer", "open=[" + file + "] autoscale color_mode=Default rois_import=[ROI manager] split_channels view=Hyperstack stack_order=XYCZT series_list=" + seriesToOpen[s]);
				list2=getList("image.titles");
				for (m=0; m<list2.length;m++){
					selectWindow(list2[m]);
					nameT2=getTitle();
					if (indexOf(nameT2, colors) >=0) {
						saveAs("Tiff", newDir+File.separator+nameT+"_"+colors +".tif");
					}
				}
			
			}	
		}
	}
	run("Close All");
	run("Collect Garbage");
	run("Collect Garbage");
}