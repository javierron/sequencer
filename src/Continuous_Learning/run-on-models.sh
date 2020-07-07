set -e
set -x

MODELS=`ls -dv ~/models-pilot/*`
MODEL_PATH="$HOME/sequencer/model/model.pt"
CODREP_RESULT="$HOME/codrep-result.txt"
D4J_RESULT="$HOME/d4j-result.txt"
CONTINUOUS_LEARNING_PATH="$HOME/sequencer/src/Continuous_Learning"
DEFECTS4J_EXPERMENT_PATH="$HOME/sequencer/src/Defects4J_Experiment"

for MODEL in $MODELS
do
    export DATE=`date +%s`
    echo "Processing $MODEL file..."

    cp $MODEL $MODEL_PATH

    cd $CONTINUOUS_LEARNING_PATH
    ./codrep-test.sh
    echo ",$DATE" >> $CONTINUOUS_LEARNING_PATH/Codrep_Results/$DATE/result.txt
    echo `cat $CONTINUOUS_LEARNING_PATH/Codrep_Results/$DATE/result.txt` >> $CODREP_RESULT

    cd $DEFECTS4J_EXPERMENT_PATH
    ./Defects4J_experiment.sh -l -t
    echo `cat $CONTINUOUS_LEARNING_PATH/public/single_run_data` >> $D4J_RESULT

done