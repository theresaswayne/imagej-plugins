pos = 8;
seqSteps = 2;
numFiles = 33;

filesPerTime = pos * seqSteps;
if (numFiles%filesPerTime == 0) {
	t = numFiles/filesPerTime; // calculate number of timepoints
	print("There are ",pos,"positions,",seqSteps,"steps in the sequence, and",t,"timepoints for a total of",numFiles," images." );
}
else { // print warning if # files is wrong
	print("There are ",numFiles," files in the directory but we need a multiple of",filesPerTime);
	exit("Check input parameters");
}



