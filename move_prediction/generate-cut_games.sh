
#!/bin/bash
start=${1:-1100}
end=${2:-1900}
jump=${3:-100}


cd "$(dirname "$0")"
echo "Current working directory: $(pwd)"


process_elo() {
    elo=$1
    outputtest="../data/pgns_ranged_testing_cut/${elo}"
    outputtrain="../data/pgns_ranged_training_cut/${elo}"
    
    mkdir -p $outputtest
    mkdir -p $outputtrain

    for te in "../data/pgns_ranged_training/${elo}"/*; do
        fname="$(basename -- $te)"
        echo "${elo}-${fname}"
        current_dir=$(pwd)
        python3 cut_games.py ../data/pgns_ranged_training/${elo} ${outputtrain}
    done

    for te in "../data/pgns_ranged_testing/${elo}"/{1..3}.pgn; do
        fname="$(basename -- $te)"
        echo "${elo}-${fname}"
        current_dir=$(pwd)
        python3 cut_games.py ../data/pgns_ranged_testing/${elo} ${outputtest}
    done

}

# Using parallel for post-loop processing
export -f process_elo
parallel process_elo ::: $(seq $start $jump $end)

echo "Current working directory: $(pwd)"