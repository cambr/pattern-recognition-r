main = function() {
  data = read.csv("/Users/linus/Documents/Projekt/pattern-recognition-r/ass1/data.txt", header = TRUE)
  rows = nrow(data)

  for (k in 1:1) {
    res = smartKnn(data, k, rows)
    cat(sprintf("K=%d, R=%.3f\n", k, res))
  }
}

#
#
#
#
#
#
#
#
main2 = function() {
  data = read.csv("/Users/linus/Documents/Projekt/pattern-recognition-r/ass1/data.txt", header = TRUE)
  fraction = 0.25
  rows = nrow(data)
  indexes = 1 : rows
  testIndexes = sample(indexes, fraction * rows)
  trainingIndexes = indexes[-testIndexes]

  result = multinom(formula = lettr ~ ., data = data[trainingIndexes,])
  model = exp(coef(result)) # Convert to matrix
  
  for (irowTest in 1:nrow(data[testIndexes,-1])) {
    bestChar = NULL
    lowestValue = -1
    for (irowModel in 1:nrow(model)) {
      l = l(model[irowModel,], data[testIndexes,-1][irowTest,])
      if(l > lowestValue){
        bestChar = names(model[,1][irowModel])
        lowestValue = l
      }
    }

    cat(sprintf("l=%.3f, could it be %s? it should be %s\n", lowestValue, bestChar, data[testIndexes, 1][irowTest]))
  }
}

#
# Den korta listan = v2
#
l = function (v1, v2) {
  print(v1)
  print(v2)
  print("------")
  v1[1] + sum(v1[-1] * v2)
}

p = function (l) {
  e = exp(1)
  return(e^l / (e^l + 1))
}

smartKnn = function(data, k = 1, rows = nrow(data), fraction = 0.25) {
  indexes = 1 : rows
  testIndexes = sample(indexes, fraction * rows)
  trainingIndexes = indexes[-testIndexes]
  ans = knn(data[trainingIndexes,-1], data[testIndexes,-1], data[trainingIndexes, 1], k)

  result = c()
  for (i in 1:length(ans)) {
    o = as.character(data[testIndexes,1][i])
    if(is.null(result[o]) || is.na(result[o])){
      result[o] = 0 
    }

    if(o == ans[i]){
      result[o] = result[o] + 1
    }
  }

  worst = Inf
  best = 0
  bestChar = NULL
  worstChar = NULL

  for (char in names(result)) {
    amount = result[char]
    res = amount / sum(data[testIndexes,1] == char)
    cat(sprintf("%s => %.3f\n", char, res))
    if(res > best) {
      best = res
      bestChar = char
    }

    if(res < worst) {
      worst = res
      worstChar = char
    }
  }

  cat(sprintf("Worst (%.3f): %s, Best (%.3f): %s\n", worst, worstChar, best, bestChar))
  sum(data[testIndexes,1] == ans) / length(data[testIndexes,1])
}