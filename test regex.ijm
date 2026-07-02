testString = ".*Fluor.*";
targetString = "FluxorescentCells.tif";
if (matches(targetString, testString)) {
	print(testString, "matches",targetString);
}
else {
	print(testString, "does not match", targetString);
}
