#!/bin/bash

export HOME=/pfs/nobackup$HOME

ALL_MODELS=`find . -wholename "models/pilot1/*model-*.pt"`

cd $OpenNMT_py

for MODEL_PATH in $ALL_MODELS
do
    DATE=`echo $MODEL_PATH | sed 's/.*model-\([0-9]*-[0-9]*\).*/\1/'`
    export MODEL_PATH=$MODEL_PATH
    export SRC_PATH="processed/pilot1/$DATE/src-train.txt"
    export RESULT_PATH="processed/pilot1/$DATE/predictions.txt"
    export LOG_PATH="processed/pilot1/$DATE/translate.out"
    echo $DATE
    sbatch jobscript-translate-training
done
