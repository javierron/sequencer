#!/bin/bash

set -e
set -x

if [ -z "$THREAD_ID" ]; then
    echo "THREAD_ID is not set!"
    exit
fi

if [ -z "$MODEL_PATH" ]; then
    echo "MODEL_PATH is not set!"
    exit
fi

if [ -z "$RESULT_PATH" ]; then
    echo "RESULT_PATH is not set!"
    exit
fi

CONTINUOUS_LEARNING_PATH="$HOME/sequencer/src/Continuous_Learning"
OpenNMT_py="$HOME/OpenNMT-py"
DATA_PATH="$HOME/sequencer/results/Golden"

mkdir -p $RESULT_PATH

cd $OpenNMT_py
python3 translate.py -gpu 0 -model $MODEL_PATH -src $DATA_PATH/src-test.txt -beam_size 50 -n_best 50 -output $RESULT_PATH/predictions.txt -dynamic_dict > $RESULT_PATH/translate.out 2>&1 

cd $CONTINUOUS_LEARNING_PATH
python3 codrep-compare.py $RESULT_PATH/predictions.txt $DATA_PATH/tgt-test.txt $RESULT_PATH/result.txt > $RESULT_PATH/compare.out 2>&1
