// HyperStack Demo
//
// This macro demonstrates how to create a HyperStack
// and how to control it using the Stack macro functions.

  requires("1.39l");
  print("");
  print("Create a HyperStack");
  run("New HyperStack...", "title=HyperStack type=8-bit width=300 height=200 channels=3 slices=10 frames=5 label");
  getLocationAndSize(x, y, w, h);
  selectWindow("Log");
  setLocation(x+325, y);
  if (Stack.isHyperStack)
      print("Stack.isHyperStack: true");
  else
      print("Stack.isHyperStack: false");

  print("Get Dimensions");
  getDimensions(w, h, channels, slices, frames);
  Stack.getPosition(channel, slice, frame);
  print("   Chanels: "+channels);
  print("   Slices: "+slices);
  print("   Frames: "+frames);
  print("Position (before): "+channel+", "+slice+", "+frame);
  Stack.setPosition(channels, slices, frames);
  Stack.getPosition(channel, slice, frame);
  print("Position (after): "+channel+", "+slice+", "+frame);

  print("Display channels");
  Stack.setPosition(1, 1, 1);
  for (i=1; i<=channels; i++) {
      Stack.setChannel(i);
      wait(500);
  }

  print("Display Slices");
  if (channels>1) Stack.setChannel(2);
  for (i=1; i<=slices; i++) {
      Stack.setSlice(i);
      wait(250);
  }

  print("Display Frames");
  getDimensions(w, h, channels, slices, frames);
  if (channels>2) Stack.setChannel(3);
  for (i=1; i<=frames; i++) {
      Stack.setFrame(i);
      wait(500);
  }

  print("Display all images");
  for (t=1; t<=frames; t++) {
     for (z=1; z<=slices; z++) {
        for (c=1; c<=channels; c++) {
           Stack.setPosition(c, z, t);
           wait(20);
        }
     }
  }
  Stack.setPosition(1, 1, 1);

  print("Change channel 1 LUTs");
  run("Yellow"); // Image>Lookup Tables>Yellow
  wait(1000);
  run("Cyan");
  wait(1000);
  run("Red");


