#!/bin/bash

cd "$(dirname "$0")"

# Function to convert a compressed PGN file to bz2 format
convert_file() {
    local file="$1"
    local output_file="../data/lichess_raw/$(basename "${file%.pgn.zst}").bz2"
    
    zstd -d -c "$file" | bzip2 > "$output_file"
    echo "Converted: $file"
}

# Export the function for parallel processing
export -f convert_file

# Path to the directory containing compressed PGN files
input_dir="../data/lichess_raw"

# Find all compressed PGN files in the input directory
files=("$input_dir"/*.pgn.zst)

# Use GNU Parallel to run the conversion function in parallel
parallel convert_file ::: "${files[@]}"

echo "All files converted successfully."