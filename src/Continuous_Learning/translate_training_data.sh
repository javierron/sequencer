#!/bin/bash

python3 translate.py -gpu 0 -model $MODEL_PATH -src $SRC_PATH -beam_size 50 -n_best 50 -output $RESULT_PATH -dynamic_dict > $LOG_PATH 2>&1 
