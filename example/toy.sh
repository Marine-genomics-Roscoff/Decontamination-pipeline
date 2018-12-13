#!/bin/bash
gunzip example/query/*.gz
gunzip example/ref/*.gz
exit

bash buildSpeciesTable.sh -i "example/query/*.fa" > data/toy.speciesTable.tsv
bash buildSpeciesTable.sh -i "example/ref/*.fa" >> data/toy.speciesTable.tsv
exit

#if you want to do all against all comparisons 
bash submitContamination_and_wait.sh -q "example/query/*.fa"
#else 
bash submitContamination_and_wait.sh -q "example/query/*.fa" -r "example/ref/*.fa"
exit

echo "wait until the end of all jobs"
exit

echo "Ways to do not consider pairs as contaminations:"
echo "Fill the file data/knownExceptions.tsv with the exceptions with already know"
echo "Fill the file data/from_species_to_genus.tsv with the correct hierachy to be ignored"
echo "Fill the file data/obsolete.genus.tsv with the genus that are obsolete and the new corresponding codes"
exit

bash translateAndListCandidates.sh -i "results/*.candidates.tsv" -s data/toy.speciesTable.tsv -o toy
bash exceptions.sh -i toy -s data/toy.speciesTable.tsv

