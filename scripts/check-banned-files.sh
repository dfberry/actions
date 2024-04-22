errors=""
root_dir=$(git rev-parse --show-toplevel)
file_path="$root_dir/.github/policies/banned-files.txt"

echo "Root directory: $root_dir"
echo "File path: $file_path"

if [ ! -f "$file_path" ]; then
    echo "No banned files found"
    exit 0
fi

banned_files=$(tr '[:upper:]' '[:lower:]' < "$file_path" | xargs)
echo "Banned files: $banned_files"

diff_output=$(git diff --name-only --diff-filter=A origin/main)
echo "Diff output: $diff_output"

while IFS= read -r file; do
    echo "Processing file: $file"
    file_lower=$(echo "$file" | tr '[:upper:]' '[:lower:]' | xargs)
    echo "File lower: $file_lower"
    grep_output=$(echo "$banned_files" | grep -Fx "$file_lower")
    echo "Grep output: $grep_output"
    if [ -n "$grep_output" ]; then
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
    echo "No banned files found"
    exit 0
fi

