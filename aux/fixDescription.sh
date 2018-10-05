for tag in ASSEMBLY_ACC LENGTH NCGR_SAMPLE_ID NCGR_SEQ_ID ORGANISM TAXON_ID
do
   echo -n "${tag} "
   grep -c -m1 " ${tag}\|${tag} " MMETSP.tsv
done
