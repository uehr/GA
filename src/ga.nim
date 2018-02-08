import random,algorithm,os

type Gene* = seq[int]

var 
  goal* = @[21,17,13,10,7,6,4,3,2,1,1,0,0,0,0]
  genes* = newSeq[Gene]()
  genes_qty* = 500
  gene_ele_qty* = goal.len()
  gene_ele_limit* = 30
  mutation_percent* = 5
  log_interval* = 1

proc newGene* : Gene = 
  var buff = newSeq[int]()
  for i in 1..gene_ele_qty:
    buff.add(random(gene_ele_limit))
  return buff

proc initial* = 
  for i in 0..genes_qty:
    genes.add(newGene())
    
proc assess*(gene:Gene) : int =
  for i in 0..<gene.len():
    result += abs(goal[i] - gene[i])

proc `<`(left, right: Gene): bool =
  return assess(left) < assess(right)

proc `>`(left, right: Gene): bool =
  return assess(left) > assess(right)

proc `+`(left, right: Gene): Gene =
  var 
   p1 = random(gene_ele_qty)
   p2 = random(gene_ele_qty)
   l = left
   r = right

  if p1 > p2: swap(p1,p2)

  for i in p1..p2: swap(l[i], r[i])

  if random(100) < mutation_percent:
    r[random(gene_ele_qty)] = random(gene_ele_limit)
    l[random(gene_ele_qty)] = random(gene_ele_limit)

  if l < r: return l
  else: return r

proc generation_assess*() :int = 
  for gene in genes: 
    result += assess(gene)

proc cycle*() = 
  var next_generation = newSeq[Gene]()
  genes.sort(cmp[Gene])
  for _ in 0..<genes_qty:
    next_generation.add(genes[0] + genes[1])
  genes = next_generation