# Bash script to download the NCBI Tax IDs from the nucleotide accessions for the NCBI ITS sequences
# Saves to a list
# Then, the taxIDs can be cross-references with the ones in Mycocosm

# This doesn't go through the whole ITS database; only the ones with GENUS in common with Mycocosm

cd /projectnb/talbot-lab-data/Katies_data/picrust_for_fungi_package/
  cat nr_acc_its.txt | while read ACC || [[ -n $ACC ]];
do
echo -n -e "$ACC\t"
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=${ACC}&rettype=fasta&retmode=xml" |\
grep TSeq_taxid |\
cut -d '>' -f 2 |\
cut -d '<' -f 1 |\
tr -d "\n"
echo
done > its_acc_taxids.txt