#!/bin/bash

#fix - the code doesnt start in its own directory
cd "$(dirname "$0")"

echo "Current working directory: $(pwd)"

mkdir ../data/pgns_ranged_filtered/
for i in {1000..2000..100}; do
    echo $i
    outputdir="../data/pgns_ranged_filtered/${i}"
    mkdir $outputdir
done


mkdir ../data/pgns_ranged_blocks
for i in {1000..2000..100}; do
    echo $i
    cw=`pwd`
    outputdir="../data/pgns_ranged_blocks/${i}"
    mkdir $outputdir
    cd $outputdir
    for y in {2017..2019}; do
        mkdir $y
    done
    cd $cw
    # y=2013
    # echo "${i}-${y}"
    # mkdir $y
    # cd $y
    # #source ~/.bashrc; bzcat "../../../pgns_ranged_filtered/${i}/lichess_db_standard_rated_${y}"* | pgn-extract -7 -C -N  -#200000
    # screen -S "${i}-${y}" -dm bash -c "source ~/.bashrc; bzcat \"../../../pgns_ranged_filtered/${i}/lichess_db_standard_rated_${y}\"* | pgn-extract -7 -C -N  -#200000"
    # screen_pids_blocks+=($!)
    # cd ..
    # cd $cw
done
