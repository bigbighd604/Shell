#!/bin/bash

# Find users from /etc/passwd with duplicate ids.
# Very simple, just a quick implementation.

dup_id=""
counter=0
dup_names=""

cat "$1" | cut -d ':' -f 1-3 | sed -e 's/:/ /g' | sort -k 3 >"$1.sorted"

while read user pass uid; do
  cur_id=$uid
  if [[ "$dup_id" != "$cur_id" ]]; then
    if [[ -n "$dup_id" && $counter -gt 1 ]]; then
      echo "$dup_id [$counter] : $dup_names"
      counter=0
    fi
    dup_id=$cur_id
    dup_names="$user"
    counter=1
  else
    dup_names="$dup_names $user"
    counter=$((counter+1))
  fi
done <"$1.sorted"
