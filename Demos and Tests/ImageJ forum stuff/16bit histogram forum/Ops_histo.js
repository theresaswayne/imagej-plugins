// @Dataset data
// @OpService ops

histogram = ops.image().histogram(data, 256);

print (histogram.size());
print (histogram.valueCount());
print (histogram.toLongArray());