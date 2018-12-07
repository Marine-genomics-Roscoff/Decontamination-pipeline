#!/bin/bash

usage="$(basename "$0") [-h] -t \"target\" -i \"folder\" -- program to compare pair of libraries (condor version)
where:
    -h  show this help text
    -i  set the input folder -- should be a complete path double quoted
    -t  folder with libraries to be compared with all the other in the input folder -- should be a complete path double quoted"

while getopts h:t:i: option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    t) targetLibs=$OPTARG
       ;;
    i) inputFolders=$OPTARG
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
   echo "missing input folder" >&2
   exit 1
fi

if [ "$targetLibs" == "" ]
then
   targetLibs="$inputFolders"
fi

#mkdir logs
ls -C1 $inputFolders > data/processContamination.condor.list
ls -C1 $targetLibs > data/target.list

if [ "$targetLibs" == "$inputFolders" ]
then
   condor_submit -batch-name "decont_[${inputFolders}]" processContamination.condor.sub -append "Arguments = processSelfContamination.sh \$(Item) data/target.list"
else
   condor_submit -batch-name "decont_[${inputFolders}]" processContamination.condor.sub -append "Arguments = processContamination.sh \$(Item) data/target.list"
fi
