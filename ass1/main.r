main = function() {
  data = read.csv("/Users/linus/Documents/Projekt/pattern-recognition-r/ass1/data.txt", header = TRUE)
  rows = nrow(data)

  for (k in 1:15) {
    res = smartKnn(data, k, rows)
    cat(sprintf("K=%d, R=%.3f\n", k, res))
  }
}

smartKnn = function(data, k = 1, rows = nrow(data), fraction = 0.25) {
  indexes = 1 : rows
  testIndexes = sample(indexes, fraction * rows)
  trainingIndexes = indexes[-testIndexes]
  ans = knn(data[trainingIndexes,-1], data[testIndexes,-1], data[trainingIndexes, 1], k)
  sum(data[testIndexes,1] == ans) / length(data[testIndexes,1])
}