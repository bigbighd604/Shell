#!/bin/bash
#
# Q. crawl products name and price from amazon
# Requiremens:
# 1. support different levels of pages
# 2. use regex
#


URL=$1
LEVEL=$2
CLEVEL=0
TMP=$(mktemp -d)

echo "TEMP Folder: $TMP"

cd $TMP

function crawl() {
  local url=$1
  local TMPFILE=$(mktemp --tmpdir=$TMP)
  wget -q -O "$TMPFILE" "$url" >/dev/null
  if [[ ! -s "$TMPFILE" ]]; then
    echo "Empty file for $url"
    exit
  fi
  local product=$(cat $TMPFILE| perl -nle 'print $1 if /<span id="btAsinTitle"\s*?\S*?>(.+?)</')
  #local price=$(cat $TMPFILE | perl -nle 'print $1 if /<b class="priceLarge\s*?\S*?"\s*?\S*?>(.*?)</')
  local price=$(cat $TMPFILE | perl -0777 -nle 'print $1 if /<b class="priceLarge\s*?\S*?"\s*?\S*?>\s*(.*?)\s*</')
  local product_urls=$(cat $TMPFILE | perl -nle 'print $1 if /href="(http:\/\/www.amazon.com\/.+?\/dp\/.*?)"/' | sort | uniq)
  echo "$product:$price: $url"
  if [[ $CLEVEL -lt $LEVEL ]];then
    for nurl in "$product_urls"; do
      crawl "$nurl"
    done
    CLEVEL=$((CLEVEL + 1))
  fi
}

crawl $URL
