 macro "Measure Segmented Distances [1]" {
  if (!(selectionType==6||selectionType==10))
      exit("Segmented line or point selection required");
  getSelectionCoordinates(x, y);
  if (x.length<2)
      exit("At least two points required");
  getPixelSize(unit, pw, ph);
  n = nResults;
  distance = 0;
  totalDistance=0;
  for (i=1; i<x.length; i++) {
     dx = (x[i] - x[i-1])*pw;
     dy = (y[i] - y[i-1])*ph;
     distance = sqrt(dx*dx + dy*dy);
     setResult("D"+i, n, distance);
     totalDistance+=distance;
  }
  updateResults;
  print(totalDistance);
} 