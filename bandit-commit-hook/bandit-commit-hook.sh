#!/bin/bash
echo "================================================================================="
echo "Bandit scan is initiated"
cd $PWD
files=$(git diff-tree --no-commit-id --name-only -r $(git log --format="%H" -n 1))
for file in $files
do
    bandit $file
done
echo "Bandit scan is done"
echo "================================================================================="