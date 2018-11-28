#!/bin/bash

usage="$(basename "$0") [-h] -q \"query\" -r \"ref\" -- program to compare pair of libraries (condor version)
where:
    -h  show this help text
    -r  set the where the references are -- should be a complete path double quoted
    -q  folder with libraries to be compared with all the others in the ref folder -- should be a complete path double quoted"

while getopts h:r:q: option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    q) targetLibs=$OPTARG
       ;;
    r) inputFolders=$OPTARG
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

if [ "$inputFolders" == "" ]
then
   echo "missing ref folder" >&2
   exit 1
fi

if [ "$targetLibs" == "" ]
then
   targetLibs="$inputFolders"
fi

#mkdir logs
ls -C1 $inputFolders > data/processContamination.condor.list
ls -C1 $targetLibs > data/target.list
condor_submit -batch-name "decont_[${inputFolders}]" processContamination.condor.sub -append "Arguments = processContamination.sh \$(Item) data/target.list"
