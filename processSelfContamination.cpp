#!/bin/bash

#path to LAST binaries should be specify here
export PATH=$PATH:/kingdoms/mpb/workspace7/rocha/LAST/last-921/src/

inputLibrary=$1
inputList=$2

libraries=(`cat $inputList`)
qtdLibraries=`cat $inputList | wc -l`
let qtdLibraries-=1

echo "processing library $inputLibrary againt libraries listed in $inputList"

if [ "$inputLibrary" != "" ]
then
   libraryName=`echo "$inputLibrary" | rev | cut -f 1 -d "/" | cut -d "." -f 2- | rev`
   
   #Jump to the next library to avoid compare all againt all
   start=0
   for i in `seq 0 $qtdLibraries`
   do
      start=$i
      if [ "$inputLibrary" == "${libraries[$i]}" ]
      then
         break
      fi
   done
   let start+=1

   if [ $start -le $qtdLibraries ]
   then
      #build last DB
      lastdb -cR01 ${libraryName}.DB $inputLibrary
      echo -n "" > $libraryName.blasttab

      #compare the current library againt all the next ones (to avoid all againts all)
      for j in `seq $start $qtdLibraries`
      do
         speciesName=`echo "${libraries[$j]}" | rev | cut -f 1 -d "/" | cut -d "." -f 2- | rev`
         lastal -P 4 -e64 -fBlastTab+ $libraryName.DB ${libraries[$j]} | sed "s/$/"$'\t'"$speciesName"$'\t'"$libraryName/" >> $libraryName.blasttab
      done
      rm -vf $libraryName.DB*

      #parse all the useful columns of lastal result
      grep -v "^#" $libraryName.blasttab | awk -F '\t' '{if ($15 > $14) short = $14; else short = $15; if ($4 >= 150 || $4 >= (short/2)) print $1"\t"$16"\t"$2"\t"$17"\t"sprintf("%.0f",$3);}' > $libraryName.tsv
      gzip $libraryName.blasttab

      #list all the distinct library pairs amoung hits found by lastal
      IFS=$'\n' libraryPairs=(`cut -f 2,4 $libraryName.tsv | sort | uniq`)

      libraryCount=${#libraryPairs[@]}
      let libraryCount-=1

      #find contaminated sequences based on Daniel Richter criterias (Roscoff lab) scanning pair by pair of libraries found by lastal
      echo -n "" > $libraryName.candidates.tsv
      for j in `seq 0 $libraryCount`
      do
         libraryA=`echo "${libraryPairs[$j]}" | cut -f1`
         libraryB=`echo "${libraryPairs[$j]}" | cut -f2`

         for k in `seq 0 100`
         do
            hits[$k]=0
         done

         while read counts
         do
            identity=`echo "$counts" | cut -f 2`
            hits[${identity}]=`echo "$counts" | cut -f 1`
         done < <(grep "$libraryA" $libraryName.tsv | grep "$libraryB" | cut -f 5 | sort | uniq -c | sed "s/^[ ]\+//" | sed "s/ /"$'\t'"/" | sort -t$'\t' -k2gr,2)

         #debug -> print the distribution
         echo "# $libraryA $libraryB"
         for k in `seq 0 100`
         do
            echo "# $k ${hits[${k}]}"
         done

         #find the the cutoff threshold
         threshold=101
         if [ ${hits[100]} -gt ${hits[99]} ]
         then
            for i in `seq 100 -1 0`
            do
               binCount0=${hits[$i]}
               binCount1=${hits[$(( $i - 1 ))]}
               binCount2=${hits[$(( $i - 2 ))]}
               if [[ $binCount0 -le $binCount1 && $binCount1 -le $binCount2 ]]
               then
                  threshold=$i
                  break
               fi
            done

            grep "$libraryA" $libraryName.tsv | grep "$libraryB" | awk -F '\t' -v threshold=$threshold '{if (threshold <= $5) print $0"\t"threshold}' >> $libraryName.candidates.tsv
         fi
      done
      gzip $libraryName.tsv
   fi
fi

mv *.candidates.tsv results/
mv *.gz results/

