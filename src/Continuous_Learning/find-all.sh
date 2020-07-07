ALL=`find . -wholename "*Codrep_Results/pilot1/*predictions.txt"`

rm training-passed

for x in $ALL
do
    python3 find-passed.py $x ../../results/Golden/tgt-test.txt result-found.txt
done