
#!/bin/bash

cd "$(dirname "$0")"
echo "Current working directory: $(pwd)"



process_elo() {
    elo=$1
    mkdir -p "../data/elo_ranges/${elo}"
    outputtest="../data/elo_ranges/${elo}/test"
    outputtrain="../data/elo_ranges/${elo}/train"
    
    mkdir -p $outputtest
    mkdir -p $outputtrain

    for te in "../data/pgns_ranged_training/${elo}"/*; do
        fname="$(basename -- $te)"
        echo "${elo}-${fname}"
        current_dir=$(pwd)
        cd $outputtrain
        mkdir $fname
        cd $fname
        trainingdata-tool -v -files-per-dir 5000 ${current_dir}/${te}
        cd "$current_dir"
    done

    for te in "../data/pgns_ranged_testing/${elo}"/{1..3}.pgn; do
        fname="$(basename -- $te)"
        echo "${elo}-${fname}"
        current_dir=$(pwd)
        cd $outputtest
        mkdir $fname
        cd $fname
        trainingdata-tool -v -files-per-dir 5000 ${current_dir}/${te}
        cd "$current_dir"
    done

}

# Using parallel for post-loop processing
export -f process_elo
parallel process_elo ::: {1100..1300..100}

echo "Current working directory: $(pwd)"