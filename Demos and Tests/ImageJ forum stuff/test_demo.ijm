// This macro demonstrates how to draw text with a filled background.
// A JavaScript version is available at
//    http://imagej.nih.gov/ij/macros/js/DrawTextWithBackground.js

  requires("1.45j");
  run("Boats (356K)");
  run("RGB Color");
  setColor("black");
  x=50; y=40;
  drawString("This is the default font.", x, y, "white");

  setFont("SansSerif", 9);
  y += 30;
  drawString("This is 9-point, 'SansSerif'", x, y, "white");

  setFont("Monospaced", 12);
  y += 30;
  drawString("This is 12-point, 'Monospaced'", x, y, "white");

  setFont("Serif", 18, "antiliased");
  y += 30;
  drawString("This is 18-point, 'Serif', antialiased'", x, y, "white");

  setColor("white");
  x2 = 200;
  drawLine(x2, y+5, x2, y+110);
  setFont("SansSerif", 20, "bold");
  y += 40;
  drawString("Left Justified", x2, y, "black");
  y += 32;
  setJustification("center");
  drawString("Centered", x2, y, "black");
  y += 32;
  setJustification("right");
  drawString("Right Justified", x2, y, "black");
 
  setFont("SansSerif" , 16, "antiliased");
  setJustification("center");
  drawString("123.45", 597, 73, "black");
  setJustification("left");

  setFont("SansSerif" , 24, "italic");
  y += 45;
  setColor("yellow");
  drawString("24-point, 'SansSerif', italic", x, y, "black");

  setFont("SansSerif" , 28, "antialiased");
  y += 50;
  setColor("red");
  drawString("28-point, 'SansSerif', antialiased", x, y, "blue");

  y += 60;
  setFont("Serif" , 18, "antialiased");
  setColor("black");
  s = "Multiple lines of\n"+
      "14-point, antialiased\n"+
      "Serif text\n";
  drawString(s+"left-justified", 50, y, "white");
  setJustification("center");
  drawString(s+"centered", 325, y, "white");
  setJustification("right");
  drawString(s+"right-justified", 600, y, "white");