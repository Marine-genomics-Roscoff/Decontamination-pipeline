#!/bin/bash

delimiter=$1
input=$2
output=$3
fasta=$4

usage="$(basename "$0") [-h] -d \"delimiter\" -l \"lineage\" -o \"output\" -f \"fasta\" -- program build a hierarchy of species based on the lineage
where:
    -h  show this help text
    -d  set the column delimiter of the lineage and fasta file
    -l  set the lineage file
    -o  set the new fasta file with the lineage
    -f  set the fasta file"

while getopts h:f:l:o:d: option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    l) input=$OPTARG
       ;;
    o) output=$OPTARG
       ;;
    d) delimiter=$OPTARG
       ;;
    f) fasta=$OPTARG
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

if [ "$input" == "" ]
then
   echo "missing lineage" >&2
   exit 1
fi

if [ "$output" == "" ]
then
   echo "missing the output" >&2
   exit 1
fi

if [ "$delimiter" == "" ]
then
   echo "missing delimiter" >&2
   exit 1
fi

if [ "$fasta" == "" ]
then
   echo "missing fasta" >&2
   exit 1
fi

cat ${input} | tr "$delimiter" "\n" | sort | uniq | cat -n | sed "s/[ ]\+/"$'\t'"/" | cut -f 2- > ${output}.0.tmp
numCols=`awk -F "$delimiter" '{print NR-1}'`


echo -n > ${output}.1.tmp
for col in `seq 1 $numCols`
do
   nextCol=$(($col + 1))
   cut -f $col,$nextCol $input | sort | uniq >> ${output}.1.tmp
done

sort ${output}.1.tmp | sed "s/$/$delimiter/" | sed "s/${delimiter}${delimiter}$/$delimiter/" | sed "s/^/$delimiter/" > ${output}.2.tmp

while read code
do
   taq=`echo "$code" | cut -f 2`
   number=`echo "$code" | cut -f 1`
   sed -i "s/;${tag};/;${number};/" ${output}.2.tmp
   sed -i "s/\b${tag}\b/${tag}${delimiter}TAXON_ID=${number}${delimiter}/" ${fasta}
done < ${output}.0.tmp

awk -F '\t' '{print $2"\t"$1}' ${output}.hierachy.tsv > ${output}.oneLevelUp.tsv
mv ${output}.0.tmp ${output}.codes.tsv
mv ${output}.2.tmp ${output}.hierachy.tsv
