library(MASS)
library(nnet)
library(e1071)
library(class)

main1 = function() {
  data = read.csv("/Users/linus/Documents/Projekt/pattern-recognition-r/ass1/data.txt", header = TRUE)
  blocks = createDataBlocks(data, nrow(data))
  for (k in 1:1) {
    model = knn(blocks$training[,-1], blocks$testing[,-1], blocks$training[,1], k)
    calcResult(blocks, model)
    print(table(blocks$testing[,1], model))
  }
}

main2 = function() {
  data = read.csv("/Users/linus/Documents/Projekt/pattern-recognition-r/ass1/data.txt", header = TRUE)
  blocks = createDataBlocks(data, nrow(data))
  model = multinom(formula = lettr ~ ., data = blocks$training, maxit = 200)
  result = predict(model, blocks$testing, interval = "predict")
  calcResult(blocks, result)
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
  print(table(blocks$testing[,1], result))
  print(calcResult(blocks, result))
}

main5 = function() {
  data = read.csv("/Users/linus/Documents/Projekt/pattern-recognition-r/ass1/data.txt", header = TRUE)
  blocks = createDataBlocks(data, nrow(data))
  for (i in 10:22) {
    model = nnet(formula = lettr ~ ., data = blocks$training, size = i, decay = i)
    result = predict(model, blocks$testing, type = "class")
    print("------------")
    print(i)
    print(calcResult(blocks, result))
    cat(sprintf("=====> %d\n", i))
    print(table(blocks$testing[,1], result))
  }
}

main6 = function(){
  data = read.csv("/Users/linus/Documents/Projekt/pattern-recognition-r/ass1/data.txt", header = TRUE)
  blocks = createDataBlocks(data, nrow(data))
  model = qda(formula = lettr ~ ., data = blocks$training)
  result = predict(model, blocks$testing)$class
  print(table(blocks$testing[,1], result))
  print(calcResult(blocks, result))
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

calcResult = function(blocks, model) {
  result = c()
  for (i in 1:length(model)) {
    o = as.character(model[i])
    if(is.null(result[o]) || is.na(result[o])){
      result[o] = 0
    }

    if(o == blocks$testing[i,1]){
      result[o] = result[o] + 1
    }
  }

  worst = Inf
  best = 0
  bestChar = NULL
  worstChar = NULL

  for (char in names(result)) {
    amount = result[char]
    res = amount / sum(blocks$testing[,1] == char)
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
  sum(blocks$testing[,1] == model) / length(blocks$testing[,1])
}