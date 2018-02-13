import random
import algorithm
import os
import strutils
import math

type point* = object
  x*: int
  y*: int

type Gene = seq[point]

type GA* = object
  goal* : seq[point]
  generation* : seq[Gene]
  generation_cnt* : int
  mutation_percent* : int
  genes_save_cnt* : int
  genes_cnt* : int
  gene_ele_limit* : int
  gene_x_limit* : int
  gene_y_limit* : int

proc getPoints*(ga:GA, goal:string) : seq[point] =
  var goal_lines = goal.splitLines()
  for x in 0..<goal_lines.len:
    for y in 0..<goal_lines[x].len:
      if goal_lines[x][y] != ' ':
        result.add(point(x:x, y:y))

proc newPoint*(ga:GA) : point =
  return point(x:random(ga.gene_x_limit), y:random(ga.gene_y_limit))

proc newGene*(ga:GA) : Gene = 
  var res = newSeq[point]()
  for i in 0..<ga.gene_ele_limit:
    res.add(ga.newPoint())
  return res

proc newGeneration*(ga:GA) : seq[Gene] = 
  var res = newSeq[Gene]()
  for i in 0..<ga.genes_cnt:
    res.add(ga.newGene())
  return res

proc distance*(a,b : point) : int =
  var dx = a.x - b.x
  var dy = a.y - b.y
  return sqrt(pow(dx.float, 2) + pow(dy.float, 2)).int

proc geneAssess*(ga:GA, gene:Gene) : int =
  for i in 0..<gene.len():
    result += distance(ga.goal[i], gene[i])

proc getRouletteProbabilitys*(ga:GA) : seq[int] =
  var 
    res = newSeq[int]()
    tmp : float = ga.genes_cnt.float
    sum : int = 0

  res.add(0)
  while tmp >= 2:
    tmp = tmp / 1.5
    sum += tmp.int
    res.add(sum)

  res.add(ga.genes_cnt.int)

  return res

proc getRouletteArrowPoint*(ga:GA) : int =
  var arrow = random(ga.genes_cnt)
  var probabilitys = ga.getRouletteProbabilitys()
  var generation_cell = (ga.genes_cnt / probabilitys.len()).int
  for i in 1..<probabilitys.len():
    var start = probabilitys[i - 1]
    var finish = probabilitys[i]
    if arrow >= start and arrow <= finish:
      return generation_cell * i 

proc geneSelect*(ga:GA) : Gene =
  var
    elite_range = ga.getRouletteArrowPoint()
  return ga.generation[random(elite_range)]

proc cross*(ga:GA, root1, root2: var Gene): Gene =
  var 
    child = newSeq[point](ga.gene_ele_limit)

  for i in 0..<ga.gene_ele_limit:
    var
      min_x = min(root1[i].x, root2[i].x)
      max_x = max(root1[i].x, root2[i].x)
      min_y = min(root1[i].y, root2[i].y)
      max_y = max(root1[i].y, root2[i].y)

    if min_x == max_x or random(100) <= ga.mutation_percent:
      max_x += 1

    if min_y == max_y or random(100) <= ga.mutation_percent:
      max_y += 1

    var
      x = random(max(min_x, 0)..min(max_x, ga.gene_x_limit))
      y = random(max(min_y, 0)..min(max_y, ga.gene_y_limit))

    child[i] = point(x:x, y:y)

  return child

proc mutation(ga:var GA) =
  for i in 0..<ga.genes_cnt:
    if random(100) < ga.mutation_percent:
      var hoge = random(ga.gene_ele_limit)
      ga.generation[i][hoge] = ga.newPoint()

proc generationAssess*(ga:GA) :int = 
  for gene in ga.generation: 
    result += ga.geneAssess(gene)

proc topGeneAssess*(ga:GA) :int=
  return ga.geneAssess(ga.generation[0])

proc generationPrint*(ga: GA, ch:char) =
  var canvas = newSeq[string](ga.gene_y_limit)
  for i in 0..<ga.gene_y_limit:
    canvas[i] = " ".repeat(ga.gene_x_limit)

  for j in ga.generation[0]: 
    canvas[j.y][j.x] = ch

  echo "-".repeat(ga.gene_x_limit)
  for i in canvas: echo i
  echo "-".repeat(ga.gene_x_limit)

proc goalPrint*(ga: GA, ch:char) =
  var canvas = newSeq[string](ga.gene_y_limit)
  for i in 0..<ga.gene_y_limit:
    canvas[i] = " ".repeat(ga.gene_x_limit)

  for j in ga.goal: 
    canvas[j.y][j.x] = ch

  for i in canvas:
    echo i

proc cycle*(ga: var GA) = 
  if ga.generation != nil:
    var next = ga
    next.generation.sort(proc(left, right: Gene) : int = 
                         return next.geneAssess(left) - next.geneAssess(right))

    ga.generation.setLen(0)

    for i in 0..<ga.genes_save_cnt:
      ga.generation.add(next.generation[i])

    for _ in 0..<ga.genes_cnt - ga.genes_save_cnt:
      var
        elite1 = next.geneSelect()
        elite2 = next.geneSelect()
      ga.generation.add(next.cross(elite1, elite2))

    ga.mutation()
  else:
    ga.generation = ga.newGeneration()