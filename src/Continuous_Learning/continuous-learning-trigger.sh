#!/bin/bash

set -e
set -x

while [ "$1" != "" ]; do
  case $1 in
    -l | --local )
      LOCAL=1
      ;;
  esac
  shift
done

if ! command -v sshpass &>/dev/null; then
  echo "sshpass is not installed"
  exit 1
fi

CONTINUOUS_LEARNING_PATH="$HOME/sequencer/src/Continuous_Learning"
DIFFS_DIR="$HOME/continuous-learning-data"
OUTPUT_PATH="$CONTINUOUS_LEARNING_PATH/public"

TRAIN_SOURCE_ACC_FILE="$OUTPUT_PATH/src-train-acc.txt"
TRAIN_TARGET_ACC_FILE="$OUTPUT_PATH/tgt-train-acc.txt"
VALIDATION_SOURCE_ACC_FILE="$OUTPUT_PATH/src-val-acc.txt"
VALIDATION_TARGET_ACC_FILE="$OUTPUT_PATH/tgt-val-acc.txt"

TRAIN_SOURCE_FILE="$OUTPUT_PATH/src-train.txt"
TRAIN_TARGET_FILE="$OUTPUT_PATH/tgt-train.txt"
VALIDATION_SOURCE_FILE="$OUTPUT_PATH/src-val.txt"
VALIDATION_TARGET_FILE="$OUTPUT_PATH/tgt-val.txt"

LEARNING_RATES=(0.03125 0.0625 0.09375)
DATA_POINT_THRESHOLD=10000

# set TRAIN_URL 
# TRAIN_URL="user@address.com"

mkdir -p "$OUTPUT_PATH"

while :
do
  python3 tokenize.py "$DIFFS_DIR" "$OUTPUT_PATH"
  rm -rf "${DIFFS_DIR:?}"/*

  NUMBER_OF_DATA_POINTS=$(wc -l < "$TRAIN_SOURCE_ACC_FILE")

  if [ "$NUMBER_OF_DATA_POINTS" -gt $DATA_POINT_THRESHOLD ] ; then

    cd "$CONTINUOUS_LEARNING_PATH"

    cp "$TRAIN_SOURCE_ACC_FILE" "$TRAIN_SOURCE_FILE"
    cp "$TRAIN_TARGET_ACC_FILE" "$TRAIN_TARGET_FILE"
    cp "$VALIDATION_SOURCE_ACC_FILE" "$VALIDATION_SOURCE_FILE"
    cp "$VALIDATION_TARGET_ACC_FILE" "$VALIDATION_TARGET_FILE"

    FILESIZE_TRAIN=$(stat -c%s "$TRAIN_SOURCE_FILE")
    FILESIZE_VAL=$(stat -c%s "$VALIDATION_SOURCE_FILE")

    if [ "$FILESIZE_TRAIN" -gt "0" ] && [ "$FILESIZE_VAL" -gt "0" ] ; then

        echo "executing remote training..."

        for i in "${!LEARNING_RATES[@]}"; do
          echo "  with learning rate: ${LEARNING_RATES[$i]}"
          if [ $LOCAL -eq "1" ] ; then
            export DATA_PATH="$OUTPUT_PATH"
            export DATE=$(date +"%d%m%Y-%H%M")
            export THREAD_ID="$i"
            ./continuous-learning-train-and-test.sh -lr "${LEARNING_RATES[$i]}" & >> "training-$i.log"
          else
            sshpass -e ssh "$TRAIN_URL" "~/pfs/sequencer/src/Continuous_Learning/continuous-learning-get-and-submit.sh -t $i -l ${LEARNING_RATES[$i]}"
          fi
        done

        rm "$TRAIN_SOURCE_ACC_FILE"
        rm "$TRAIN_TARGET_ACC_FILE"
        rm "$VALIDATION_SOURCE_ACC_FILE"
        rm "$VALIDATION_TARGET_ACC_FILE"
    fi

  fi
  sleep 20m

done
