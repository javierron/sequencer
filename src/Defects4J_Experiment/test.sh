MODELS_DIR="$HOME/sequencer/src/Continuous_Learning/models/model-*"

array=($(ls -v $MODELS_DIR))

echo ${array[@]}

parsed_array=()

for i in "${array[@]}"
do
   : 
   parsed_array+=( `echo $i | sed 's/.*model-\([0-9]*-[0-9]*\).*/\1/'`)
   # do whatever on $i
done

for j in ${parsed_array[@]}
do
   : 
   echo $j 
done
