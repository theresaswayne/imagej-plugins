//@ string(label="Thresholding method", choices={"Default","Huang","Intermodes","IsoData","IJ_IsoData","Li","MaxEntropy","Mean","MinError","Minimum","Moments","Otsu","Percentile","RenyiEntropy","Shanbhag","Triangle","Yen"}, style="listBox") Thresh_Method
//@ string(label = "Type something") aThing

// test threshold selection
run("Blobs (25K)");
setAutoThreshold(Thresh_Method);
print("Threshold used:",Thresh_Method);
