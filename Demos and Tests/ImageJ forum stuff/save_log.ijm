//@ File (label = "Output directory", style = "directory") outputDir


print("Here's some stuff");
string = getInfo("log");
File.saveString(string, outputDir+File.separator+"log.txt");


