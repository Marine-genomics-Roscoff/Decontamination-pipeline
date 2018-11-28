#!/bin/bash

usage="$(basename "$0") [-h] -i \"resultFiles\" -o outputPrefix -s speciesTable -- program to pre-process the candidates 
where:
    -h  show this help text
    -i  set the result files -- should be a complete path double quoted
    -o  set the output prefix
    -s  set the table of species
"

while getopts h:i:s:o: option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    i) inputFiles=$OPTARG
       ;;
    s) speciesTable=$OPTARG
       ;;
    o) outputPrefix=$OPTARG
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

if [ "$inputFiles" == "" ]
then
   echo "missing result files" >&2
   exit 1
fi

if [ "$speciesTable" == "" ]
then
   echo "missing species table" >&2
   exit 1
fi

if [ "$outputPrefix" == "" ]
then
   echo "missing output prefix" >&2
   exit 1
fi

#list all the possible contaminated pair of libraries
grep -v "^#" $inputFiles | cut -d ":" -f 2- | awk -F '\t' '{print $2"\t"$4"\t"$1"\t"$3"\t"$5"\t"$6}' > $outputPrefix.crossContaminantion.sequence.pairs.tsv
cut -f 2,1 $outputPrefix.crossContaminantion.sequence.pairs.tsv | sort | uniq | sed "s/^/"$'\t'"/" | sed "s/$/"$'\t'"/" > $outputPrefix.crossContaminantion.organism.pairs.tsv

while read translation
do
   fileName=`echo "$translation" | cut -f1`
   specieName=`echo "$translation" | cut -f2`
   taxon=`echo "$translation" | cut -f3`
   echo "$fileName -> $specieName"
   sed -i "s/"$'\t'"$fileName"$'\t'"/"$'\t'"$fileName"$'\t'"$specieName"$'\t'"$taxon"$'\t'"/" $outputPrefix.crossContaminantion.organism.pairs.tsv
done < <(grep -v "^#" $speciesTable)

sed -i "s/^"$'\t'"//" $outputPrefix.crossContaminantion.organism.pairs.tsv
sed -i "s/"$'\t'"$//" $outputPrefix.crossContaminantion.organism.pairs.tsv

awk -i inplace -F '\t' '{print $3"\t"$6"\t"$2"\t"$5"\t"$1"\t"$4}' $outputPrefix.crossContaminantion.organism.pairs.tsv
