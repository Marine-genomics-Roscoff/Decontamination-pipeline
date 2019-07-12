#!/bin/bash
export PATH=$PATH:./

usage="$(basename "$0") [-h] -i prefix -s speciesTable -- program to process the exceptions
where:
    -h  show this help text
    -i  prefix used in the translate step
    -s  set the table of species
"
while getopts h:i:s: option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    i) prefix=$OPTARG
       ;;
    s) speciesTable=$OPTARG
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

if [ "$speciesTable" == "" ]
then
   echo "missing species table" >&2
   exit 1
fi

if [ "$prefix" == "" ]
then
   echo "missing prefix" >&2
   exit 1
fi

awk -F '\t' '{if ($1 == $2) print "SPECIES\t"$0}' ${prefix}.crossContaminantion.organism.pairs.tsv > ${prefix}.crossContaminantion.organism.pairs.exceptions.tsv
awk -F '\t' '{if ($1 != $2) print $0}' ${prefix}.crossContaminantion.organism.pairs.tsv > ${prefix}.crossContaminantion.organism.pairs.0.tmp

echo "absent taxons - you have to fill data/obsolete.genus.tsv based on data/${prefix}.absent.genus.tsv and rerun this script"
cut -f 1,2 ${prefix}.crossContaminantion.organism.pairs.0.tmp | tr '\t' '\n' | sort | uniq > ${prefix}.crossContaminantion.organism.pairs.6.tmp
cut -f 1 data/from_species_to_genus.tsv | sort | uniq > ${prefix}.crossContaminantion.organism.pairs.7.tmp
bash /kingdoms/mpb/workspace3/rocha/algorithms/scripts/compare.sh ${prefix}.crossContaminantion.organism.pairs.7.tmp ${prefix}.crossContaminantion.organism.pairs.6.tmp | sed "s/$/"$'\t'"/" > data/${prefix}.absent.genus.tsv

while read fromTo
do
   in=`echo "$fromTo" | cut -f 1`
   out=`echo "$fromTo" | cut -f 2`
   sed -i "s/^$in"$'\t'"/$out"$'\t'"/" ${prefix}.crossContaminantion.organism.pairs.0.tmp; 
   sed -i "s/"$'\t'"$in"$'\t'"/"$'\t'"$out"$'\t'"/" ${prefix}.crossContaminantion.organism.pairs.0.tmp
done < <(grep $'\t'"[0-9]\|\-1" data/obsolete.genus.tsv)

echo "if you did not succeded to fix all data/${prefix}.absent.genus.tsv, you can fill data/from_species_to_genus.tsv with the missing, but for another taxonomic level (like family) and rerun this script."
#grep $'\t'"[0-9]\|\-1" missing.taxons.tsv >> from_species_to_genus.tsv

joinCut.bin data/from_species_to_genus.tsv "1" "2"  ${prefix}.crossContaminantion.organism.pairs.0.tmp "1" "1 2 3 4 5 6" ${prefix}.crossContaminantion.organism.pairs.1.tmp
joinCut.bin data/from_species_to_genus.tsv "1" "2"  ${prefix}.crossContaminantion.organism.pairs.1.tmp "2" "1 2 3 4 5 6 7" ${prefix}.crossContaminantion.organism.pairs.2.tmp

awk -F '\t' '{if ($7 == $8) print "GENUS\t"$0}' ${prefix}.crossContaminantion.organism.pairs.2.tmp >> ${prefix}.crossContaminantion.organism.pairs.exceptions.tsv
awk -F '\t' '{if ($7 != $8) print $0}' ${prefix}.crossContaminantion.organism.pairs.2.tmp > ${prefix}.crossContaminantion.organism.pairs.3.tmp

awk -F '\t' '{if ($3 ~ /^UN/ && $4 ~ /^UN/) print "UNKNOWN\t"$0}' ${prefix}.crossContaminantion.organism.pairs.3.tmp >> ${prefix}.crossContaminantion.organism.pairs.exceptions.tsv
awk -F '\t' '{if (!($3 ~ /^UN/ && $4 ~ /^UN/)) print $0}' ${prefix}.crossContaminantion.organism.pairs.3.tmp >> ${prefix}.crossContaminantion.organism.pairs.4.tmp
awk -F '\t' '{if (substr($3,1,index(gensub("-"," ","g",$3)," ") -1) == substr($4,1,index(gensub("-"," ","g",$4)," ") -1) && substr($4,1,index(gensub("-"," ","g",$4)," ")) != "")  print "NAME\t"$0}' ${prefix}.crossContaminantion.organism.pairs.4.tmp >> ${prefix}.crossContaminantion.organism.pairs.exceptions.tsv
awk -F '\t' '{if (substr($3,1,index(gensub("-"," ","g",$3)," ") -1) != substr($4,1,index(gensub("-"," ","g",$4)," ") -1) || substr($4,1,index(gensub("-"," ","g",$4)," ")) == "")  print $0}' ${prefix}.crossContaminantion.organism.pairs.4.tmp > ${prefix}.crossContaminantion.organism.pairs.5.tmp

echo "you should fill data/knownExceptions.tsv with the exceptions you alread know and rerun this script"
while read exception
do
   spA=`echo "$exception" | cut -f 1`
   spB=`echo "$exception" | cut -f 2`
   awk -v spA="$spA" -v spB="$spB" -F '\t' '{if (($3 ~ spA && $4 ~ spB) || ($3 ~ spB && $4 ~ spA)) print "EXCEPT\t"$0}' ${prefix}.crossContaminantion.organism.pairs.0.tmp >> ${prefix}.crossContaminantion.organism.pairs.exceptions.tsv
done < data/knownExceptions.tsv

echo "verify your-self manually the exceptions (${prefix}.crossContaminantion.organism.pairs.exceptions.tsv), prefix lines with # that you do not agree and rerun this script"
grep -v "^#" ${prefix}.crossContaminantion.organism.pairs.exceptions.tsv | cut -f 6,7 | sort | uniq > data/pattern.exceptions.tsv

grep -Fv -f data/pattern.exceptions.tsv ${prefix}.crossContaminantion.sequence.pairs.tsv > results/final.${prefix}.crossContaminantion.sequence.pairs.tsv
joinCut.bin ${speciesTable} "1" "2" results/final.${prefix}.crossContaminantion.sequence.pairs.tsv "1" "1 2 3 4" results/final.${prefix}.crossContaminantion.sequence.pairs.0.tmp
joinCut.bin ${speciesTable} "1" "2" results/final.${prefix}.crossContaminantion.sequence.pairs.0.tmp "2" "1 2 3 4 5" results/final.${prefix}.crossContaminantion.sequence.pairs.1.tmp
cut -f 1,2,5,6 results/final.${prefix}.crossContaminantion.sequence.pairs.1.tmp | sort | uniq -c | sed "s/^[ ]\+//" | sort -gr | sed "s/ /"$'\t'"/" > results/final.${prefix}.crossContaminantion.organism.pairs.tsv
awk -F '\t' '{print $1"\t"$5"\t"$3"\n"$2"\t"$6"\t"$4}' results/final.${prefix}.crossContaminantion.sequence.pairs.1.tmp | sort | uniq | cut -f 1,2 | sort | uniq -c | sed "s/^[ ]\+//" | sort -gr | sed "s/ /"$'\t'"/" > results/final.${prefix}.crossContaminantion.organism.tsv

mv ${prefix}.crossContaminantion.* results/
