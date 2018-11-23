#!/bin/bash
gunzip toy/*.gz
exit
bash buildSpeciesTable.sh -i "toy/*.fa" > data/toy.speciesTable.tsv
bash buildSpeciesTable.sh -i "toy_target/*.fa" >> data/toy.speciesTable.tsv
bash submitContamination_and_wait.sh -i "toy/*.fa" -t "toy_target/*.fa"
bash translateAndListCandidates.sh -i "results/*.candidates.tsv" -s data/toy.speciesTable.tsv -o toy
bash exceptions.sh -i toy -s data/toy.speciesTable.tsv

