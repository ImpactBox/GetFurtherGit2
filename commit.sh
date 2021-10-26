#!/bin/bash
echo 'Commit message:'
read commitMessage

ant retrieve
python build.py
ant cleanUp

git add -A
git commit -m "$commitMessage"
git push origin HEAD


