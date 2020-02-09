#! /bin/bash

set -e
set -x

export PATH=$PATH:"$HOME/defects4j/framework/bin"

OpenNMT_py="$HOME/OpenNMT-py"
CONTINUOUS_LEARNING_PATH="$HOME/sequencer/src/Continuous_Learning"
DEFECTS4J_EXPERMENT_PATH="$HOME/sequencer/src/Defects4J_Experiment"

VOCABULARY="$HOME/sequencer/results/Golden/vocab.txt"

DATA_PATH="$CONTINUOUS_LEARNING_PATH/processed"
MODEL_PATH="$CONTINUOUS_LEARNING_PATH/models"
MODEL_TESTING_PATH="$HOME/sequencer/model"

FILE_SERVER_URL="" # set this up

TRAIN_SOURCE_FILE="$DATA_PATH/src-train.txt"
TRAIN_TARGET_FILE="$DATA_PATH/tgt-train.txt"

VALIDATION_SOURCE_FILE="$DATA_PATH/src-val.txt"
VALIDATION_TARGET_FILE="$DATA_PATH/tgt-val.txt"

mkdir -p $DATA_PATH

curl $FILE_SERVER_URL/src-train > TRAIN_SOURCE_FILE
curl $FILE_SERVER_URL/tgt-train > TRAIN_TARGET_FILE
curl $FILE_SERVER_URL/src-val > VALIDATION_SOURCE_FILE
curl $FILE_SERVER_URL/tgt-val > VALIDATION_TARGET_FILE

TRAINING_STEPS=10000

cd $CONTINUOUS_LEARNING_PATH


cd $OpenNMT_py
python preprocess.py -src_vocab $VOCABULARY -train_src $DATA_PATH/src-train.txt -train_tgt $DATA_PATH/tgt-train.txt -valid_src $DATA_PATH/src-val.txt -valid_tgt $DATA_PATH/tgt-val.txt -src_seq_length 1010 -tgt_seq_length 100 -src_vocab_size 1000 -tgt_vocab_size 1000 -dynamic_dict -share_vocab -save_data $DATA_PATH/final 2>&1 > $DATA_PATH/preprocess.out

TRAIN_STEPS_DIRECTIVE="-train_steps $TRAINING_STEPS"
TRAIN_FROM_DIRECTIVE=""
if ls $MODEL_PATH/final-model_step_*; then
    LAST_MODEL=`ls -t $MODEL_PATH/final-model_step_* | head -n1`
    TRAIN_FROM_DIRECTIVE="-train_from $LAST_MODEL"
    
    LAST_STEP=`echo $LAST_MODEL | sed 's/.*final-model_step_\([0-9]*\).*/\1/'`
    TRAIN_STEPS_DIRECTIVE="-train_steps $(( $LAST_STEP + $TRAINING_STEPS ))"
fi

python train.py -data $DATA_PATH/final -encoder_type brnn -enc_layers 2 -decoder_type rnn -dec_layers 2 -rnn_size 256 -global_attention general -batch_size 32 -word_vec_size 256 -bridge -copy_attn -reuse_copy_attn $TRAIN_STEPS_DIRECTIVE -gpu_ranks 0 -save_checkpoint_steps 10000 $TRAIN_FROM_DIRECTIVE -save_model $MODEL_PATH/final-model > $MODEL_PATH/train.final.out

cd $CONTINUOUS_LEARNING_PATH

NEW_MODEL=`ls -Art models/final-model_step_* | tail -n 1`

DATE=`date +"%d%m%Y-%H%M"`
cp $NEW_MODEL $MODEL_TESTING_PATH/model.pt
cp $NEW_MODEL $MODEL_PATH/model-$DATE.pt

cd $DEFECTS4J_EXPERMENT_PATH

./Defects4J_experiment.sh -l -t

curl -X POST -d @$CONTINUOUS_LEARNING_PATH/single_run_data $FILE_SERVER_URL/data

rm $DATA_PATH/*

