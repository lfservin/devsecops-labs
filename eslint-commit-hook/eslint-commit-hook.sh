#!/bin/bash
echo "================================================================================="
echo "ES Lint scan is initiated"
cd $PWD
files=$(git diff-tree --no-commit-id --name-only -r $(git log --format="%H" -n 1))
for file in $files
do
    eslint $file
done
echo "ES Lint scan is done"
echo "================================================================================="