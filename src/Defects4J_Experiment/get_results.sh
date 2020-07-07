CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
MODELS_DIR="$HOME/sequencer/src/Continuous_Learning/models/model-*"
MODEL_LIST=($(ls -v $MODELS_DIR))
CONTINUOUS_LEARNING_DATA=$CURRENT_DIR/../Continuous_Learning/public/single_run_data

PARSED_MODEL_LIST=()

for i in "${MODEL_LIST[@]}"
do
   :
   PARSED_MODEL_LIST+=( `echo $i | sed 's/.*model-\([0-9]*-[0-9]*\).*/\1/'`)
done


for j in ${PARSED_MODEL_LIST[@]}
do
    :
    DEFECTS4J_PATCHES_DIR="$CURRENT_DIR/Defects4J_patches/$j" 
    CREATED=`find $DEFECTS4J_PATCHES_DIR -name '*' -type d | wc -l | awk '{print $1}'`
    COMPILED=`find $DEFECTS4J_PATCHES_DIR -name '*_compiled' | wc -l | awk '{print $1}'`
    PASSED=`find $DEFECTS4J_PATCHES_DIR -name '*_passed' | wc -l | awk '{print $1}'`
    echo "$CREATED,$COMPILED,$PASSED,$TIMESTAMP" >> $CONTINUOUS_LEARNING_DATA
done
