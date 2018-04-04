// IJ1 macro to prepare actin cable images for 3D analysis in plugins such as BoneJ, SimpleNeuriteTracer
// 1) Makes voxels isotropic (same xyz size) by reslicing in Z direction
// 2) Pads with blank slices at beginning and end.
// Matches bit depth of input image.
// Input: single-channel z stack with z spacing != xy spacing
// Output: A new image window.
// Usage: Open an image. Run the macro.
// Note: if you want to cut out some z slices from the stack for better segmentation, do that *BEFORE* running the macro.

// T. Swayne, for Pon lab, 2017

// get stack info

title = getTitle();
getVoxelSize(voxwidth, voxheight, depth, unit);
getDimensions(stackwidth, stackheight, channels, slices, frames);
origBitDepth = bitDepth(); 
processedName = title+"_isotropic_padded.tif";

print("initial voxel depth =",depth);
print("initial bit depth =",origBitDepth);

// make voxels isotropic

selectWindow(title);
run("Reslice Z", "new="+voxwidth);

// pad with blank slices at beginning and end

newImage("blankSlice", origBitDepth+"-bit black", stackwidth, stackheight, 1);
run("Concatenate...", "  title=&processedName image1=blankSlice image2=[Resliced] image3=blankSlice");

// fix scale of concatenated image

setVoxelSize(voxwidth, voxheight, voxwidth, unit);

// check final values

selectWindow(processedName);
getVoxelSize(voxwidth, voxheight, newdepth, unit);
finalBitDepth = bitDepth(); 

print("final voxel depth =",newdepth);
print("final bit depth =",finalBitDepth);
