

myTitle = getTitle(); // read the image name into a variable
run("Properties... ", "show"); // same as alt-Y; shows the table of point counts
selectWindow("Counts_"+myTitle); 
lines = split(getInfo(), "\n");  // read all rows into an array
headings = split(lines[0], "\t"); // read the heading row into an array
counterValues = split(lines[1], "\t");  // read the counter values into an array

myCounter0 = counterValues[1]; // the value from the first counter 
myCounter1 = counterValues[2];
print(myCounter0,"\n",myCounter1); // print the values to the Log window


