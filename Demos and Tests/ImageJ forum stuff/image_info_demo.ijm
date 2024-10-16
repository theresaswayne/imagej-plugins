// This macro display information about the active image

  requires("1.32f");
  title = getTitle;
  width = getWidth;
  height = getHeight;
  depth = nSlices;
  getPixelSize(unit, pw, ph, pd);

  print("Title: " + title);
  print("Size: " + width*pw+"x"+height*ph+"x"+depth*pd+" " + unit);
  if (unit!="pixel" || pd!=1) {
      print("Pixel Size: "+pw+"x"+ph+"x"+pd + " " + unit);
      if (pw==ph)
          print("Resolution: "+1/pw+" pixels per "+unit);
      else {
          print("X Resolution: "+1/pw+" pixels per "+unit);
          print("Y Resolution: "+1/ph+" pixels per "+unit);
      }
  }

  path = getDirectory("image");
  if (path=="")
      path = "not available";
  else
      path = path + title;
  print("Path: " + path);

  getThreshold(t1, t2); 
  if (t1==-1)
      print("No threshold");
  else
      print("Threshold: " + t1 + "-" + t2);
  
  type = selectionType();
  if (type==-1)
      print("No selection");
  else {
//      print("Selection Type: " + convertTypeToString(type));
      print("Selection Type: " + type);
      if (type==5) {
          getLine(x1, y1, x2, y2, lineWidth);
          print("  X1: " + x1*pw);
          print("  Y1: " + y1*ph);
          print("  X2: " + x2*pw);
          print("  Y2: " + y2*ph);
     } else {
          getBoundingRect(x, y, w, h);
          print("  X: " + x*pw);
          print("  Y: " + y*ph);
          print("  Width: " + w*pw);
          print("  Height: " + h*ph);
     }
  }


  function convertTypeToString(type) {
      if (type==0) return "Rectangle";
      else if (type==1) return "Oval";
      else if (type==2) return "Polygon";
      else if (type==3) return "Freehand";
      else if (type==4) return "Traced";
      else if (type==5) return "Straight Line";
      else if (type==6) return "PolyLine";
      else if (type==7) return "Freeline";
      else if (type==8) return "Angle";
      else if (type==9) return "Composite";
  }     