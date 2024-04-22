#!/bin/bash
# check-files.sh

# $1 = file name with path
# $2 = flag indicating whether the values in the file should be accepted or rejected: 1=accept, 2=reject

errors=""
root_dir=$(git rev-parse --show-toplevel)

# First command-line argument is the file name with path
file_path="$root_dir/$1"

echo "Root directory: $root_dir"
echo "File path: $file_path"

if [ ! -f "$file_path" ]; then
    echo "No files found in $file_path"
    exit 0
fi

# Second command-line argument is the flag indicating whether the values in the file should be accepted or rejected
# 1=accept, 2=reject
flag=$2

file_values=$(tr '[:upper:]' '[:lower:]' < "$file_path" | xargs)
echo "File values: $file_values"

diff_output=$(git diff --name-only --diff-filter=A origin/main)
echo "Diff output: $diff_output"

while IFS= read -r file; do
    
    echo "Processing file: $file"

    file_lower=$(echo "$file" | tr '[:upper:]' '[:lower:]' | xargs)
    echo "File lower: $file_lower"

    grep_output=$(echo "$file_values" | grep -Fx "$file_lower")
    echo "Grep output: $grep_output"

    if [ "$flag" = "0" -a -n "$grep_output" ]; then
        errors="${errors}File $file is not allowed\n"
        echo "File $file is not allowed"
    elif [ "$flag" != "0" -a -z "$grep_output" ]; then
        errors="${errors}File $file is not allowed\n"
        echo "File $file is not allowed"
    else
        echo "File $file is allowed"
    fi
    echo "Errors: $errors"
done < <(echo "$diff_output")

echo "Errors-2: $errors"

if [ -n "$errors" ]; then
    echo -e "$errors"
    exit 1
else
    echo "No disallowed files found"
    exit 0
fi