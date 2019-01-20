# convert_nb_to_md.sh
# Convert the jupyter notebooks to markdown format and move to posts
# move the images to the images folder
# HELP:
#   https://cduvallet.github.io/posts/2018/03/ipython-notebooks-jekyll
#   https://linode.com/docs/applications/project-management/jupyter-notebook-on-jekyll/

INPUT=$1
# 1. convert .nb to .md
jupyter nbconvert $INPUT --to markdown

# 2. create new .md file with header and
DATE=$(date +%d-%m-%Y" "%H:%M:%S)
TITLE=`date +%Y-%m-%d`_jupyter_nb

touch _pages/_posts/$TITLE.md
cat > _pages/_posts/$TITLE.md <<- EOM
  ---
layout: post
title:  "Data Science Stuff"
date:   $DATE
categories:
  - data
---
EOM

# 3. copy contents of jupyter to new .md file
cat $INPUT | tee -a _pages/_posts/$TITLE.md

# 3. move images
mv _jupyter/*.jpg assets/images/.
