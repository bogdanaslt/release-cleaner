#!/bin/bash

keep_releases=2
releases_dir=$(pwd)

usage()
{
  echo "Usage: cleaner  [ -k | --keep RELEASES ] [ -p | --path PATH ]"
  exit 2
}

PARSED_ARGUMENTS=$(getopt -a -n cleaner.sh -o k:p: --long keep:,path: -- "$@")
VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ]; then
  usage
fi
eval set -- "$PARSED_ARGUMENTS"

while :
do
  case "$1" in
    -k | --keep) keep_releases="$2"; shift 2 ;;
    -p | --path) releases_dir="$2"; shift 2 ;;
    -- ) shift; break ;;
    *) echo "Unexpected option: $1 - this should not happen."
       usage ;;
  esac
done

releases_dir=${releases_dir%/}

if [[ "$keep_releases" -le "0" ]]; then
    echo "Releases count must be more than 0 ($keep_releases provided)"
    usage
    exit 1;
fi

if [[ -z $releases_dir ]]; then
    echo "Releases direcory not provided"
    usage
    exit 1;
fi

total=$(ls -l $releases_dir | grep '^d' | wc -l)
if [[ "$total" -lt "$keep_releases" ]]; then
    exit 0
fi
((total=total-keep_releases))
i=0
readarray -d '' entries < <(printf '%s\0' $releases_dir/*/ | sort -zV)
for directory in "${entries[@]}"; do
  if [[ "$total" -eq "$i" ]]; then
    exit 0
  fi
  echo $((i+1))/$total : deleteing $directory
  rm -rf $directory
  ((i=i+1))
done