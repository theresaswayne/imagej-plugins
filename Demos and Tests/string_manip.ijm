// illustrates how to remove the last character in a string
// and how to find and replace

myString = "1\t2\t3456789";
print(myString);

myString = substring(myString,0,lengthOf(myString)-1);
print(myString);

myString = replace(myString, "\t",",")
print(myString);


