run("CLIJ2 Macro Extensions", "cl_device="); // default (will be Intel HD graphics on MacBook Pro 2019)
Ext.CLIJ2_clear();
Ext.CLIJ2_getGPUProperties(gpu, memory, opencl_version);
print("GPU: " + gpu);
print("Memory in GB: " + (memory / 1024 / 1024 / 1024) );
print("OpenCL version: " + opencl_version);


run("CLIJ2 Macro Extensions", "cl_device=AMD"); // a much more powerful GPU on MacBook Pro 2019
Ext.CLIJ2_clear();
Ext.CLIJ2_getGPUProperties(gpu, memory, opencl_version);
print("GPU: " + gpu);
print("Memory in GB: " + (memory / 1024 / 1024 / 1024) );
print("OpenCL version: " + opencl_version);