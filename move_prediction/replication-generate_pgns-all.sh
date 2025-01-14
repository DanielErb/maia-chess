#!/bin/bash

start=${1:-1100}
end=${2:-1900}
jump=${3:-100}

# Fix - the code doesn't start in its own directory
cd "$(dirname "$0")"

echo "Current working directory: $(pwd)"

screen_pids=()
screen_pids_blocks=()

# Read the raw pgns from lichess and filter out the elo ranges we care about

# Function to filter Elo ranges
filter_elo_range() {
    elo=$1
    upperval=$(($elo + 100))
    outputdir="../data/pgns_ranged_filtered/${elo}"
    for f in ../data/lichess_raw/lichess_db_standard_rated_2017* ../data/lichess_raw/lichess_db_standard_rated_2018* ../data/lichess_raw/lichess_db_standard_rated_2019-{01..11}.bz2; do
#    for f in ../data/lichess_raw/lichess_db_standard_rated_2019-{01..11}.bz2; do
        t=$(echo $f | tail -c 5)
        if [ $t == ".bz2" ] && [  -f "$f" ]; then # Verify that we have something in this year
            fname="$(basename -- $f)"
            echo "${elo}-${fname}"
            source ~/.bashrc
            python3 ../data_generators/extractELOrange.py --remove_bullet --remove_low_time ${elo} ${upperval} ${outputdir}/${fname} ${f}
        fi
    done
}

# Use parallel to filter Elo ranges concurrently
export -f filter_elo_range
parallel filter_elo_range ::: $(seq $start $jump $end)


echo "Done filtering"
echo "Current working directory: $(pwd)"

# You have to wait for the screens to finish to do this
# We use pgn-extract to normalize the games and prepare for preprocessing
# This also creates blocks of 200,000 games which are useful for the next step

# Function to run pgn-extract for Elo ranges
run_pgn_extract() {
    elo=$1
    outputdir="../data/pgns_ranged_blocks/${elo}"

    for y in {2017..2019}; do
        cw=`pwd`
        echo "current working directory - ${cw}"
        echo "${elo}-${y}"
        cd $outputdir/$y
        source ~/.bashrc
        bzcat "../../../pgns_ranged_filtered/${elo}/lichess_db_standard_rated_${y}"* | pgn-extract -7 -C -N -#200000
        cd $cw
        echo "current working directory - ${cw}"
    done
}

# Use parallel to run pgn-extract concurrently
export -f run_pgn_extract
parallel run_pgn_extract ::: $(seq $start $jump $end)

echo "Done pgn-extract"
