// planeTimings.txt
// Written by Curtis Rueden
// Last updated on 2008 December 11

// Uses Bio-Formats to print the chosen file's plane timings to the Log.

run("Bio-Formats Macro Extensions");

id = File.openDialog("Choose a file");
print("Image path: " + id);

Ext.setId(id);
Ext.getImageCount(imageCount);
print("Plane count: " + imageCount);

creationDate = "";
Ext.getImageCreationDate(creationDate);
print("Creation date: " + creationDate);

deltaT = newArray(imageCount);
exposureTime = newArray(imageCount);
print("Plane deltas (seconds since experiment began):");
for (no=0; no<imageCount; no++) {
  Ext.getPlaneTimingDeltaT(deltaT[no], no);
  Ext.getPlaneTimingExposureTime(exposureTime[no], no);
  if (deltaT[no] == deltaT[no]) { // not NaN
    s = "\t" + (no + 1) + ": " + deltaT[no] + " s";
    if (exposureTime[no] == exposureTime[no]) { // not NaN
      s = s + " [exposed for " + exposureTime[no] + " s]";
    }
    print(s);
  }
}
print("Complete.");