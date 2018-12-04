#!/bin/bash

usage="$(basename "$0") [-h] -p \"patternFile\" -t  \"targetFile\" -- [grep -Ff pattern.txt target.txt] with awk
where:
    -h  show this help text
    -p  file with the patterns to be found
    -t  file to be searched"

while getopts h:t:p: option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    p) patternFile=$OPTARG
       ;;
    t) targetFile=$OPTARG
       ;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
   \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac
done

if [ "$patternFile" == "" ]
then
   echo "missing pattern file" >&2
   exit 1
fi

if [ "$targetFile" == "" ]
then
   echo "missing target file" >&2
   exit 1
fi

awk -v patternFile="${patternFile}" -v targetFile="${targetFile}" '
BEGIN {
   pSize=1
   while (getline < patternFile)
   {
      pattern[pSize] = $0
      pSize = pSize + 1
   }

   while (getline < targetFile)
   {
      for (i = 1; i < pSize; ++i)
      {
         if (index($0, pattern[i]) > 0)
         {
            print $0
            break
         }
      }
   }
}
'
