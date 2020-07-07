OpenNMT_py="$HOME/OpenNMT-py"
CONTINOUS_LEARNING_PATH="$HOME/sequencer/src/Continous_Learning"

DATA_PATH="$CONTINOUS_LEARNING_PATH/processed/pilot1-augment"
VOCABULARY="$HOME/sequencer/results/Golden/vocab.txt"
TRAIN_SOURCE_FILE="$DATA_PATH/src-train.txt"
TRAIN_TARGET_FILE="$DATA_PATH/tgt-train.txt"
MODEL_PATH="$CONTINOUS_LEARNING_PATH/models/pilot-1"
LAST_MODEL="$MODEL_PATH/final-model_step_9500.pt"

cd OpenNMT_py

python preprocess.py -src_vocab $VOCABULARY -train_src $TRAIN_SOURCE_FILE -train_tgt $TRAIN_TARGET_FILE -src_seq_length 1010 -tgt_seq_length 100 -src_vocab_size 1000 -tgt_vocab_size 1000 -dynamic_dict -share_vocab -save_data $DATA_PATH/final 2>&1 > $DATA_PATH/preprocess.out

python train.py -data $DATA_PATH/final -encoder_type brnn -enc_layers 2 -decoder_type rnn -dec_layers 2 -rnn_size 256 -global_attention general -batch_size 32 -word_vec_size 256 -bridge -copy_attn -reuse_copy_attn -train_steps 1000 -learning_rate 0.125 -train_from  -gpu_ranks 0 -save_checkpoint_steps 10000 -train_from $LAST_MODEL -save_model $MODEL_PATH/final-model > $MODEL_PATH/train.final.out
