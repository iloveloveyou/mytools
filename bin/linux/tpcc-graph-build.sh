#!/bin/bash
### goto user homedir and remove previous file
rm -f '$2'
#gnuplot << EOP
#### set data source file
#datafile = '$1'
#### set graph type and size
#set terminal jpeg size 640,480
#### set titles
#set grid x y
#set xlabel "Time (sec)"
#set ylabel "Transactions"
#### set output filename
#set output '$2'
#### build graph
## plot datafile with lines
#plot datafile title "5.6.13, binlog" with lines, \
#datafile using 3:4 title "5.6.13, nobinlog" with lines axes x1y1
#EOP

gnuplot << EOP
set style line 1 lt 1 lw 3
set style line 2 lt 5 lw 3
set style line 3 lt 9 lw 3
set terminal jpeg size 640,480
set grid x y
set xlabel "Time(sec)"
set ylabel "Transactions"
set output '$2'
plot "$1" title "PS 5.1.56 buffer pool 8M" ls 1 with lines , \
     "$1" us 3:4 title "PS 5.1.56 buffer pool 512M" ls 2 with lines ,\
     "$1" us 5:6 title "PS 5.1.56 buffer pool 2G" ls 3 with lines axes x1y1
EOP
