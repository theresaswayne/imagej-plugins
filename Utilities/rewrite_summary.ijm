
// build a results table 
// open the image, analyze, add a line to the summary
// repeat for c1, c2, overlap
// read out the values and make a new summaru table
// format: image name, n cells, n cells colocalized with other label, % colocalized with other label

selectWindow("Summary"); 
lines = split(getInfo(), "\n"); 
headings = split(lines[0], "\t"); 
C1Values = split(lines[1], "\t"); 
C2Values = split(lines[2], "\t"); 
OverlapValues = split(lines[3], "\t"); 

C1Name = C1Values[0];
C2Name = C2Values[0];
C1Count = parseInt(C1Values[1]);
C2Count = parseInt(C2Values[1]);
OverlapCount = parseInt(OverlapValues[1]);

C1withC2 = OverlapCount/C1Count;
// print("C1 coloc " + C1withC2);
C2withC1 = OverlapCount/C2Count;
// print("C2 coloc " + C2withC1);

run("New... ", "name=[Cell_Colocalization] type=Table"); 
print("[Cell_Colocalization]", "Filename\tChannel\tTotal Cells\tColocalized Cells\tFraction Colocalized\n");
print("[Cell_Colocalization]", C1Name+"\t1\t" + C1Count+ "\t"+ OverlapCount + "\t" + C1withC2);
print("[Cell_Colocalization]", C2Name+"\t2\t" + C2Count+ "\t"+ OverlapCount + "\t" + C2withC1);

// path = "/Users/confocal/Google Drive/Confocal Facility/User projects/Alberini brain image analysis/cfos-Arc/split channels/test/"

saveAs("Text", path+"edited-summary.xls");
