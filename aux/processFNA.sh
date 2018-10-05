prefix=$1

#cat ${prefix}.0.fna | tr '\n' '@' | tr '>' '\n' | sed 's/@/\t/' | sed "s/@//g" | sed "s/^/>/" | sed "s/"$'\t'"/\n/" | sed "s/ /"$'\t'"/" > ${prefix}.fna
#sed -i '1d' ${prefix}.fna
transeq -frame 6 -sequence ${prefix}.fna -outseq ${prefix}.faa
cat ${prefix}.faa | tr '\n' '@' | tr '>' '\n' | sed 's/@/\t/' | sed "s/@//g" | sed "s/^/>/" | sed "s/ /"$'\t'"/" > ${prefix}.tsv 
sed -i "s/ /"$'\t'"/" ${prefix}.faa
sed -i '1d' ${prefix}.tsv
