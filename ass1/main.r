library(MASS)
library(nnet)
library(e1071)
library(class)

main1 = function() {
  data = read.csv("data.txt", header = TRUE)
  rows = nrow(data)

  for (k in 1:1) {
    res = smartKnn(data, k, rows)
    cat(sprintf("K=%d, R=%.3f\n", k, res))
  }
}

main2 = function() {
  data = read.csv("/Users/linus/Documents/Projekt/pattern-recognition-r/ass1/data.txt", header = TRUE)
  blocks = createDataBlocks(data, nrow(data))
  model = multinom(formula = lettr ~ ., data = blocks$training, maxit = 200)
  result = predict(model, blocks$testing, interval = "predict")
  table(blocks$testing[,1], result)
}

main4 = function() {
  data = read.csv("/Users/linus/Documents/Projekt/pattern-recognition-r/ass1/data.txt", header = TRUE)
  blocks = createDataBlocks(data, nrow(data))
  model = svm(formula = lettr ~ ., data = blocks$training)
  result = predict(model, blocks$testing, interval = "predict")
  table(blocks$testing[,1], result)
}

main3 = function() {
  data = read.csv("/Users/linus/Documents/Projekt/pattern-recognition-r/ass1/data.txt", header = TRUE)
  blocks = createDataBlocks(data, nrow(data))
  model = lda(formula = lettr ~ ., data = blocks$training)
  result = predict(model, blocks$testing)$class
  table(blocks$testing[,1], result)
  # printResult(result, blocks$testing)
}

main5 = function() {
  data = read.csv("/Users/linus/Documents/Projekt/pattern-recognition-r/ass1/data.txt", header = TRUE)
  blocks = createDataBlocks(data, nrow(data))
  for (i in 10:22) {
    model = nnet(formula = lettr ~ ., data = blocks$training, size = i)
    result = predict(model, blocks$testing, type = "class")
    cat(sprintf("=====> %d\n", i))
    print(table(blocks$testing[,1], result))
  }
}

main6 = function(){
  data = read.csv("data.txt", header = T)
  blocks = createDataBlocks(data, nrow(data))
  model = qda(formula = lettr ~ ., data = blocks$training)
  result = predict(model, blocks$testing)$class
  table(blocks$testing[,1], result)
}

createDataBlocks = function(data, rows = nrow(data), fraction = 0.25){
  indexes = 1 : rows
  testIndexes = sample(indexes, fraction * rows)
  trainingIndexes = indexes[-testIndexes]

  return(list(testing=data[testIndexes,], training=data[trainingIndexes,]))
}

printResult = function(result, testData) {
  for (i in 1:length(result)) {
    predict = result[i]
    should = testData[,1][i]
    cat(sprintf("could it be %s? it should be %s\n", predict, should))
  }
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