#!/bin/bash

export HOME=/pfs/nobackup$HOME

ALL_MODELS=`find . -wholename "*models/pilot1/*model-.pt"`

cd $OpenNMT_py

for $MODEL_PATH in $ALL_MODELS
do
    DATE=`echo $MODEL_PATH | sed 's/.*model-\([0-9]{8}-[0-9]{4}\).*/\1/'`
    echo $MODEL_PATH
    echo $DATE
done
