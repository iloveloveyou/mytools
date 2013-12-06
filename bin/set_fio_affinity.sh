#!/bin/bash
#PCI-E SSD卡中断配置问题

set_affinity()
{
    MASK_TMP=$((1<<(`expr $VEC + $CORE`)))
    MASK=`printf "%X" $MASK_TMP`
    printf "%s mask=%s for /proc/irq/%d/smp_affinity\n" $DEV$VEC $MASK $IRQ
    printf "%s" $MASK > /proc/irq/$IRQ/smp_affinity
}


if [ $# -ne 1 ] ; then
    echo "usage:"
    echo "    $0 core "
    exit
fi

CORE=$1
DEV="iodrive-fct"
MAX=`grep -i $DEV /proc/interrupts | wc -l`
if [ "$MAX" == "0" ] ; then
    echo no $DIR vectors found on $DEV
    exit
fi

for VEC in `seq 0 1 $MAX`
do
    for IRQ in `cat /proc/interrupts | grep -i $DEV$VEC|cut  -d:  -f1| sed "s/ //g"`
    do
        set_affinity
    done
done

# ./set_fio_affinity.sh 30 
#iodrive-fct0 mask=40000000 for /proc/irq/144/smp_affinity
#iodrive-fct1 mask=80000000 for /proc/irq/145/smp_affinity
