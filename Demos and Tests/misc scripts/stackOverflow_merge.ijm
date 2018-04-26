// @File(label = "Green images", style = "directory") file1
// @File(label = "Blue images", style = "directory") file2
// @File(label = "Output directory", style = "directory") output

// Do not delete or move the top 3 lines! They contain essential parameters

setBatchMode(true);
list1= getFileList(file1); 
n1=lengthOf(list1);
print("n1 = ",n1);
list2= getFileList(file2); 
n2=lengthOf(list2);
small = n1;
if(small<n2)
	small = n2;
for(i=0;i<small;i++)
    {
	image1=list1[i];
	image2=list2[i];
    open(file1+File.separator+list1[i]);
    open(file2+File.separator+list2[i]);
	print("processing image",i);
	run("Merge Channels...", "c2=&image1 c3=&image2"); 
    name = substring(image1, 0, 13)+"_merge";
	saveAs("tiff", output+File.separator+name);
	close();
	}
setBatchMode(false);
