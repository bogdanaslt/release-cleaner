#!/bin/bash

keep_releases=2
releases=$(pwd)
while getopts ":c:p:" opt; do
  case $opt in
    c)
      re='^[0-9]+$'
      if ! [[ $OPTARG =~ $re ]] ; then
        echo "error: -c must be an integer number" >&2; exit 1
      fi
      keep_releases=$OPTARG
      ;;
    p)
        releases=${OPTARG%/}
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [[ -z $releases ]]; then
    echo "Releases direcory not provided. Useage:"
    echo "cleaner.sh -c 2 -p /path/to/releases/directory"
    exit 1;
fi

total=$(ls -l $releases | grep '^d' | wc -l)
if [[ "$total" -lt "$keep_releases" ]]; then
    exit 0
fi
((total=total-keep_releases))
i=0
readarray -d '' entries < <(printf '%s\0' $releases/*/ | sort -zV)
for directory in "${entries[@]}"; do
  if [[ "$total" -eq "$i" ]]; then
    exit 0
  fi
  echo $i/$total : deleteing $directory
  rm -rf $directory
  ((i=i+1))
done