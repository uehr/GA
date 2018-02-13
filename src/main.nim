import ga
import os
import strutils

type Goal = object
  gene : seq[point] 
  max_x : int
  max_y : int

proc getGoalFromFile(file_name:string): Goal =
  var goalFile = open(file_name).readAll().splitLines()
  var res : Goal
  res.gene = newSeq[point]()
  for i in 0..<goalFile.len:
    for j in 0..<goalFile[i].len:
      if goalFile[i][j] != ' ':
        res.gene.add(point(x:j,y:i))
        res.max_x = max(res.max_x, j + 1)
        res.max_y = max(res.max_y, i + 1)
  return res

var goal = getGoalFromFile("star.txt")

var hoge = GA(goal:goal.gene, 
              mutation_percent:10,
              genes_cnt:50,
              genes_save_cnt:10,
              gene_ele_limit:goal.gene.len(),
              gene_x_limit: goal.max_x,
              gene_y_limit: goal.max_y)

var
  assess = 1
  cnt = 0

hoge.cycle()
hoge.generationPrint('.')
sleep(5000)

while assess != 0:
  hoge.cycle()
  assess = hoge.topGeneAssess()
  if cnt mod 10 == 0:
    # echo "Diff: ", assess 
    # echo "Generation: ", cnt
    hoge.generationPrint('.')
  cnt += 1

hoge.generationPrint('.')
echo readLine(stdin)