#!/bin/bash

# BIN=./redis-benchmark
BIN=./mc-benchmark
payload=32
iterations=100000
keyspace=100000

for clients in 1 5 10 20 30 40 50 60 70 80 90 100 200 300
do
    SPEED=0
    for dummy in 0 1 2
    do
        S=$($BIN -n $iterations -r $keyspace -d $payload -c $clients | grep 'per second' | tail -1 | cut -f 1 -d'.')
        if [ $(($S > $SPEED)) != "0" ]
        then
            SPEED=$S
        fi
    done
    echo "$clients $SPEED"
done
