#!/bin/bash

cd "$(dirname "$0")"

echo "Current working directory: $(pwd)"

mkdir ../data/elo_ranges
cw=`pwd`
for elo in {1100..1900..100}; do
    echo $i
    mkdir "../data/elo_ranges/${elo}"
    outputtest="../data/elo_ranges/${elo}/test"
    outputtrain="../data/elo_ranges/${elo}/train"
    mkdir $outputtest
    mkdir $outputtrain
    for te in "../data/pgns_ranged_training/${elo}"/*; do
        fname="$(basename -- $te)"
        echo "${elo}-${fname}"
        current_dir=$(pwd)
        cd $outputtrain
        echo "Current working directory: $(pwd)"
        mkdir $fname
        cd $fname
        echo "Current working directory: $(pwd)"
        #fixed problem traininigdata-tool doesnt only writes to input path
        #trainingdata-tool -v -files-per-dir 5000 "${current_dir}/${te}"
        screen -S "${elo}-${fname}-test" -dm bash -c "trainingdata-tool -v -files-per-dir 5000 ${current_dir}/${te}"
        cd "$current_dir"
        echo "Current working directory: $(pwd)"
    done
    for te in "../data/pgns_ranged_testing/${elo}"/{1..2}.pgn; do
        fname="$(basename -- $te)"
        echo "${elo}-${fname}"
        current_dir=$(pwd)
        cd $outputtest
        echo "Current working directory: $(pwd)"
        mkdir $fname
        cd $fname
        echo "Current working directory: $(pwd)"
        #echo "trainingdata-tool -v -files-per-dir 5000 ${te}"
        #trainingdata-tool -v -files-per-dir 5000 ${te}
        screen -S "${elo}-${fname}-test" -dm bash -c "trainingdata-tool -v -files-per-dir 5000 ${current_dir}/${te}"
        cd "$current_dir"
        echo "Current working directory: $(pwd)"
    done
    te="../data/final_training_data/pgns_ranged_testing/${elo}/3.pgn"    fname="$(basename -- $te)"
    echo "${elo}-${fname}"
    current_dir=$(pwd)
    cd $outputtest
    echo "Current working directory: $(pwd)"
    mkdir $fname
    cd $fname
    echo "Current working directory: $(pwd)"
    #trainingdata-tool -v -files-per-dir 5000 ${te}
    screen -S "${elo}-${fname}-test" -dm bash -c "trainingdata-tool -v -files-per-dir 5000 ${current_dir}/${te}"
    cd "$current_dir"
    echo "Current working directory: $(pwd)"
done

while screen -list | grep -q "test"; do
    sleep 1
done

cd $cw
echo "Current working directory: $(pwd)"


#not clear if there's a need to really kill them
#for scr in $(screen -ls | awk '{print $1}'); do if [[ $scr == *"test"* ]]; then echo $scr; screen -S $scr -X kill; fi; done

#for scr in $(screen -ls | awk '{print $1}'); do if [[ $scr == *"2200"* ]]; then echo $scr; screen -S $scr -X kill; fi; done


#for scr in $(screen -ls | awk '{print $1}'); do if [[ $scr == *"final"* ]]; then echo $scr; screen -S $scr -X kill; fi; done
