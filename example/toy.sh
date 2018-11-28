#!/bin/bash
gunzip toy/*.gz
exit

bash buildSpeciesTable.sh -i "example/query/*.fa" > data/toy.speciesTable.tsv
bash buildSpeciesTable.sh -i "example/ref/*.fa" >> data/toy.speciesTable.tsv
bash submitContamination_and_wait.sh -q "example/query/*.fa" -r "example/ref/*.fa"

echo "wait until the end of all jobs"
exit

bash translateAndListCandidates.sh -i "results/*.candidates.tsv" -s data/toy.speciesTable.tsv -o toy
bash exceptions.sh -i toy -s data/toy.speciesTable.tsv

