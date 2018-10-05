for tag in NCGR_SEQ_ID ASSEMBLY_ACC TAXON_ID ORGANISM LENGTH; do sed -i "s/ ${tag}/ \/${tag}/" MMETSP.fna; done

