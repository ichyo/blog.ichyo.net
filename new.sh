#!/bin/sh
set -eu

POST_DIR=_posts

function show_usage() {
    echo "Usage: $(basename "$0") title date"
    exit 1
}

if [ $# -ne 2 ]; then
    show_usage
fi

SITE_TITLE=$(grep "title: " _config.yml | cut -d' ' -f2)
RAW_PAGE_TITLE=$(echo $1 | awk '{$1=$1};1')
FILE_PAGE_TITLE=$(echo "$RAW_PAGE_TITLE" | sed -E 's/[\t ]+/-/g')
DATE=$(date -d "$2" +"%Y-%m-%d")
FILE_PATH=$POST_DIR/$DATE-$FILE_PAGE_TITLE.md

if [ -e $FILE_PATH ]; then
    echo "Error: $FILE_PATH already exists"
    exit 1
fi

echo "$FILE_PATH"

cat <<EOF > $FILE_PATH
---
layout: post
title: $RAW_PAGE_TITLE - $SITE_TITLE
---

Hello world
EOF

