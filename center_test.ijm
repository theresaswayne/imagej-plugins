run("Leaf");
makeRectangle(200, 130, 80, 60);
run("Draw", "slice");
Roi.getBounds(x, y, width, height);
// find the center of the tile roi
centerX = x + (width/2);
centerY = y + (height/2);
print("center is",centerX,",",centerY);
//makePoint(centerX, centerY, "large");

makeRectangle(300, 60, 80, 60);
run("Draw", "slice");
Roi.getBounds(xA, yA, widthA, heightA);
// find the center of the tile roi
centerXA = xA + (widthA/2);
centerYA = yA + (heightA/2);
print("centerA is",centerXA,",",centerYA);
makePoint(centerXA, centerYA, "large");

dist = sqrt(pow((centerX-centerXA),2) + pow((centerY-centerYA),2));
print("Distance between centers is",dist);

test = 4;
testsqd = pow(test,2);
print(test, testsqd);

my = newArray("my");
Array.print(my);
my = Array.concat(my,"word");
Array.print(my);


  print("original arrays");
  a = newArray("a1","a2","a3");
  Array.print(a);
  b = newArray("b1","b2","b3");
  Array.print(b);

  print("concatenated arrays");
  c = Array.concat(a, b);
  Array.print(c);

  print("add value to beginning of an array");
  a = Array.concat("xx", a);
  Array.print(a);

  print("add value to end of an array");
  b = Array.concat(b, "xx");
  Array.print(b);

  print("double the size of an array");
  a = newArray("a1","a2","a3");
  a = Array.concat(a, newArray(a.length));
  Array.print(a);

