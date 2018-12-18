#!/bin/bash

usage="$(basename "$0") [-h] -i \"folder\" -- program build the table of species -- check duplicate files/species and it will be usefull to elect the candidates with contamination
where:
    -h  show this help text
    -i  set the input folder -- should be a complete path double quoted"

while getopts h:i: option; do
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
done

if [ "$inputFolders" == "" ]
then
   echo "missing input folder" >&2
   exit 1
fi

echo "#duplicate files:"
grep -m1 "^>" $inputFolders | cut -d ":" -f 1 | rev | cut -d "/" -f 1 | cut -d "." -f 2- | rev | sort | uniq -c | sed "s/^[ ]\+//" | grep -v "^1 " | sed "s/^/#/"
echo "#duplicate species:"
grep -m1 "^>" $inputFolders | cut -d ":" -f 2 | awk -F 'ORGANISM=' '{print $2}' | cut -d "\"" -f 2 | sort | uniq -c | sed "s/^[ ]\+//" | grep -v "^1 " | sed "s/^/#/"

echo "#table:"
while read library
do
   fileName=`echo "$library" | cut -d ":" -f 1 | rev | cut -d "/" -f 1 | cut -d "." -f 2- | rev`
   specieName=`echo "$library" | cut -d ":" -f 2 | awk '{print toupper($0)}' | awk -F 'ORGANISM=' '{print $2}' | cut -d "\"" -f 2`
   taxon=`echo "$library" | cut -d ":" -f 2 |  awk '{print toupper($0)}' | awk -F 'TAXON_ID=' '{print $2}' | cut -d " " -f 1`
   echo "$fileName"$'\t'"$specieName"$'\t'"$taxon" | sed "s/\//-/g"
   echo "fileName: [${fileName}] -> speciesName: [${specieName}] taxon: [${taxon}]"
   if [ "${taxon}" == "" ] || [ "${specieName}" == "" ]
   then
      echo "Wrong species table format (missing TAXON_ID or/and ORGANISM tags on the fasta file)."
      exit 1
   fi
done < <(grep -m1 "^>" $inputFolders)

