#!/bin/bash                                                                                                                                                          
#
for i in `seq 0 7`
do
  echo f|sudo tee /sys/class/net/em1/queues/rx-$i/rps_cpus >/dev/null
  echo f|sudo tee /sys/class/net/em2/queues/rx-$i/rps_cpus >/dev/null
done