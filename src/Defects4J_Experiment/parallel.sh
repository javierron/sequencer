set -e
set -x

MODELS_DIR="$HOME/sequencer/src/Continuous_Learning/models/model-*"

MODEL_LIST=($(ls -v $MODELS_DIR))

for i in "${MODEL_LIST[@]}"
do
   : 
   sbatch ./Defects4J_experiment.sh --export=ALL,MODEL=$i
done

