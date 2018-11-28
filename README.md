# Decontamination-pipeline

**requirements**
* LAST (http://last.cbrc.jp/)
* my file processing libs in C++
* condor like clusters (can be adapted to SGE, OAR or PBS)
   * only in linux nodes
* Only decontaminate DNA libraries

**TODO**

refers the original idea (cite needed)

explain the toy example

explain the format of the libraries -> basically a fasta file where the header has the ORGANISM and TAXON tags.

libraries and organisms should have unique names, even if the were place in different directories

**explain the manual verification steps**
* obsolet names/taxons
* species to genus file
* exceptions
