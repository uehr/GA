import random,algorithm,os,ga

let element_char = "."

proc hr(len: int,title: string):string=
  var hr = ""
  var cnt = len - title.len()
  for i in 0..<cnt:
    if cnt div 2 == i:
      hr.add(title) 
    else:
      hr.add("-")
  hr

proc build_circle(gene:Gene):string =
  var buff = gene
  var circle = ""
  for i in 0..1:
    for j in 0..<buff.len():
      for _ in 0..buff[j]: circle.add(" ")
      circle.add(element_char)
      for _ in 0..((buff.len() * 2 - buff[j]) * 2): circle.add(" ")
      circle.add(element_char)
      circle.add("\n")
    buff.reverse()
  circle

proc build_quarter(gene:Gene):string = 
  var quarter = "";
  for i in 0..<gene.len():
    for _ in 0..gene[i]: quarter.add(" ")
    quarter.add(element_char)
    quarter.add("\n")
  quarter

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