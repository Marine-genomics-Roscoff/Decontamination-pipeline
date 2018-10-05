#!/bin/bash

usage="$(basename "$0") [-h] -i \"folder\" -- program to compare pair of libraries (condor version)
where:
    -h  show this help text
    -i  set the input folder -- should be a complete path double quoted"

while getopts ':hi:' option; do
  case "$option" in
    h) echo "$usage"
       exit
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
  shift $((OPTIND - 1))
done

if [ "$inputFolders" == "" ]
then
   echo "missing input folder" >&2
   exit 1
fi

#mkdir logs
ls -C1 $inputFolders > data/processContamination.condor.list
condor_submit -batch-name "decont_[${inputFolders}]" processContamination.condor.sub -append "Arguments = processContamination.sh \$(Item) data/processContamination.condor.list"
