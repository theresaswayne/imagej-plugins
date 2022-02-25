#@ int(label="Maximum number in your list:") numROIs
#@ int(label="Test number from the list:") testNum

// how much to pad?
// The ceiling of the log base 10 of the number
// 99 -> 2; 100 -> 2; 101 -> 3

digits = Math.ceil((log(numROIs)/log(10)));
padLength = digits;

padded = IJ.pad(testNum, padLength);
print(padded);
