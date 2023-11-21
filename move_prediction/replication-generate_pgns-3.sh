#!/bin/bash

# Fix - the code doesn't start in its own directory
cd "$(dirname "$0")"

echo "Current working directory: $(pwd)"

screen_pids=()
screen_pids_blocks=()

# Read the raw pgns from lichess and filter out the elo ranges we care about
mkdir ../data/pgns_ranged_filtered/

# Function to filter Elo ranges
filter_elo_range() {
    elo=$1
    upperval=$(($elo + 100))
    outputdir="../data/pgns_ranged_filtered/${elo}"
    mkdir -p $outputdir
    for f in ../data/lichess_raw/lichess_db_standard_rated_2017* ../data/lichess_raw/lichess_db_standard_rated_2018* ../data/lichess_raw/lichess_db_standard_rated_2019*; do
        fname="$(basename -- $f)"
        echo "${elo}-${fname}"
        source ~/.bashrc
        python3 ../data_generators/extractELOrange.py --remove_bullet --remove_low_time ${elo} ${upperval} ${outputdir}/${fname} ${f}
    done
}

# Use parallel to filter Elo ranges concurrently
export -f filter_elo_range
parallel filter_elo_range ::: {1600..1800..100}


echo "Done filtering"

# You have to wait for the screens to finish to do this
# We use pgn-extract to normalize the games and prepare for preprocessing
# This also creates blocks of 200,000 games which are useful for the next step
mkdir ../data/pgns_ranged_blocks

# Function to run pgn-extract for Elo ranges
run_pgn_extract() {
    elo=$1
    outputdir="../data/pgns_ranged_blocks/${elo}"
    mkdir -p $outputdir

    for y in {2017..2019}; do
        echo "${elo}-${y}"
        mkdir -p $outputdir/$y
        cd $outputdir/$y
        source ~/.bashrc
        bzcat "../../../pgns_ranged_filtered/${elo}/lichess_db_standard_rated_${y}"* | pgn-extract -7 -C -N -#200000
        cd ..
    done
}

# Use parallel to run pgn-extract concurrently
export -f run_pgn_extract
parallel run_pgn_extract ::: {1600..1800..100}

echo "Done pgn-extract"