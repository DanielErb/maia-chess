#!/bin/bash

for f in data/lichess_raw/lichess_db_standard_rated_2020* data/lichess_raw/lichess_db_standard_rated_2019-{01..11}.pgn.bz2; do
  t=$(echo $f | tail -c 5)
  echo $t
  if [ $t == ".bz2" ]; then
    echo $t
  fi
done