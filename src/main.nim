import random,algorithm,os

proc hr(len: int,title: string):string=
  var hr = ""
  var cnt = len - title.len()
  for i in 0..<cnt:
    if cnt div 2 == i:
      hr.add(title) 
    else:
      hr.add("-")
  hr

type Gene = seq[int]

var 
  goal = @[21,17,13,10,7,6,4,3,2,1,1,0,0,0,0]
  genes = newSeq[Gene]()
  genes_qty = 500
  gene_ele_qty = goal.len()
  gene_ele_limit = 30
  mutation_percent = 5
  log_interval = 1

proc newGene(): Gene = 
  var buff = newSeq[int]()
  for i in 1..gene_ele_qty:
    buff.add(random(gene_ele_limit))
  return buff

proc initial = 
  for i in 0..genes_qty:
    genes.add(newGene())
    
proc assess(gene:Gene): int =
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

proc generation_assess() :int = 
  for gene in genes: 
    result += assess(gene)

proc build_circle(gene:Gene):string =
  var buff = gene
  var circle = ""
  for i in 0..1:
    for j in 0..<buff.len():
      for _ in 0..buff[j]: circle.add(" ")
      circle.add("@")
      for _ in 0..((buff.len() * 2 - buff[j]) * 2): circle.add(" ")
      circle.add("@\n")
    buff.reverse()
  circle

proc build_quarter(gene:Gene):string = 
  var quarter = "";
  for i in 0..<gene.len():
    for _ in 0..gene[i]: quarter.add(" ")
    quarter.add("@\n")
  quarter

proc cycle() = 
  var next_generation = newSeq[Gene]()
  genes.sort(cmp[Gene])
  for _ in 0..<genes_qty:
    next_generation.add(genes[0] + genes[1])
  genes = next_generation

proc echo_generation_data(cnt:int, assess:int)=
  var content = " "
  content.add($cnt)
  content.add(" generation ")
  echo hr(gene_ele_qty * 5, content)
  echo "diff :", assess
  echo build_circle(genes[0])

initial()
genes.sort(cmp[Gene])
var ini_assess = assess(genes[0])
echo_generation_data(0, ini_assess)
sleep(3000)

var
  assess_buff = 1
  generation_cnt = 0
  assess_log = newSeq[int]()

while assess_buff > 0:
  cycle()
  if generation_cnt mod log_interval == 0:
    assess_buff = assess(genes[0])
    echo_generation_data(generation_cnt, assess_buff)
    assess_log.add(assess_buff)
  generation_cnt += 1
  sleep(100)

sleep(5000)
