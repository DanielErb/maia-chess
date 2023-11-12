#!/bin/bash

cd "$(dirname "$0")"


# Loop through all .pgn.zst files in ../data/lichess_raw
for file in ../data/lichess_raw/*.pgn.zst; do
    # Set output file name
    output_file="../data/lichess_raw/$(basename "${file%.pgn.zst}").bz2"
    # Convert file
    zstd -d -c "$file" | bzip2 > "$output_file"

done

echo "All files converted successfully."
